namespace COE_DEMO;
using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

@assert.unique: { invoicesID: [invoicesID] }
entity Invoices : cuid, managed {
  invoicesID: String(36) @mandatory;
  invoiceNumber: String(50);
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
  paymentDueDate: Date;
  comments: String(1000);

  Items : Composition of many InvoiceItems on Items.parent = $self;
}

entity InvoiceItems : cuid, managed {
  parent : Association to Invoices;
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