# StayEasy — Hotel Booking System

Presenting a booking application for a small hotel chain. Guests use it to browse hotels and rooms and to book stays for specific dates. Hotel managers see and manage all bookings across the chain, and administrators maintain the hotel and room catalogue.

The app prevents double-booking, rejects invalid dates, calculates the price automatically, and shows the total in the guest's own currency using live exchange rates.

Built with the SAP Cloud Application Programming Model (CAP, Node.js) and an SAP Fiori elements List Report / Object Page.

## Run it

```sh
npm install
npx cds watch
```

| What | URL |
|---|---|
| Fiori app | <http://localhost:4004/bookingsmanagement/index.html> (add `?sap-language=EN` for English) |
| Same app in a Fiori launchpad | <http://localhost:4004/bookingsmanagement/test/flp.html#app-preview> |
| OData service | <http://localhost:4004/odata/v4/booking> |

The database is SQLite in memory: every restart resets it to the sample data in `db/data/`.

## Users

The browser asks for a login. To switch users, use a private window.

| User | Password | Role |
|---|---|---|
| `admin` | `admin` | Admin |
| `manager` | `manager` | Manager |
| `alice` | `alice` | Customer |
| `bob` | `bob` | Customer |

| Role | Hotels / Rooms | Bookings |
|---|---|---|
| Admin | full CRUD | full CRUD |
| Manager | read | read all, update; no create, no delete |
| Customer | read | create; read only their own |

alice owns BK-2026-0001 to 0003, bob owns BK-2026-0004 to 0006 and 0014.

## Business rules

When a booking is saved (`srv/booking-service.js`):

- **Validation:** check-in not in the past, check-out after check-in, guests within the room's capacity, and **no overlapping booking on the same room** (cancelled bookings don't count). Errors are attached to the field, so Fiori highlights it.
- **Computation:** nights, total price (nights × price per night), the hotel's currency, booking number `BK-<year>-<nnnn>`, status *New*.
- **Exchange rate:** the total is converted into the guest's currency with live rates from the Central Bank of Uzbekistan (`srv/exchange-rates.js`). If the rate service is unavailable, the booking is still saved, with a warning.

## Demo script

1. **As alice** (Customer): the list shows only her 3 bookings. Create a booking for Registan Plaza, room 11, 21–22 Nov 2026: Save is refused because the hotel is fully booked from 20 to 23 Nov.
2. Change the dates to 1–3 Dec 2026, pick a guest currency such as EUR, and save: nights, total, booking number and the converted total are filled in.
3. **As bob** (Customer): alice's bookings don't appear.
4. **As manager**: all bookings are visible. Edit a *New* booking, set it to *Confirmed* and save. There is no Delete button.
5. Edit a booking and set more guests than the room fits: the Guests field is highlighted with the error.
6. **As admin**: everything is allowed, including Delete.

## API tests

`test/crud.http` holds requests for every entity, the business rules, roles and the demo story. Open it in VS Code with the REST Client extension, start `cds watch`, and click *Send Request* above each request. The requests in a section are meant to run top to bottom.

## Project structure

| Folder | Content |
|---|---|
| `db/` | Data model (`schema.cds`): Hotels → Rooms (composition) → Bookings (association), BookingStatus code list; sample data in `db/data/` |
| `srv/` | `booking-service.cds` (OData service, draft), `access-control.cds` (roles), `booking-service.js` (business logic), `exchange-rates.js` (external API) |
| `app/bookings-management/` | Fiori elements app; the UI is defined in `annotations.cds` |
| `test/` | `crud.http` API requests |
