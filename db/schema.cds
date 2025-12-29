namespace COE_DEMO;
using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

@assert.unique: { invoicesID: [invoicesID] }
entity Invoices : cuid, managed {
  invoicesID: String(36) @mandatory;
  
  @title: 'Invoice Number'
  invoiceNumber: String(50);
  
  @title: 'Vendor Name'
  vendorName: String(100);
  
  invoiceDate: Date;
  totalAmount: Decimal(10,2);
  currency : String(3);
  
  // --- FIX START ---
  // 1. We create the actual column for the code (Visible to everyone)
  status_code: String(1) default 'N'; 
  
  // 2. We link the association MANUALLY to that column
  status: Association to Statuses on status.code = status_code;
  // --- FIX END ---

  riskScore: Integer;
  
  @title: 'Payment Due Date'
  paymentDueDate: Date;
  
  comments: String(1000);

  Items : Composition of many InvoiceItems on Items.parent = $self;
}

entity InvoiceItems : cuid, managed {
  parent : Association to Invoices;
  
  @title: 'Description'
  description : String(100);
  
  quantity : Integer;
  price : Decimal(10,2);
}

entity Statuses : CodeList {
  key code : String(1) enum {
    N;
    A;
    R;
    C;
  }
}

// ----------------------------------------------------------------------------
// Purchase Requisition Process Entities
// ----------------------------------------------------------------------------

entity RequisitionHeader : cuid, managed {
    @title: 'Description'
    Description : String(255);
    
    @title: 'Total Price'
    TotalPrice : Decimal(10,2);
    
    items : Composition of many RequisitionItems on items.parent = $self;
}

entity RequisitionItems : cuid, managed {
    parent : Association to RequisitionHeader;
    
    @title: 'Material'
    MaterialDescription : String(255);
    
    @title: 'Price'
    Price : Decimal(10,2);
    
    @title: 'Quantity'
    Quantity : Integer;
    
    @title: 'Cost Center'
    CostCenter : String(10); 
}

@cds.persistence.exists: false // Ensure CAP generates the table
entity Vendors {
    key ID : String(20); // Alphanumeric ID like 'VENDOR_A'
    Name : String(100);
}

entity CostCenters {
    key ID : String(10); // Alphanumeric ID like 'CC100'
    Name : String(100);
    Department : String(100);
}

entity CatalogItems : cuid {
    ItemName : String(100);
    Price : Decimal(10,2);
    vendor : Association to Vendors;
}
