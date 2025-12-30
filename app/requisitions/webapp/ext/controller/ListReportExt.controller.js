sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend("coe.demo.requisitions.ext.controller.ListReportExt", {
        onBrowseCatalog: function (oEvent) {
            // Navigate to the Catalog route
            // Using the Fiori Elements Extension API if available, or fallback to standard router
            var oExtensionAPI = this.base.getExtensionAPI();
            if (oExtensionAPI && oExtensionAPI.routing) {
                oExtensionAPI.routing.navigateToRoute("CatalogList");
            } else {
                // Fallback
                this.base.getAppComponent().getRouter().navTo("CatalogList");
            }
        }
    });
});
