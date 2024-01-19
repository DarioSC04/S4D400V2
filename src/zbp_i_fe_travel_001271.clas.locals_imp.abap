CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

   PUBLIC SECTION.

  PRIVATE SECTION.

    METHODS CalculateBookingID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~CalculateBookingID.
    METHODS CalculateTotalPrice FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~CalculateTotalPrice.
    METHODS Custemerid FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~Custemerid.
    METHODS BokkingDatetoToday FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~BokkingDatetoToday.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD CalculateBookingID.
    READ ENTITY IN LOCAL MODE ZI_FE_Booking_001271
      FIELDS ( BookingID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings REFERENCE INTO DATA(booking).
      SELECT SINGLE FROM zi_fe_booking_001271
      FIELDS max( bookingId )
      WHERE travelUuid = @booking->TravelUUID
      INTO @DATA(MaxId).
      booking->BookingID = MaxId + 1.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_fe_booking_001271
      UPDATE FIELDS ( BookingId )
      WITH VALUE #( for b in bookings ( %tky      = b-%tky
                                      BookingId = b-BookingID ) ).

  ENDMETHOD.

  METHOD CalculateTotalPrice.
      READ ENTITY IN LOCAL MODE ZI_FE_Booking_001271
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).


    LOOP AT bookings REFERENCE INTO DATA(booking).

     data total_price type  /dmo/flight_price.
     data travelimport type table for read import zi_fe_travel_001271\_booking.

      travelimport = value #( ( TravelUUID = booking->TravelUUID ) ).

      READ ENTITY IN LOCAL MODE zi_fe_travel_001271
      by \_Booking
      FIELDS ( FlightPrice CurrencyCode )
      with travelimport
      RESULT DATA(bokkins_in_Travel).


      LOOP AT bokkins_in_Travel REFERENCE INTO DATA(bokkin_in_Travel).


      total_price += bokkin_in_Travel->FlightPrice." bokkin_in_Travel->FlightPrice.
      Endloop.

      SELECT SINGLE FROM zi_fe_travel_001271
      FIELDS ( BookingFee )
      WHERE TravelUUID = @booking->TravelUUID
      INTO @DATA(Fee).

      total_price += Fee.

      MODIFY ENTITY IN LOCAL MODE zi_fe_travel_001271
      UPDATE FIELDS ( TotalPrice )
      WITH VALUE #( for b in bookings ( TravelUUID      = b-TravelUUID
                                       TotalPrice = total_price ) ).


    ENDLOOP.



  ENDMETHOD.

  METHOD Custemerid.

       READ ENTITY IN LOCAL MODE ZI_FE_Booking_001271
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings REFERENCE INTO DATA(booking).

      SELECT SINGLE FROM zi_fe_travel_001271
      FIELDS ( CustomerID )
      WHERE TravelUUID = @booking->TravelUUID
      INTO @DATA(ID).

    endloop.

          MODIFY ENTITY IN LOCAL MODE ZI_FE_Booking_001271
          UPDATE FIELDS ( CustomerID )
           WITH VALUE #( FOR t IN bookings
                         ( %tky = t-%tky CustomerID = Id ) ).


  ENDMETHOD.

  METHOD BokkingDatetoToday.

      READ ENTITY IN LOCAL MODE ZI_FE_Booking_001271
      FIELDS ( BookingDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings REFERENCE INTO DATA(booking).

    if booking->BookingDate is INITIAL.

    booking->BookingDate = sy-datum.

    endif.
    endloop.

          MODIFY ENTITY IN LOCAL MODE ZI_FE_Booking_001271
          UPDATE FIELDS ( BookingDate )
           WITH VALUE #( FOR t IN bookings
                         ( %tky = t-%tky BookingDate = t-BookingDate ) ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      calculatetravelid FOR DETERMINE ON SAVE
        IMPORTING
          keys FOR  Travel~CalculateTravelID ,
      validateprice FOR VALIDATE ON SAVE
        IMPORTING keys FOR Travel~validateprice,
      ValidateDates FOR VALIDATE ON SAVE
            IMPORTING keys FOR Travel~ValidateDates,
      CancelTravel FOR MODIFY
            IMPORTING keys FOR ACTION Travel~CancelTravel RESULT result,
      ConfirmBooking FOR MODIFY
            IMPORTING keys FOR ACTION Travel~ConfirmBooking RESULT result.
    " bookFlight FOR MODIFY
    " IMPORTING keys FOR ACTION Travel~bookFlight.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD validateprice.

    READ ENTITY IN LOCAL MODE ZI_FE_Travel_001271
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(prices).

    LOOP AT prices INTO DATA(price).
      IF price-TotalPrice < 0 .
      data(message) = new zcm_fe_travel_001271( severity = if_abap_behv_message=>severity-error textid = zcm_fe_travel_001271=>invallid_price ).
        APPEND VALUE #( %tky = price-%tky ) TO failed-travel.
       APPEND VALUE #( %tky           = price-%tky
                       %msg           = message
                       ) TO reported-travel.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  "METHOD bookFlight.
  "ENDMETHOD.

  METHOD calculatetravelid.
    READ ENTITY IN LOCAL MODE ZI_FE_Travel_001271
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels reference INTO DATA(travel).
      SELECT SINGLE FROM zi_fe_travel_001271
      FIELDS max( TravelId )
      INTO @DATA(MaxId).
      MaxId = MaxId + 1.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_fe_travel_001271
      UPDATE FIELDS ( TravelId )
      WITH VALUE #( for t in travels ( %tky      = t-%tky
                                      TravelId = MaxId ) ).
  ENDMETHOD.

    METHOD validatedates.
    DATA message TYPE REF TO zcm_fe_travel_001271.

    " Read Travels
    READ ENTITY IN LOCAL MODE ZI_FE_Travel_001271
         FIELDS ( BeginDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    " Process Travels
    LOOP AT travels INTO DATA(travel).
      " Validate Dates and Create Error Message
      IF travel-EndDate < travel-BeginDate.
        message = NEW zcm_fe_travel_001271( severity = if_abap_behv_message=>severity-error textid = zcm_fe_travel_001271=>invalid_dates ).
        APPEND VALUE #( %tky = travel-%tky
                        %msg = message ) TO reported-travel.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

    METHOD canceltravel.
    DATA message TYPE REF TO zcm_fe_travel_001271.

    " Read Travels
    READ ENTITY IN LOCAL MODE ZI_FE_Travel_001271
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    " Process Travels
    LOOP AT travels REFERENCE INTO DATA(travel).
      " Validate Status and Create Error Message
      IF travel->OverallStatus = 'X'.
        message = NEW zcm_fe_travel_001271( textid = zcm_fe_travel_001271=>travel_already_cancelled severity = if_abap_behv_message=>severity-error
                                  "travel = travel->Description
                                  ).
        APPEND VALUE #( %tky     = travel->%tky
                        %element = VALUE #( OverallStatus = if_abap_behv=>mk-on )
                        %msg     = message ) TO reported-travel.
