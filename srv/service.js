const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    // 1. Get the real entity definitions
    // This file handles multiple services (cOE_DEMOSrv and ProcurementService)
    // We destructure possible entities. Some will be undefined depending on the service.
    const { Invoices, InvoiceItems, Requisitions, RequisitionItems, CatalogItems } = this.entities;

    // =================================================================
    // Logic for cOE_DEMOSrv (Invoices)
    // =================================================================
    if (Invoices) {

        // 1. DEFAULT VALUES (Date & Status)
        // We listen to the 'drafts' entity to catch the event
        this.before('NEW', Invoices.drafts, async (req) => {
            console.log('--> NEW Draft Created! Setting Defaults...');

            const today = new Date();
            const nextMonth = new Date(today);
            nextMonth.setDate(today.getDate() + 30);

            req.data.paymentDueDate = nextMonth.toISOString().slice(0, 10);
            req.data.status_code = 'N';
            req.data.currency = 'INR';
        });

        // 2. AUTO-CALCULATION (Total Amount)
        // We update the total amount whenever an item is added, changed, or removed
        this.after(['CREATE', 'UPDATE', 'DELETE'], InvoiceItems.drafts, async (item, req) => {
            console.log('--> Item Draft Updated. Calculating Header...');

            // 1. Get the Parent ID (Invoice ID)
            // The item might be the request data itself or the result 'item'
            let headerID = req.data.parent_ID || item.parent_ID;

            // Fallback: If ID is missing, try to find it from the item in DB (if it exists)
            if (!headerID && req.data.ID) {
                const itemInDb = await cds.tx(req).run(
                    SELECT.one.from(InvoiceItems.drafts).where({ ID: req.data.ID })
                );
                if (itemInDb) headerID = itemInDb.parent_ID;
            }

            if (headerID) {
                // 2. Sum up all items (from the drafts view) for this specific parent
                const allItems = await cds.tx(req).run(
                    SELECT.from(InvoiceItems.drafts).where({ parent_ID: headerID })
                );

                let newTotal = 0;
                if (allItems) {
                    allItems.forEach(i => {
                        newTotal += (Number(i.quantity) || 0) * (Number(i.price) || 0);
                    });
                }

                console.log(`   --> New Total: ${newTotal} for Invoice ${headerID}`);

                // 3. Update the Parent Header Draft
                // FIX: We MUST target 'Invoices.drafts' because the user is editing a draft.
                // Updating the active 'Invoices' entity will not show up in the draft UI.
                await cds.tx(req).run(
                    UPDATE(Invoices.drafts).set({ totalAmount: newTotal }).where({ ID: headerID })
                );
            }
        });
    }

    // =================================================================
    // Logic for ProcurementService (Requisitions)
    // =================================================================
    if (Requisitions) {

        // Action: createManualPR
        this.on('createManualPR', async (req) => {
            const { MaterialName, Quantity, Price, CostCenterID } = req.data;

            const total = (Number(Quantity) || 0) * (Number(Price) || 0);
            const headerID = cds.utils.uuid();

            // 1. Insert Header
            await INSERT.into(Requisitions).entries({
                ID: headerID,
                Description: `Manual PR: ${MaterialName}`,
                TotalPrice: total
            });

            // 2. Insert Item
            await INSERT.into(RequisitionItems).entries({
                ID: cds.utils.uuid(),
                parent_ID: headerID,
                MaterialDescription: MaterialName,
                Quantity: Quantity,
                Price: Price,
                CostCenter: CostCenterID
            });

            // 3. Return the created header
            return SELECT.one.from(Requisitions).where({ ID: headerID });
        });

        // Action: createCatalogPR (Bound to CatalogItems)
        this.on('createCatalogPR', 'CatalogItems', async (req) => {
            const { CostCenterID } = req.data;
            const tx = cds.tx(req); // Get the current transaction

            // 1. Get the specific item for this request
            // In a batch/changeset, this action is called once per selected item.
            // req.query targets the specific item instance.
            const items = await tx.run(req.query);

            if (!items || items.length === 0) {
                // This might happen if the item doesn't exist anymore
                return req.error(404, "Catalog item not found.");
            }
            const item = items[0];

            // 2. Check for an existing Header ID in the current transaction state
            // We use a custom property on the transaction object to share state across the batch
            const BATCH_KEY = 'ACTIVE_REQUISITION_ID';
            let headerID = tx[BATCH_KEY];

            if (!headerID) {
                // First item in the batch -> Create the Header
                headerID = cds.utils.uuid();
                tx[BATCH_KEY] = headerID; // Store for valid subsequent calls in this batch

                console.log(`--> Creating New Batch Requisition: ${headerID}`);

                await INSERT.into(Requisitions).entries({
                    ID: headerID,
                    Description: `Catalog PR (Initializing...)`,
                    TotalPrice: 0,
                    createdAt: new Date().toISOString() // Optional if auto-managed
                });
            } else {
                console.log(`--> Adding to Existing Batch Requisition: ${headerID}`);
            }

            // 3. Add the Item to the Requisition
            await INSERT.into(RequisitionItems).entries({
                ID: cds.utils.uuid(),
                parent_ID: headerID,
                MaterialDescription: item.ItemName,
                Price: item.Price,
                Quantity: 1, // Default quantity
                CostCenter: CostCenterID
            });

            // 4. Update Header Totals (Recalculate from DB to be safe)
            // Since we are in the same transaction, we can see the inserted items
            const allItems = await tx.run(
                SELECT.from(RequisitionItems).columns('Price', 'Quantity').where({ parent_ID: headerID })
            );

            let total = 0;
            if (allItems) {
                allItems.forEach(i => total += (Number(i.Price) || 0) * (Number(i.Quantity) || 0));
            }

            await UPDATE(Requisitions).set({
                TotalPrice: total,
                Description: `Catalog PR with ${allItems.length} items`
            }).where({ ID: headerID });

            // 5. Return the updated header
            return SELECT.one.from(Requisitions).where({ ID: headerID });
        });
    }
});