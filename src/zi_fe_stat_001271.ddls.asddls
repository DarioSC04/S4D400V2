@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Status view entity'
define view entity zi_fe_stat_001271
  as select from zfe_astat_001271 as Status
{
  @UI.textArrangement: #TEXT_ONLY
  @ObjectModel.text.element: [ 'TravelStatusText' ]
  key Status.travel_status_id as TravelStatusId,
  @UI.hidden: true
  Status.travel_status_text as TravelStatusText
  
}
