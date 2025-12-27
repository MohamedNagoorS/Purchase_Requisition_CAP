/**
 * The custom logic attached to the Invoices entity to implement Smart Capabilities during CREATE and UPDATE events. This includes setting Auto-Due Date if paymentDueDate is empty, applying Risk & Approval Rule for totalAmount greater than 10,000, and Low Value Rule for totalAmount less than 500.
 * @Before(event = { "CREATE","UPDATE" }, entity = "cOE_DEMOSrv.Invoices")
 * @param {cds.Request} request - User information, tenant-specific CDS model, headers and query parameters
 */
module.exports = async function(request) {
  const { Invoices } = cds.entities;

  const invoiceData = request.data;

  // Set Auto-Due Date if paymentDueDate is empty
  if (!invoiceData.paymentDueDate) {
    const invoiceDate = invoiceData.invoiceDate || new Date();
    const autoDueDate = new Date(invoiceDate);
    autoDueDate.setDate(autoDueDate.getDate() + 30); // Assuming 30 days payment term
    invoiceData.paymentDueDate = autoDueDate.toISOString().split('T')[0]; // Format as YYYY-MM-DD
  }

  // Apply Risk & Approval Rule for totalAmount greater than 10,000
  if (invoiceData.totalAmount > 10000) {
    invoiceData.riskScore = 100; // High risk score
    invoiceData.status = 'Approval Required';
  }

  // Apply Low Value Rule for totalAmount less than 500
  if (invoiceData.totalAmount < 500) {
    invoiceData.riskScore = 10; // Low risk score
    invoiceData.status = 'Auto Approved';
  }
};
