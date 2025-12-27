using { cOE_DEMOSrv } from '../srv/service.cds';

annotate cOE_DEMOSrv.Invoices with @UI.HeaderInfo: { TypeName: 'Invoice', TypeNamePlural: 'Invoices', Title: { Value: invoicesID } };
annotate cOE_DEMOSrv.Invoices with {
  ID @UI.Hidden @Common.Text: { $value: invoicesID, ![@UI.TextArrangement]: #TextOnly }
};
annotate cOE_DEMOSrv.Invoices with @UI.Identification: [{ Value: invoicesID }];
annotate cOE_DEMOSrv.Invoices with {
  invoicesID @title: 'ID';
  invoiceNumber @title: 'Invoice Number';
  vendorName @title: 'Vendor Name';
  invoiceDate @title: 'Invoice Date';
  totalAmount @title: 'Total Amount';
  status @title: 'Status';
  riskScore @title: 'Risk Score';
  paymentDueDate @title: 'Payment Due Date';
  comments @title: 'Comments'
};

annotate cOE_DEMOSrv.Invoices with {
  totalAmount @Measures.ISOCurrency: currency
};

annotate cOE_DEMOSrv.Invoices with @UI.LineItem: [
 { $Type: 'UI.DataField', Value: invoicesID },
 { $Type: 'UI.DataField', Value: invoiceNumber },
 { $Type: 'UI.DataField', Value: vendorName },
 { $Type: 'UI.DataField', Value: invoiceDate },
 { $Type: 'UI.DataField', Value: totalAmount },
 { $Type: 'UI.DataField', Value: status },
 { $Type: 'UI.DataField', Value: riskScore },
 { $Type: 'UI.DataField', Value: paymentDueDate },
 { $Type: 'UI.DataField', Value: comments }
];

annotate cOE_DEMOSrv.Invoices with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
 { $Type: 'UI.DataField', Value: invoicesID },
 { $Type: 'UI.DataField', Value: invoiceNumber },
 { $Type: 'UI.DataField', Value: vendorName },
 { $Type: 'UI.DataField', Value: invoiceDate },
 { $Type: 'UI.DataField', Value: totalAmount },
 { $Type: 'UI.DataField', Value: status },
 { $Type: 'UI.DataField', Value: riskScore },
 { $Type: 'UI.DataField', Value: paymentDueDate },
 { $Type: 'UI.DataField', Value: comments }
  ]
};

annotate cOE_DEMOSrv.Invoices with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: 'General Information', Target: '@UI.FieldGroup#Main' }
];

annotate cOE_DEMOSrv.Invoices with @UI.SelectionFields: [
  invoicesID
];

