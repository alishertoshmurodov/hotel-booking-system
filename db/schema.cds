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
    @mandatory guestName : String;
    guestEmail : String;
    @mandatory checkInDate : Date;
    @mandatory checkOutDate : Date;
    @mandatory guestCount : Integer;
    nights : Integer;
    totalAmount : Decimal(10,2);
    currency : Currency;
    guestCurrency : Currency;
    exchangeRate : Decimal(15,8);
    totalAmountInGuestCurrency : Decimal(10,2);
    @mandatory room : Association to Rooms @assert.target;
    status : Association to BookingStatus @assert.target;
}

entity BookingStatus: sap.common.CodeList {
    key code : String(10);
    criticality : Integer;
}