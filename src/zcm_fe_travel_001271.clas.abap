CLASS zcm_fe_travel_001271 DEFINITION
PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    constants:
      begin of invallid_Price,
        msgid type symsgid value 'Z_FE_001271_TRAVEL',
        msgno type symsgno value '000',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of invallid_Price.

      CONSTANTS:
      BEGIN OF invalid_dates,
        msgid TYPE symsgid      VALUE 'Z_FE_001271_TRAVEL',
        msgno TYPE symsgno      VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_dates.

          CONSTANTS:
      BEGIN OF travel_already_cancelled,
        msgid TYPE symsgid      VALUE 'Z_FE_001271_TRAVEL',
        msgno TYPE symsgno      VALUE '005',
        attr1 TYPE scx_attrname VALUE 'DESCRIPTION',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF travel_already_cancelled.

    CONSTANTS:
      BEGIN OF travel_cancelled_successfully,
        msgid TYPE symsgid      VALUE 'Z_FE_001271_TRAVEL',
        msgno TYPE symsgno      VALUE '006',
        attr1 TYPE scx_attrname VALUE 'DESCRIPTION',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF travel_cancelled_successfully.

    CONSTANTS:
      BEGIN OF travel_not_open,
        msgid TYPE symsgid      VALUE 'Z_FE_001271_TRAVEL',
        msgno TYPE symsgno      VALUE '002',
        attr1 TYPE scx_attrname VALUE 'DESCRIPTION',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF travel_not_open.

    CONSTANTS:
      BEGIN OF travel_confirmed_successfully,
        msgid TYPE symsgid      VALUE 'Z_FE_001271_TRAVEL',
        msgno TYPE symsgno      VALUE '003',
        attr1 TYPE scx_attrname VALUE 'DESCRIPTION',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF travel_confirmed_successfully.

     DATA description TYPE /dmo/description.

    METHODS constructor
      IMPORTING severity  TYPE if_abap_behv_message=>t_severity
                textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                !description TYPE /dmo/description      OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_fe_travel_001271 IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    if_abap_behv_message~m_severity = severity.
    me->description = description.
  ENDMETHOD.




ENDCLASS.
