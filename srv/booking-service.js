import cds from '@sap/cds'
import { getExchangeRate } from './exchange-rates.js'

const DAY = 24 * 60 * 60 * 1000
const today = () => new Date().toLocaleDateString('en-CA') // YYYY-MM-DD in the server's time zone

export default class BookingService extends cds.ApplicationService {
  init() {
    const { Bookings, Rooms } = this.entities

    // A PATCH sends only the changed fields, Fiori's Save sends the whole booking.
    // Either way, merge over the stored booking and compare with it to see what really changed.
    const loadChange = async req => {
      const stored = req.event === 'UPDATE' ? await SELECT.one.from(req.subject) : null
      const booking = req.event === 'CREATE' ? req.data : stored && { ...stored, ...req.data }
      const changes = (...fields) => !stored || fields.some(f => f in req.data && req.data[f] !== stored[f])
      return { booking, changes }
    }


    // 1. Validation: dates, capacity, no double-booking
    this.before(['CREATE', 'UPDATE'], Bookings, async req => {
      const { booking, changes } = await loadChange(req)
      if (!booking?.room_ID) return // missing fields are reported by @mandatory

      const { ID, room_ID, checkInDate, checkOutDate, guestCount, status_code } = booking

      // Only check dates when they change, so old bookings can still be updated
      if (changes('checkInDate', 'checkOutDate')) {
        if (checkInDate < today())
          req.error(400, 'Check-in date cannot be in the past', 'checkInDate')
        if (checkOutDate <= checkInDate)
          req.error(400, 'Check-out date must be after the check-in date', 'checkOutDate')
      }

      const room = await SELECT.one.from(Rooms, room_ID).columns('number', 'capacity')
      if (!room) return // unknown room is reported by @assert.target

      if (changes('guestCount', 'room_ID') && guestCount > room.capacity)
        req.error(400, `Room ${room.number} fits at most ${room.capacity} guest${room.capacity === 1 ? '' : 's'}`, 'guestCount')

      if (req.errors) return
      if (status_code === 'CANCELLED') return
      if (!changes('checkInDate', 'checkOutDate', 'room_ID', 'status_code')) return

      // Two stays overlap when each one starts before the other ends.
      // Cancelled bookings don't block the room; the booking itself is excluded on UPDATE.
      const clash = await SELECT.one.from(Bookings)
        .columns('bookingNo', 'checkInDate', 'checkOutDate')
        .where `room_ID = ${room_ID}
          and checkInDate < ${checkOutDate} and checkOutDate > ${checkInDate}
          and (status_code is null or status_code != 'CANCELLED')
          and ID != ${ID}`
      if (clash) {
        // Customers may not see other customers' bookings, so only staff get the booking number
        const ref = req.user.is('Customer') ? '' : ` (${clash.bookingNo})`
        req.error(400, `Room ${room.number} is already booked from ${clash.checkInDate} to ${clash.checkOutDate}${ref}`, 'checkInDate')
      }
    })


    // 2. Computation: nights, price, currency, booking number, default status
    this.before(['CREATE', 'UPDATE'], Bookings, async req => {
      const { booking, changes } = await loadChange(req)
      if (!booking?.room_ID) return
      if (!changes('checkInDate', 'checkOutDate', 'room_ID', 'guestCurrency_code')) return

      const room = await SELECT.one.from(Rooms, booking.room_ID)
        .columns('pricePerNight', 'hotel.currency_code as currency_code')
      if (!room) return

      const nights = Math.round((Date.parse(booking.checkOutDate) - Date.parse(booking.checkInDate)) / DAY)
      req.data.nights = nights
      req.data.totalAmount = Math.round(nights * room.pricePerNight * 100) / 100
      req.data.currency_code = room.currency_code

      if (req.event === 'CREATE') {
        req.data.bookingNo = await nextBookingNo()
        req.data.status_code ??= 'NEW'
        req.data.guestCurrency_code ??= room.currency_code
      }

      // 3. External API: convert the total into the guest's currency
      const guestCurrency = req.data.guestCurrency_code ?? booking.guestCurrency_code ?? room.currency_code
      try {
        const rate = await getExchangeRate(room.currency_code, guestCurrency)
        req.data.exchangeRate = Math.round(rate * 1e8) / 1e8
        req.data.totalAmountInGuestCurrency = Math.round(req.data.totalAmount * rate * 100) / 100
      } catch (error) {
        // Don't block the booking: save it without the conversion and tell the user
        req.data.exchangeRate = null
        req.data.totalAmountInGuestCurrency = null
        req.warn(`Total in ${guestCurrency} is not available: ${error.message}`)
      }
    })

    // 4. Virtual fields: hide the Edit and Delete buttons for roles that can't use them
    this.after('READ', Bookings, (result, req) => {
      for (const booking of [].concat(result ?? [])) {
        if (typeof booking !== 'object') continue // e.g. a plain $count
        booking.hideEdit = !req.user.is('Admin') && !req.user.is('Manager')
        booking.hideDelete = !req.user.is('Admin')
      }
    })

    const nextBookingNo = async () => {
      const prefix = `BK-${new Date().getFullYear()}-`
      const last = await SELECT.one.from(Bookings).columns('max(bookingNo) as no')
        .where({ bookingNo: { like: prefix + '%' } })
      const seq = last?.no ? Number(last.no.slice(prefix.length)) + 1 : 1
      return prefix + String(seq).padStart(4, '0')
    }

    return super.init()
  }
}
