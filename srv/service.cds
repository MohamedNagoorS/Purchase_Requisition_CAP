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

@impl: './service.js'
@path: '/service/procurement'
service ProcurementService {
    entity Requisitions as projection on my.RequisitionHeader;
    entity RequisitionItems as projection on my.RequisitionItems;
    entity Vendors as projection on my.Vendors;
    entity CostCenters as projection on my.CostCenters;
    
    entity CatalogItems as projection on my.CatalogItems actions {
        action createCatalogPR(
            CostCenterID: String
        ) returns Requisitions;
    };

    action createManualPR(
        MaterialName: String,
        Quantity: Integer,
        Price: Decimal(10,2),
        CostCenterID: String
    ) returns Requisitions;
}