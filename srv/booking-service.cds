using { hotel.booking as db } from '../db/schema';

service BookingService {
    entity Hotels as projection on db.Hotels;
    entity Rooms as projection on db.Rooms {
        *,
        hotel.name as hotelName // shown in the room value help
    };
    @odata.draft.enabled
    entity Bookings as projection on db.Bookings {
        *,
        room.hotel.name as hotelName // follows the selected room
    };
    @readonly entity BookingStatus as projection on db.BookingStatus;
}

annotate BookingService.Bookings with {
    bookingNo                  @readonly;
    nights                     @readonly;
    totalAmount                @readonly;
    currency                   @readonly;
    exchangeRate               @readonly;
    totalAmountInGuestCurrency @readonly;
    hotelName                  @readonly;
}
