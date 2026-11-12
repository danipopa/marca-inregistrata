export function productOffice(product) {
  if (/^(renew-)?ro-/.test(product.code || '')) return 'OSIM'
  if (/^(renew-)?eu-/.test(product.code || '')) return 'EUIPO'
  const office = String(product.office || product.region || '').trim().toUpperCase()
  if (['RO', 'OSIM'].includes(office)) return 'OSIM'
  if (['EU', 'EUIPO'].includes(office)) return 'EUIPO'
  return 'other'
}

export function supportsClassPricing(product) {
  return product.supports_class_pricing ?? !/^(monitoring|verification)-/.test(product.code || '')
}

export function defaultClassTotal(product, count, baseOverride) {
  const base = Number(baseOverride ?? product.baseLei ?? product.base_lei ?? product.base_price_lei ?? 0)
  if (!supportsClassPricing(product)) return base
  const classes = Math.max(1, Math.min(Math.trunc(Number(count)) || 1, 11))
  if (product.class_surcharges?.[classes] != null) return base + Number(product.class_surcharges[classes])
  // Compatibility with catalog responses from before editable class pricing.
  if (/^(renew-)?ro-/.test(product.code || '')) return base + (classes - 1) * 254
  if (/^(renew-)?eu-/.test(product.code || '')) return base + [0, 50, 200, 350, 500, 650, 800, 950, 1100, 1250, 1400][classes - 1]
  return base
}

export function productClassTotal(product, count) {
  const classes = Math.max(1, Math.min(Math.trunc(Number(count)) || 1, 11))
  const override = product.class_prices?.[classes]
  if (classes > 1 && supportsClassPricing(product) && Number.isInteger(override) && override >= 0) return override
  return defaultClassTotal(product, classes)
}

export function classPriceDraft(product) {
  return Object.fromEntries(Array.from({ length: 10 }, (_, index) => {
    const count = index + 2
    return [count, product.class_prices?.[count] ?? '']
  }))
}

export function serializeClassPrices(draft = {}) {
  const prices = {}
  for (const [count, value] of Object.entries(draft)) {
    if (value == null || String(value).trim() === '') continue
    if (!/^(?:[2-9]|10|11)$/.test(count) || !['number', 'string'].includes(typeof value) || !Number.isSafeInteger(Number(value)) || Number(value) < 0) {
      throw new Error('Prețurile pe clase trebuie să fie numere întregi pozitive sau zero.')
    }
    prices[count] = Number(value)
  }
  return prices
}
