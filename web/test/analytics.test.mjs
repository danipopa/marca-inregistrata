import assert from 'node:assert/strict'
import test from 'node:test'
import { analyticsConsent, analyticsItems, analyticsProvider, createGoogleAnalytics } from '../utils/analytics.js'
import { ANALYTICS_CONSENT_VERSION, CONSENT_STORAGE_KEY } from '../utils/traffic.js'

function fixture({ accepted = true, version = ANALYTICS_CONSENT_VERSION, id = 'G-TEST123456', path = '/', blockedStorage = false } = {}) {
  const values = new Map([[CONSENT_STORAGE_KEY, JSON.stringify({ accepted, version })]])
  const scripts = []
  const cookies = []
  const browser = {
    navigator: {},
    location: { origin: 'https://inregistrare-marca.com', pathname: path, hostname: 'inregistrare-marca.com', search: '?email=secret@example.com', hash: '#private' },
    localStorage: {
      getItem: (key) => {
        if (blockedStorage) throw new Error('Storage blocked')
        return values.get(key)
      },
      setItem: (key, value) => values.set(key, value),
    },
    document: {
      referrer: 'https://google.com/search?q=confidential#private',
      title: 'Private customer trademark name',
      get cookie() { return '_ga=old; _ga_TEST123456=value; essential=keep' },
      set cookie(value) { cookies.push(value) },
      createElement: () => ({}),
      head: { appendChild: script => scripts.push(script) },
    },
  }
  const tracker = createGoogleAnalytics({ measurementId: id, browser })
  const consent = (accepted, version = ANALYTICS_CONSENT_VERSION) => values.set(CONSENT_STORAGE_KEY, JSON.stringify({ accepted, version }))
  const commands = () => (browser.dataLayer || []).map(args => [...args])
  const events = () => commands().filter(command => command[0] === 'event')
  return { browser, tracker, scripts, cookies, consent, values, commands, events }
}

const item = { productCode: 'ro-word', total: 450, currency: 'RON', mark: 'CONFIDENTIAL TRADEMARK', email: 'secret@example.com' }
const paid = { verified: true, order: { id: 123, status: 'paid', product: { code: 'renew-ro-word' }, total: { amount: 799, currency: 'RON' }, email: 'private@example.com' } }

test('provider selection makes GA4 and first-party tracking mutually exclusive', () => {
  assert.equal(analyticsProvider({}), 'first-party')
  assert.equal(analyticsProvider({ googleAnalyticsId: 'G-TEST123456' }), 'google')
  assert.equal(analyticsProvider({ analyticsProvider: 'none', googleAnalyticsId: 'G-TEST123456' }), 'none')
  assert.equal(analyticsProvider({ analyticsProvider: 'google' }), 'google')
  assert.equal(analyticsProvider({ analyticsProvider: 'first-party', googleAnalyticsId: 'G-TEST123456' }), 'first-party')
})

test('no Google script or events without a valid ID and current affirmative consent', () => {
  for (const options of [{ id: '' }, { id: 'G-INVALID<script>' }, { accepted: false }, { version: 'old' }, { blockedStorage: true }]) {
    const f = fixture(options)
    assert.equal(f.tracker.pageView('/'), false)
    assert.equal(f.tracker.event('generate_lead'), false)
    assert.equal(f.tracker.purchase(paid), false)
    assert.equal(f.scripts.length, 0)
    assert.equal(f.commands().length, 0)
  }
})

test('DNT and GPC prevent initial loading and later events', () => {
  for (const preference of [{ doNotTrack: '1' }, { globalPrivacyControl: true }]) {
    const f = fixture()
    Object.assign(f.browser.navigator, preference)
    assert.equal(analyticsConsent(f.browser), false)
    assert.equal(f.tracker.pageView('/'), false)
    assert.equal(f.scripts.length, 0)
  }
})

test('initializes once with denied advertising, manual page views and sanitized context', () => {
  const f = fixture()
  assert.equal(f.tracker.pageView('/'), true)
  assert.equal(f.tracker.pageView('/'), false)
  assert.equal(f.scripts.length, 1)
  assert.equal(f.scripts[0].referrerPolicy, 'no-referrer')
  assert.equal(f.commands()[0][0], 'consent')
  assert.equal(f.commands()[0][1], 'default')
  assert.equal(f.commands()[0][2].analytics_storage, 'denied')
  const config = f.commands().find(command => command[0] === 'config')[2]
  assert.equal(config.send_page_view, false)
  assert.equal(config.allow_google_signals, false)
  assert.equal(config.allow_ad_personalization_signals, false)
  assert.equal(f.events()[0][2].page_referrer, 'https://google.com')
  assert(!JSON.stringify(f.commands()).includes('private'))
  assert(!JSON.stringify(f.commands()).includes('secret'))
  f.browser.location.pathname = '/order'
  assert.equal(f.tracker.pageView('/order'), true)
  assert.equal(f.events()[1][2].page_referrer, 'https://inregistrare-marca.com/')
  assert.equal(f.events()[1][2].page_location, 'https://inregistrare-marca.com/order')
  assert.equal(f.scripts.length, 1)
})

