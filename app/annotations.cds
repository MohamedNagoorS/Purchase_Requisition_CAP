using { cOE_DEMOSrv } from '../srv/service.cds';

// ----------------------------------------------------------------
// 1. Header & Title Configuration
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.HeaderInfo: { 
    TypeName: 'Invoice', 
    TypeNamePlural: 'Invoices', 
    Title: { Value: invoicesID },
    Description: { Value: vendorName }
};

// Hide the technical ID and show the human-readable ID instead
annotate cOE_DEMOSrv.Invoices with {
    ID @UI.Hidden @Common.Text: { $value: invoicesID, ![@UI.TextArrangement]: #TextOnly }
};

annotate cOE_DEMOSrv.Invoices with @UI.Identification: [{ Value: invoicesID }];

// ----------------------------------------------------------------
// 2. Labels (Nice Names for Columns)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with {
    invoicesID @title: 'ID' @HTML5.CssDefaults: { width: '1rem' }; // Keep ID small
    
    invoiceNumber @title: 'Invoice Number' @HTML5.CssDefaults: { width: '8rem' }; // Limit Invoice No width
    
    vendorName @title: 'Vendor Name' ; // Limit Vendor Name width
    
    invoiceDate @title: 'Invoice Date';
    totalAmount @title: 'Total Amount';
    
    status_code @title: 'Status' @HTML5.CssDefaults: { width: '6rem' }; // Force Status to be visible
    
    riskScore @title: 'Risk Score';
    paymentDueDate @title: 'Payment Due Date';
    comments @title: 'Comments'
};

annotate cOE_DEMOSrv.Invoices with {
    totalAmount @Measures.ISOCurrency: currency
};

// ----------------------------------------------------------------
// 3. The List View (Columns)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: invoicesID },
    { $Type: 'UI.DataField', Value: invoiceNumber },
    { $Type: 'UI.DataField', Value: vendorName },
    { $Type: 'UI.DataField', Value: totalAmount },
    // CRITICAL FIX: Use 'status_code' here
    { $Type: 'UI.DataField', Value: status_code }, 
    { $Type: 'UI.DataField', Value: paymentDueDate },
    { $Type: 'UI.DataField', Value: riskScore }
];

// ----------------------------------------------------------------
// 4. The Detail Page (Form Fields)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.FieldGroup #Main: {
    $Type: 'UI.FieldGroupType', Data: [
        { $Type: 'UI.DataField', Value: invoicesID },
        { $Type: 'UI.DataField', Value: invoiceNumber },
        { $Type: 'UI.DataField', Value: vendorName },
        { $Type: 'UI.DataField', Value: invoiceDate },
        { $Type: 'UI.DataField', Value: totalAmount },
        // CRITICAL FIX: Use 'status_code' here too
        { $Type: 'UI.DataField', Value: status_code },
        { $Type: 'UI.DataField', Value: riskScore },
        { $Type: 'UI.DataField', Value: paymentDueDate },
        { $Type: 'UI.DataField', Value: comments }
    ]
};

// ----------------------------------------------------------------
// 5. Page Layout (Facets)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.Facets: [
    { 
        $Type: 'UI.ReferenceFacet', 
        ID: 'Main', 
        Label: 'General Information', 
        Target: '@UI.FieldGroup#Main' 
    },
    { 
        $Type: 'UI.ReferenceFacet', 
        ID: 'InvoiceItems', 
        Label: 'Invoice Items', 
        Target: 'Items/@UI.LineItem' 
    }
];

// ----------------------------------------------------------------
// 6. Filter Bar
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.SelectionFields: [
    invoicesID,
    vendorName,
    status_code // CRITICAL FIX: Filter by the code column
];

// ----------------------------------------------------------------
// 7. DROPDOWN CONFIGURATION (The Magic Part)
// ----------------------------------------------------------------

// We attach the Value Help specifically to 'status_code'
// The Value Help must be attached to the REAL column (status_code)
annotate cOE_DEMOSrv.Invoices with {
    status_code @( 
        Common : {
            Text : status.name, // Show the text "New" from the association
            TextArrangement : #TextOnly, 
            ValueListWithFixedValues : true,
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Statuses',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : status_code, ValueListProperty : 'code' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            }
        }
    )
};

// ----------------------------------------------------------------
// 8. Line Items Table (Products)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.InvoiceItems with @(
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : description, Label : 'Description' },
        { $Type : 'UI.DataField', Value : quantity, Label : 'Quantity' },
        { $Type : 'UI.DataField', Value : price, Label : 'Unit Price' }
    ]
);