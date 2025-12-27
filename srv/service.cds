using { COE_DEMO as my } from '../db/schema.cds';

@path: '/service/cOE_DEMO'
@requires: 'authenticated-user'
service cOE_DEMOSrv {
  @odata.draft.enabled
  entity Invoices as projection on my.Invoices {
    *,
    // Redirect 'Items' composition to the service-level 'InvoiceItems' entity.
    // This ensures that annotations applied to 'InvoiceItems' are picked up when navigating from Invoices.
    Items : redirected to InvoiceItems
  };
  
  // Explicitly expose items
  entity InvoiceItems as projection on my.InvoiceItems;
}