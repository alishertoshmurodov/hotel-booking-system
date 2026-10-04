// Exchange rates from the Central Bank of Uzbekistan (free, no API key).
// CBU publishes how many UZS one unit of each currency costs, so any pair
// is converted through UZS: from -> UZS -> to.
const CBU_URL = 'https://cbu.uz/uz/arkhiv-kursov-valyut/json/'

export async function getExchangeRate(from, to) {
  if (from === to) return 1

  const res = await fetch(CBU_URL, { signal: AbortSignal.timeout(5000) })
  if (!res.ok) throw new Error(`exchange rate service responded with ${res.status}`)

  const uzsPer = { UZS: 1 }
  for (const { Ccy, Rate, Nominal } of await res.json())
    uzsPer[Ccy] = Number(Rate) / Number(Nominal)

  for (const currency of [from, to])
    if (!uzsPer[currency]) throw new Error(`no exchange rate for ${currency}`)

  return uzsPer[from] / uzsPer[to]
}
