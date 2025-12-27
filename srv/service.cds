using { COE_DEMO as my } from '../db/schema.cds';

@path: '/service/cOE_DEMO'
@requires: 'authenticated-user'
service cOE_DEMOSrv {
  @odata.draft.enabled
  entity Invoices as projection on my.Invoices;
}