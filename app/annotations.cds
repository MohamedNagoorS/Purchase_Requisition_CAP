using { cOE_DEMOSrv } from '../srv/service.cds';

// ----------------------------------------------------------------
// 1. LIST VIEW
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: invoicesID, Label: 'ID' },
    { $Type: 'UI.DataField', Value: invoiceNumber, Label: 'Invoice No' },
    { $Type: 'UI.DataField', Value: vendorName, Label: 'Vendor' },
    { $Type: 'UI.DataField', Value: totalAmount, Label: 'Total' },
    { $Type: 'UI.DataField', Value: status_code, Label: 'Status' },
    { $Type: 'UI.DataField', Value: paymentDueDate, Label: 'Due Date' }
];

annotate cOE_DEMOSrv.Invoices with @UI.SelectionFields: [
    invoicesID, vendorName, status_code
];

// ----------------------------------------------------------------
// 2. INVOICE DETAIL PAGE
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with @(
    // A. TITLE
    UI.HeaderInfo : {
        TypeName : 'Invoice',
        TypeNamePlural : 'Invoices',
        Title : { Value : invoiceNumber },
        Description : { Value : vendorName }
    },

    // B. FORCE EMPTY HEADER SECTIONS (The Fix)
    // We must explicitly say "Empty Array" [] to stop auto-generation.
    UI.HeaderFacets : [], 
    UI.Identification : [],

    // C. BODY SECTIONS
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            ID : 'GeneralSection',
            Label : 'General Information',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'General Data',
                    Target : '@UI.FieldGroup#Main'
                }
            ]
        },
        { 
            $Type : 'UI.ReferenceFacet', 
            ID : 'ItemsSection', 
            Label : 'Invoice Items', 
            Target : 'Items/@UI.LineItem' 
        }
    ],

    // D. FORM FIELDS
    UI.FieldGroup #Main : {
        Data : [
            { Value: invoicesID, Label: 'ID' },
            { Value: invoiceNumber, Label: 'Invoice Number' }, 
            { Value: vendorName, Label: 'Vendor Name' },
            { Value: invoiceDate, Label: 'Invoice Date' },
            { Value: totalAmount, Label: 'Total Amount' }, 
            { Value: status_code, Label: 'Status' },
            { Value: paymentDueDate, Label: 'Payment Due Date' }
        ]
    }
);

// ----------------------------------------------------------------
// 3. ITEMS TABLE
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.InvoiceItems with @UI.LineItem: [
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Quantity' },
    { Value: price, Label: 'Unit Price' }
];

annotate cOE_DEMOSrv.InvoiceItems with @(
    UI.HeaderInfo : { TypeName : 'Item', TypeNamePlural : 'Items', Title : { Value : description } },
    UI.Facets : [ { $Type : 'UI.ReferenceFacet', Label : 'Item Details', Target : '@UI.FieldGroup#ItemMain' } ],
    UI.FieldGroup #ItemMain : {
        Data : [
            { Value : description, Label : 'Description' },
            { Value : quantity,    Label : 'Quantity' },
            { Value : price,       Label : 'Unit Price' }
        ]
    }
);

// ----------------------------------------------------------------
// 4. DROPDOWNS & LOGIC
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.Invoices with {
    status_code @( Common : {
        Text : status.name, TextArrangement : #TextOnly,
        ValueListWithFixedValues : true,
        ValueList : {
            $Type : 'Common.ValueListType', CollectionPath : 'Statuses',
            Parameters : [
                { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : status_code, ValueListProperty : 'code' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
            ]
        }
    })
};

annotate cOE_DEMOSrv.Invoices with @(
    Common.SideEffects : { SourceEntities : [ Items ], TargetProperties : [ totalAmount ] }
);