test('navigation suspension and private paths prevent background page views', () => {
  const f = fixture()
  f.tracker.pageView('/')
  f.tracker.suspend()
  assert.equal(f.browser['ga-disable-G-TEST123456'], true)
  for (const path of ['/account', '/admin', '/password-reset', '/unknown']) {
    f.browser.location.pathname = path
    assert.equal(f.tracker.pageView(path), false)
    assert.equal(f.tracker.pageView('/'), false)
    assert.equal(f.tracker.event('generate_lead'), false)
    assert.equal(f.browser['ga-disable-G-TEST123456'], true)
  }
  assert.equal(f.events().length, 1)
})

test('consent withdrawal disables subsequent events and clears only GA cookies', () => {
  const f = fixture()
  f.tracker.pageView('/')
  f.consent(false)
  assert.equal(f.tracker.syncConsent(), false)
  assert.equal(f.browser['ga-disable-G-TEST123456'], true)
  assert.equal(f.tracker.event('generate_lead'), false)
  assert.equal(f.events().length, 1)
  assert(f.cookies.some(cookie => cookie.startsWith('_ga=')))
  assert(!f.cookies.some(cookie => cookie.startsWith('essential=')))
  f.consent(true)
  assert.equal(f.tracker.pageView('/'), true)
  const consentUpdates = f.commands().filter(command => command[0] === 'consent' && command[1] === 'update')
  assert.equal(consentUpdates.at(-1)[2].analytics_storage, 'granted')
  assert.equal(consentUpdates.at(-1)[2].ad_storage, 'denied')
})

test('conversion events contain only allowlisted fields and catalog codes', () => {
  const f = fixture()
  assert.equal(f.tracker.event('generate_lead', { email: 'secret@example.com' }), true)
  assert.equal(f.tracker.event('add_to_cart', { items: [item] }), true)
  assert.equal(f.tracker.event('begin_checkout', { items: [item] }), true)
  assert.equal(f.tracker.event('order_submitted', { items: [item] }), true)
  assert.equal(f.tracker.event('unknown', { email: 'secret@example.com' }), false)
  assert.equal(f.tracker.event('purchase', paid), false)
  assert.equal(f.tracker.event('begin_checkout', { items: [item, { ...item, currency: 'EUR' }] }), false)
  assert.equal(f.tracker.event('add_to_cart', { items: [{ ...item, productCode: 'secret@example.com' }] }), false)
  assert.equal(f.tracker.event('add_to_cart', { items: [{ ...item, total: -1 }] }), false)
  assert.equal(f.tracker.event('add_to_cart', { items: 'invalid' }), false)
  assert(!JSON.stringify(f.events()).includes('secret'))
  assert(!JSON.stringify(f.events()).includes('CONFIDENTIAL'))
  assert.equal(f.events()[1][2].value, 450)
  assert.equal(analyticsItems([{ ...item, productCode: 'eu-logo' }]).length, 1)
})

test('purchase requires server-verified payment, uses server totals and deduplicates transaction IDs', () => {
  const f = fixture({ path: '/account' })
  assert.equal(f.tracker.purchase({ ...paid, verified: false }), false)
  assert.equal(f.tracker.purchase({ ...paid, order: { ...paid.order, status: 'pending_payment' } }), false)
  assert.equal(f.scripts.length, 0)
  assert.equal(f.tracker.purchase(paid), true)
  assert.equal(f.tracker.purchase(paid), false)
  const event = f.events()[0]
  assert.equal(event[1], 'purchase')
  assert.equal(event[2].transaction_id, 'order-123')
  assert.equal(event[2].value, 799)
  assert.equal(event[2].page_location, 'https://inregistrare-marca.com/checkout')
  assert(!JSON.stringify(event).includes('private@example.com'))
  event[2].event_callback()
  assert.equal(f.browser['ga-disable-G-TEST123456'], true)
  const anotherTracker = createGoogleAnalytics({ measurementId: 'G-TEST123456', browser: f.browser })
  assert.equal(anotherTracker.purchase(paid), false)
  f.browser.location.pathname = '/admin'
  assert.equal(anotherTracker.purchase({ ...paid, order: { ...paid.order, id: 456 } }), false)
})

test('account checkout keeps queued conversions enabled until their callbacks complete', () => {
  const f = fixture({ path: '/account' })
  assert.equal(f.tracker.event('begin_checkout', { items: [item] }), true)
  assert.equal(f.tracker.event('order_submitted', { items: [item] }), true)
  f.tracker.syncConsent()
  assert.equal(f.browser['ga-disable-G-TEST123456'], false)
  f.events()[0][2].event_callback()
  assert.equal(f.browser['ga-disable-G-TEST123456'], false)
  f.events()[1][2].event_callback()
  assert.equal(f.browser['ga-disable-G-TEST123456'], true)
})
