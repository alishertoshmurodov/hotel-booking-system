using BookingService as service from '../../srv/booking-service';

// Field labels, currencies and how IDs are shown
annotate service.Bookings with {
    bookingNo                  @title: 'Booking No.';
    guestName                  @title: 'Guest';
    guestEmail                 @title: 'Email';
    checkInDate                @title: 'Check-in';
    checkOutDate               @title: 'Check-out';
    guestCount                 @title: 'Guests';
    nights                     @title: 'Nights';
    totalAmount                @title: 'Total'                  @Measures.ISOCurrency: currency_code;
    currency                   @title: 'Hotel Currency';
    guestCurrency              @title: 'Guest Currency';
    exchangeRate               @title: 'Exchange Rate';
    totalAmountInGuestCurrency @title: 'Total (Guest Currency)' @Measures.ISOCurrency: guestCurrency_code;
    hotelName                  @title: 'Hotel';

    // Show the status name instead of its code, as a dropdown
    status @title: 'Status'
           @Common.Text: status.name
           @Common.TextArrangement: #TextOnly
           @Common.ValueListWithFixedValues;

    // Show the room number instead of its UUID, with a value help listing the rooms
    room @title: 'Room'
         @Common.Text: room.number
         @Common.TextArrangement: #TextOnly
         @Common.ValueList: {
             $Type         : 'Common.ValueListType',
             CollectionPath: 'Rooms',
             Parameters    : [
                 { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: room_ID, ValueListProperty: 'ID' },
                 { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'hotelName' },
                 { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'type' },
                 { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'capacity' },
                 { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'pricePerNight' }
             ]
         };
}

annotate service.Rooms with {
    ID            @title: 'Room' @Common.Text: number @Common.TextArrangement: #TextOnly;
    number        @title: 'Room No.';
    type          @title: 'Type';
    capacity      @title: 'Capacity';
    pricePerNight @title: 'Price per Night';
    hotelName     @title: 'Hotel';
}


// List Report: filter bar and table
annotate service.Bookings with @(
    UI.SelectionFields: [
        status_code,
        checkInDate,
        room_ID,
        guestName
    ],

    // #High columns stay visible on narrow screens, the others move into "Show Details"
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: bookingNo,    ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: guestName,    ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: hotelName },
        { $Type: 'UI.DataField', Value: room_ID },
        { $Type: 'UI.DataField', Value: checkInDate,  ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: checkOutDate, ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: guestCount },
        { $Type: 'UI.DataField', Value: totalAmount },
        { $Type: 'UI.DataField', Value: status_code,  Criticality: status.criticality, ![@UI.Importance]: #High }
    ]
);


// Object Page: header and sections
annotate service.Bookings with @(
    UI.HeaderInfo: {
        TypeName      : 'Booking',
        TypeNamePlural: 'Bookings',
        Title         : { Value: bookingNo },
        Description   : { Value: guestName }
    },

    UI.DataPoint #status: {
        Value      : status_code,
        Title      : 'Status',
        Criticality: status.criticality
    },

    UI.HeaderFacets: [
        { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#status' }
    ],

    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', ID: 'Stay',  Label: 'Stay',  Target: '@UI.FieldGroup#Stay' },
        { $Type: 'UI.ReferenceFacet', ID: 'Guest', Label: 'Guest', Target: '@UI.FieldGroup#Guest' },
        { $Type: 'UI.ReferenceFacet', ID: 'Price', Label: 'Price', Target: '@UI.FieldGroup#Price' }
    ],

    UI.FieldGroup #Stay: { Data: [
        { Value: room_ID },
        { Value: hotelName },
        { Value: checkInDate },
        { Value: checkOutDate },
        { Value: nights },
        { Value: guestCount },
        { Value: status_code }
    ]},

    UI.FieldGroup #Guest: { Data: [
        { Value: guestName },
        { Value: guestEmail }
    ]},

    UI.FieldGroup #Price: { Data: [
        { Value: totalAmount },
        { Value: guestCurrency_code },
        { Value: exchangeRate },
        { Value: totalAmountInGuestCurrency }
    ]}
);