*        APPEND VALUE #( %tky = travel->%tky ) TO failed-travel.
        DELETE travels INDEX sy-tabix.
        CONTINUE.
      ENDIF.

      " Set Status to Cancelled and Create Success Message
      travel->OverallStatus = 'X'.
      message = NEW zcm_fe_travel_001271( severity = if_abap_behv_message=>severity-success
                                textid   = zcm_travel=>travel_cancelled_successfully
                                "travel   = travel->Description
                                ).
      APPEND VALUE #( %tky     = travel->%tky
                      %element = VALUE #( OverallStatus = if_abap_behv=>mk-on )
                      %msg     = message ) TO reported-travel.
    ENDLOOP.

    " Modify Travels
    MODIFY ENTITY IN LOCAL MODE ZI_FE_Travel_001271
          UPDATE FIELDS ( OverallStatus )
           WITH VALUE #( FOR t IN travels
                         ( %tky = t-%tky OverallStatus = t-OverallStatus ) ).

    " Set Result
    result = VALUE #( FOR t IN travels
                      ( %tky   = t-%tky
                        %param = t ) ).
  ENDMETHOD.

  METHOD ConfirmBooking.
    DATA message TYPE REF TO zcm_fe_travel_001271.

    " Read Travels
    READ ENTITY IN LOCAL MODE ZI_FE_Travel_001271
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    " Process Travels
    LOOP AT travels REFERENCE INTO DATA(travel).

      " Validate Status and Create Error Message
      IF travel->OverallStatus = 'X' OR travel->OverallStatus = 'A'.
        message = NEW zcm_fe_travel_001271( severity = if_abap_behv_message=>severity-error
                                            textid = zcm_fe_travel_001271=>travel_not_open ).
        APPEND VALUE #( %tky     = travel->%tky
                        %element = VALUE #( OverallStatus = if_abap_behv=>mk-on )
                        %msg     = message ) TO reported-travel.
        APPEND VALUE #( %tky = travel->%tky ) TO failed-travel.
        DELETE travels INDEX sy-tabix.
        CONTINUE.
      ENDIF.

      " Set Status to Confirmed and Create Success Message
      travel->OverallStatus = 'A'.
      message = NEW zcm_fe_travel_001271( severity = if_abap_behv_message=>severity-success
                                          textid   = zcm_fe_travel_001271=>travel_confirmed_successfully ).
      APPEND VALUE #( %tky     = travel->%tky
                      %element = VALUE #( OverallStatus = if_abap_behv=>mk-on )
                      %msg     = message ) TO reported-travel.
    ENDLOOP.

    " Modify Travels
    MODIFY ENTITY IN LOCAL MODE ZI_FE_Travel_001271
           UPDATE FIELDS ( OverallStatus )
           WITH VALUE #( FOR t IN travels
                         ( %tky = t-%tky OverallStatus = t-OverallStatus ) ).

    " Set Result
    result = VALUE #( FOR t IN travels
                      ( %tky   = t-%tky
                        %param = t ) ).
  ENDMETHOD.

ENDCLASS.
