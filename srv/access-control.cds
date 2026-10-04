using { BookingService } from './booking-service';

// Roles (users and passwords are mocked in package.json):
//
//   Role      Hotels / Rooms   Bookings
//   Admin     full CRUD        full CRUD
//   Manager   read             read all, update (no create, no delete)
//   Customer  read             create, read only their own

annotate BookingService with @(requires: 'authenticated-user');

annotate BookingService.Hotels with @(restrict: [
    { grant: 'READ', to: 'authenticated-user' },
    { grant: '*',    to: 'Admin' }
]);

annotate BookingService.Rooms with @(restrict: [
    { grant: 'READ', to: 'authenticated-user' },
    { grant: '*',    to: 'Admin' }
]);

annotate BookingService.Bookings with @(restrict: [
    { grant: '*',                to: 'Admin' },
    { grant: ['READ', 'UPDATE'], to: 'Manager' },
    { grant: 'CREATE',           to: 'Customer' },
    { grant: 'READ',             to: 'Customer', where: 'createdBy = $user' }
]);
