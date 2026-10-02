using { Currency, managed, cuid, sap } from '@sap/cds/common';
namespace hotel.booking;

entity Hotels: cuid, managed {
    name : String;
    city : String;
    country : String;
    currency : Currency;
    stars : Integer;
    isActive : Boolean;
    rooms : Composition of many Rooms on rooms.hotel = $self;
}

entity Rooms: cuid {
    number : String;
    type : String enum { Single; Double; Suite };
    capacity : Integer;
    pricePerNight : Decimal(10,2);
    hotel : Association to Hotels;
    bookings : Association to many Bookings on bookings.room = $self;
}

entity Bookings: cuid, managed {
    bookingNo : String;
    guestName : String;
    guestEmail : String;
    checkInDate : Date;
    checkOutDate : Date;
    guestCount : Integer;
    nights : Integer;
    totalAmount : Decimal(10,2);
    currency : Currency;
    guestCurrency : Currency;
    exchangeRate : Decimal(10,4);
    totalAmountInGuestCurrency : Decimal(10,2);
    room : Association to Rooms;
    status : Association to BookingStatus;
}

entity BookingStatus: sap.common.CodeList {
    key code : String(10);
    criticality : Integer;
}