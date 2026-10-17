import { ANALYTICS_CONSENT_VERSION, CONSENT_STORAGE_KEY, TRAFFIC_PATHS } from './traffic.js'

const PAGE_TITLES = {
  '/': 'Trademark services', '/order': 'Trademark order', '/checkout': 'Checkout',
  '/termeni-si-conditii': 'Terms and conditions', '/politica-de-confidentialitate': 'Privacy policy',
}
const DENIED = { analytics_storage: 'denied', ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' }
const COMMERCE_EVENTS = ['begin_checkout', 'order_submitted', 'purchase']
const CATALOG_CODE = /^(?:(?:renew-)?(?:ro|eu)-(?:word|monochrome|color|logo)|monitoring-brand|verification-brand)$/

export function analyticsProvider(config) {
  const provider = config.analyticsProvider || 'auto'
  if (provider === 'auto') return /^G-[A-Z0-9]+$/.test(config.googleAnalyticsId || '') ? 'google' : 'first-party'
  return ['google', 'first-party'].includes(provider) ? provider : 'none'
}

export function analyticsConsent(browser) {
  try {
    const consent = JSON.parse(browser.localStorage.getItem(CONSENT_STORAGE_KEY) || '{}')
    return consent.accepted === true && consent.version === ANALYTICS_CONSENT_VERSION
      && browser.navigator.doNotTrack !== '1' && browser.navigator.globalPrivacyControl !== true
  }
  catch { return false }
}

// Names come from the catalog code, never from customer-entered trademark names.
export function analyticsItems(items = []) {
  if (!Array.isArray(items)) return []
  return items.flatMap((item) => {
    if (!item || typeof item !== 'object') return []
    const code = item.productCode || item.product?.code || item.product_code
    const price = Number(item.total?.amount ?? item.total)
    const currency = item.total?.currency || item.currency || 'RON'
    if (!CATALOG_CODE.test(code || '') || !Number.isFinite(price) || price < 0 || !['RON', 'EUR'].includes(currency)) return []
    const category = code.startsWith('renew-') ? 'renewal' : code.startsWith('monitoring-') ? 'monitoring' : code.startsWith('verification-') ? 'verification' : 'registration'
    return [{ item_id: code, item_name: code, item_category: category, price, quantity: 1, currency }]
  })
}

function commerceParameters(items) {
  const safeItems = analyticsItems(items)
  if (!safeItems.length) return null
  const currencies = new Set(safeItems.map(item => item.currency))
  if (currencies.size !== 1) return null
  return { currency: safeItems[0].currency, value: Math.round(safeItems.reduce((sum, item) => sum + item.price, 0) * 100) / 100,
    items: safeItems.map(({ item_id, item_name, item_category, price, quantity }) => ({ item_id, item_name, item_category, price, quantity })) }
}

export function createGoogleAnalytics({ measurementId, debug = false, browser }) {
  const id = /^G-[A-Z0-9]+$/.test(measurementId || '') ? measurementId : ''
  let initialized = false
  let consentGranted = false
  let privateEventsPending = 0
  let suspended = false
  let previousPage = null
  let previousLocation = ''
  const purchases = new Set()
  const disableKey = `ga-disable-${id}`
  const enabled = () => Boolean(id) && analyticsConsent(browser)
  const publicPage = () => TRAFFIC_PATHS.includes(browser.location.pathname)
  const gtag = (...args) => browser.gtag(...args)
  const collectionDisabled = () => suspended || !enabled() || (!publicPage() && !(browser.location.pathname === '/account' && privateEventsPending > 0))

  function pageParameters(path) {
    return {
      page_location: `${browser.location.origin}${path}`,
      page_title: PAGE_TITLES[path],
      page_referrer: previousLocation || externalReferrer(),
    }
  }

  function externalReferrer() {
    try {
      const url = new URL(browser.document.referrer)
      return url.origin !== browser.location.origin && ['https:', 'http:'].includes(url.protocol) ? url.origin : ''
    }
    catch { return '' }
  }

  function clearCookies() {
    try {
      const names = browser.document.cookie.split(';').map(cookie => cookie.trim().split('=')[0]).filter(name => name === '_ga' || name.startsWith('_ga_'))
      const hostname = browser.location.hostname
      const domains = ['', ...hostname.split('.').map((_, index, parts) => parts.slice(index).join('.'))]
      for (const name of names) {
        for (const domain of domains) {
          browser.document.cookie = `${name}=; Max-Age=0; Path=/; SameSite=Lax${domain ? `; Domain=${domain}` : ''}`
        }
      }
    }
    catch { /* Cookies may be unavailable in restricted browser contexts. */ }
  }

  function syncConsent() {
    if (!id) return false
    suspended = false
    browser[disableKey] = collectionDisabled()
    if (!enabled()) {
      previousPage = null
      previousLocation = ''
      clearCookies()
      if (initialized && consentGranted) gtag('consent', 'update', DENIED)
      consentGranted = false
    }
    return enabled()
  }

  function initialize(path) {
    if (!enabled()) return false
    browser[disableKey] = false
    if (initialized) {
      if (!consentGranted) gtag('consent', 'update', { ...DENIED, analytics_storage: 'granted' })
      consentGranted = true
      return true
    }
    initialized = true
    browser.dataLayer = browser.dataLayer || []
    browser.gtag = browser.gtag || function () {
      browser.dataLayer.push(arguments)
    }
    gtag('consent', 'default', DENIED)
    gtag('consent', 'update', { ...DENIED, analytics_storage: 'granted' })
    consentGranted = true
    gtag('js', new Date())
    gtag('config', id, {
      ...pageParameters(path), send_page_view: false,
      allow_google_signals: false, allow_ad_personalization_signals: false,
      cookie_expires: 60 * 60 * 24 * 90,
      ...(debug ? { debug_mode: true } : {}),
    })
    const script = browser.document.createElement('script')
    script.async = true
    script.referrerPolicy = 'no-referrer'
    script.src = `https://www.googletagmanager.com/gtag/js?id=${id}`
    script.id = 'google-analytics-script'
    browser.document.head.appendChild(script)
    return true
  }

  function send(name, params, path) {
    if (!initialize(path)) return false
    const privateEvent = !publicPage()
    if (privateEvent) privateEventsPending += 1
    let completed = false
    gtag('set', pageParameters(path))
    gtag('event', name, { ...pageParameters(path), ...params, send_to: id,
      ...(debug ? { debug_mode: true } : {}),
      event_callback: () => {
        if (completed) return
        completed = true
        if (privateEvent) privateEventsPending -= 1
        params.event_callback?.()
        browser[disableKey] = collectionDisabled()
      },
      event_timeout: 2000,
    })
    return true
  }

  function pageView(path) {
    if (!syncConsent() || !TRAFFIC_PATHS.includes(path) || path !== browser.location.pathname) return false
    // Query strings and fragments are deliberately excluded, including from deduplication.
    if (previousPage === path) return false
    if (!send('page_view', {}, path)) return false
    previousPage = path
    previousLocation = `${browser.location.origin}${path}`
    return true
  }

  function event(name, input = {}) {
    if (!enabled()) return false
    const path = browser.location.pathname
    if (!publicPage() && !(path === '/account' && COMMERCE_EVENTS.includes(name))) return false
    const context = publicPage() ? path : '/checkout'
    if (name === 'generate_lead') return send(name, { form_name: 'contact' }, context)
    if (name === 'add_to_cart' || name === 'begin_checkout' || name === 'order_submitted') {
      const parameters = commerceParameters(input.items)
      return parameters ? send(name, parameters, context) : false
    }
    return false
  }

  function purchase(result) {
    if (!enabled() || result?.verified !== true || result.order?.status !== 'paid') return false
    const order = result.order
    if (!/^\d+$/.test(String(order.id))) return false
    const transactionId = `order-${order.id}`
    const key = `ga4-purchase-${id}-${transactionId}`
    try {
      if (purchases.has(transactionId) || browser.localStorage.getItem(key)) return false
    }
    catch { if (purchases.has(transactionId)) return false }
    const parameters = commerceParameters([order])
    if (!parameters || !['/account', '/checkout'].includes(browser.location.pathname)) return false
    if (!send('purchase', { ...parameters, transaction_id: transactionId, event_callback: () => {
      if (!enabled()) return
      try {
        browser.localStorage.setItem(key, 'sent')
      }
      catch { /* In-memory and GA transaction IDs still reduce duplicates. */ }
    } }, '/checkout')) return false
    purchases.add(transactionId)
    return true
  }

  function suspend() {
    suspended = true
    if (id) browser[disableKey] = true
  }

  return { pageView, event, purchase, syncConsent, suspend,
    get initialized() {
      return initialized
    },
  }
}
