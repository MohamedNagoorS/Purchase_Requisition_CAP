using { cOE_DEMOSrv } from '../srv/service.cds';
using { ProcurementService } from '../srv/service.cds';

// ================================================================
// SERVICE 1: cOE_DEMOSrv (INVOICES)
// ================================================================

// ----------------------------------------------------------------
// 1. LIST VIEW (Invoices)
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
    UI.HeaderInfo : {
        TypeName : 'Invoice',
        TypeNamePlural : 'Invoices',
        Title : { Value : invoiceNumber },
        Description : { Value : vendorName }
    },
    UI.HeaderFacets : [], // Using default object info
    UI.Identification : [],
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
    },
    Common.SideEffects : { 
        SourceEntities : [ Items ], 
        TargetProperties : [ totalAmount ] 
    }
);

// ----------------------------------------------------------------
// 3. DROPDOWNS (Invoices)
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

// ----------------------------------------------------------------
// 4. ITEMS TABLE (Invoices)
// ----------------------------------------------------------------
annotate cOE_DEMOSrv.InvoiceItems with @UI.LineItem: [
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Quantity' },
    { Value: price, Label: 'Unit Price' }
];

annotate cOE_DEMOSrv.InvoiceItems with @(
    UI.HeaderInfo : { TypeName : 'Item', TypeNamePlural : 'Items', Title : { Value : description } },
    UI.HeaderFacets : [],
    UI.Identification : [],
    UI.Facets : [ { $Type : 'UI.ReferenceFacet', Label : 'Item Details', Target : '@UI.FieldGroup#ItemMain' } ],
    UI.FieldGroup #ItemMain : {
        Data : [
            { Value : description, Label : 'Description' },
            { Value : quantity,    Label : 'Quantity' },
            { Value : price,       Label : 'Unit Price' }
        ]
    },
    Common.SideEffects : {
        TargetProperties : [ 'parent/totalAmount' ]
    }
);


// ================================================================
// SERVICE 2: ProcurementService (REQUISITIONS)
// ================================================================

// ----------------------------------------------------------------
// REQUISITIONS LIST VIEW
// ----------------------------------------------------------------
annotate ProcurementService.Requisitions with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Requisition ID' },
        { $Type: 'UI.DataField', Value: Description, Label: 'Description' },
        { $Type: 'UI.DataField', Value: TotalPrice, Label: 'Total Price' },
        { $Type: 'UI.DataField', Value: createdAt, Label: 'Created At' },
        // Custom Action: Create Manual PR (Unbound)
        { $Type: 'UI.DataFieldForAction', Action: 'ProcurementService.EntityContainer/createManualPR', Label: 'New Manual PR' }
    ],
    Capabilities.Insertable: false
);

annotate ProcurementService.Requisitions with @UI.SelectionFields: [
    ID, Description
];

// ----------------------------------------------------------------
// REQUISITIONS OBJECT PAGE
// ----------------------------------------------------------------
annotate ProcurementService.Requisitions with @(
    UI.HeaderInfo: {
        TypeName: 'Requisition',
        TypeNamePlural: 'Requisitions',
        Title: { Value: Description },
        Description: { Value: ID }
    },
    UI.Facets: [
        {
            $Type: 'UI.CollectionFacet',
            ID: 'GeneralSection',
            Label: 'General Information',
            Facets: [
                {
                    $Type: 'UI.ReferenceFacet',
                    Label: 'Details',
                    Target: '@UI.FieldGroup#Main'
                }
            ]
        },
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'ItemsSection',
            Label: 'Requisition Items',
            Target: 'items/@UI.LineItem'
        }
    ],
    UI.FieldGroup #Main: {
        Data: [
            { Value: ID, Label: 'ID' },
            { Value: Description, Label: 'Description' },
            { Value: TotalPrice, Label: 'Total Price' },
            { Value: createdAt, Label: 'Created At' }
        ]
    }
);

// ----------------------------------------------------------------
// REQUISITION ITEMS LIST
// ----------------------------------------------------------------
annotate ProcurementService.RequisitionItems with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: MaterialDescription, Label: 'Material' },
    { $Type: 'UI.DataField', Value: Quantity, Label: 'Quantity' },
    { $Type: 'UI.DataField', Value: Price, Label: 'Price' },
    { $Type: 'UI.DataField', Value: CostCenter, Label: 'Cost Center' }
];

// ----------------------------------------------------------------
// CATALOG ITEMS ANNOTATIONS
// ----------------------------------------------------------------
annotate ProcurementService.CatalogItems with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ItemName, Label: 'Item Name' },
        { $Type: 'UI.DataField', Value: Price, Label: 'Price' },
        { $Type: 'UI.DataField', Value: vendor.Name, Label: 'Vendor' },
        // Custom Action: Create Catalog PR (Bound)
        { $Type: 'UI.DataFieldForAction', Action: 'ProcurementService.createCatalogPR', Label: 'Create PR from Selected' }
    ]
);

// ----------------------------------------------------------------
// 5. ACTION PARAMETER DROPDOWNS (FIXED)
// ----------------------------------------------------------------

// A. Dropdown for "Create Manual PR" (Unbound Action)
// We annotate the parameters of the unbound action using the 'with' block
annotate ProcurementService.createManualPR with {
    CostCenterID @( Common : {
        ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'CostCenters',
            Parameters : [
                { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : CostCenterID, ValueListProperty : 'ID' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'Name' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'Department' }
            ]
        },
        Label : 'Select Cost Center'
    })
};

// B. Dropdown for "Create Catalog PR" (Bound Action)
// We annotate the Bound Action explicitly by targeting the Entity 'actions'
annotate ProcurementService.CatalogItems with actions {
    createCatalogPR(
        CostCenterID @( Common : {
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'CostCenters',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : CostCenterID, ValueListProperty : 'ID' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'Name' }
                ]
            },
            Label : 'Assign Cost Center'
        })
    )
};