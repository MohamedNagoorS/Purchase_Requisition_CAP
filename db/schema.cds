namespace COE_DEMO;
using { cuid } from '@sap/cds/common';

@assert.unique: { invoicesID: [invoicesID] }
entity Invoices : cuid {
  invoicesID: String(36) @mandatory;
  invoiceNumber: String(50);
  vendorName: String(100);
  invoiceDate: Date;
  totalAmount: Decimal(10,2);
  currency : String(3);
  status: String(20);
  riskScore: Integer;
  paymentDueDate: Date;
  comments: String(1000);
}

