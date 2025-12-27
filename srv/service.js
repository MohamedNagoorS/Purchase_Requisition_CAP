const cds = require('@sap/cds');

console.log("--------------------------------------------------");
console.log("✅ JS FILE LOADED! Logic Active.");
console.log("--------------------------------------------------");

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
    this.after(['CREATE', 'UPDATE', 'DELETE'], InvoiceItems.drafts, async (item, req) => {
        console.log('--> Item Draft Updated. Calculating Header...');

        // 1. Get the Parent ID (Invoice ID)
        let headerID = req.data.parent_ID || item.parent_ID;

        // Fallback: If ID is missing, check the DB
        if (!headerID) {
            const itemInDb = await cds.tx(req).run(
                SELECT.one.from(InvoiceItems.drafts).where({ ID: req.data.ID })
            );
            if (itemInDb) headerID = itemInDb.parent_ID;
        }

        if (headerID) {
            // 2. Sum up all items (from the drafts view)
            const allItems = await cds.tx(req).run(
                SELECT.from(InvoiceItems.drafts).where({ parent_ID: headerID })
            );

            let newTotal = 0;
            allItems.forEach(i => {
                newTotal += (i.quantity || 0) * (i.price || 0);
            });

            console.log(`   --> New Total: ${newTotal} for Invoice ${headerID}`);

            // 3. Update the Header
            // CRITICAL FIX: We Update 'Invoices' (Not Invoices.drafts)
            // The system knows 'headerID' is a draft and will update the correct table automatically.
            await cds.tx(req).run(
                UPDATE(Invoices).set({ totalAmount: newTotal }).where({ ID: headerID })
            );
        }
    });
});