using { hotel.booking as db } from '../db/schema';

service BookingService {
    entity Hotels as projection on db.Hotels;
    entity Rooms as projection on db.Rooms;
    entity Bookings as projection on db.Bookings;
    @readonly entity BookingStatus as projection on db.BookingStatus;
}