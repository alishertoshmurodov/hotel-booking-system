sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"bookingsmanagement/test/integration/pages/BookingsList.gen",
	"bookingsmanagement/test/integration/pages/BookingsObjectPage.gen"
], function (JourneyRunner, BookingsListGenerated, BookingsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('bookingsmanagement') + '/test/flp.html#app-preview',
        pages: {
			onTheBookingsListGenerated: BookingsListGenerated,
			onTheBookingsObjectPageGenerated: BookingsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

