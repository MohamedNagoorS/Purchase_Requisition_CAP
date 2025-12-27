const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    // 1. Get the real entity definitions
    const { Invoices, InvoiceItems } = this.entities;

    // =================================================================
    // 1. DEFAULT VALUES (Date & Status)
    // =================================================================
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

    // =================================================================
    // 2. AUTO-CALCULATION (Total Amount)
    // =================================================================
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
});