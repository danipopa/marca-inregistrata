<template>
  <div class="checkout-page">
    <div class="top-strip">
      <div class="wrap top-strip__inner">
        <div class="contact-line">
          <a href="tel:0770898767">0770 898 767</a>
          <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
        </div>
        <nav
          aria-label="Navigatie principala"
          class="quick-links"
        >
          <NuxtLink to="/#despre">{{ t.navAbout }}</NuxtLink>
          <NuxtLink to="/account">{{ t.navAccount }}</NuxtLink>
          <NuxtLink to="/#contact">{{ t.navContact }}</NuxtLink>
        </nav>
      </div>
    </div>

    <header class="main-header">
      <div class="wrap main-header__inner">
        <NuxtLink
          class="brand"
          to="/"
          aria-label="SANDU si Asociatii IP Attorney"
        >
          <span
            class="brand__logo"
            :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
            role="img"
            aria-label="SANDU si Asociatii IP Attorney"
          />
        </NuxtLink>

        <nav
          aria-label="Servicii rapide"
          class="main-nav"
        >
          <NuxtLink to="/#preturi">{{ t.quickRegistration }}</NuxtLink>
          <NuxtLink to="/#reinnoire">{{ t.quickRenewal }}</NuxtLink>
          <NuxtLink to="/#monitorizare">{{ t.quickMonitoring }}</NuxtLink>
          <NuxtLink to="/account">{{ t.navAccount }}</NuxtLink>
          <div
            class="language-switcher"
            :aria-label="t.languageLabel"
          >
            <button
              v-for="option in languages"
              :key="option.code"
              type="button"
              :class="{ active: selectedLanguage === option.code }"
              @click="setLanguage(option.code)"
            >
              {{ option.label }}
            </button>
          </div>
        </nav>
      </div>
    </header>

    <main class="checkout-main">
      <section class="wrap checkout-layout">
        <div>
          <p class="eyebrow">
            {{ t.eyebrow }}
          </p>
          <h1>{{ t.title }}</h1>
          <p>{{ t.copy }}</p>
        </div>

        <div class="checkout-panel">
          <div
            v-if="cartItems.length"
            class="cart-list"
          >
            <article
              v-for="item in cartItems"
              :key="item.id"
              class="cart-item"
            >
              <div>
                <strong>{{ item.productTitle }}</strong>
                <span>{{ item.mark }} · {{ item.classes }} {{ t.niceClasses }}</span>
                <small v-if="item.ownerChangeRequested">{{ t.ownerChangeCartLabel }}</small>
                <small>{{ item.primaryClass }}</small>
              </div>
              <div class="cart-item__meta">
                <strong>{{ item.formattedTotal }}</strong>
                <button
                  type="button"
                  class="text-danger"
                  @click="removeFromCart(item.id)"
                >
                  {{ t.removeFromCart }}
                </button>
              </div>
            </article>
          </div>

          <p
            v-else
            class="muted empty-cart"
          >
            {{ t.emptyCart }}
          </p>

          <div
            v-if="cartItems.length"
            class="checkout-box"
          >
            <div class="checkout-summary">
              <span>{{ t.cartTotal }}</span>
              <strong>{{ formattedCartTotal }}</strong>
              <small>{{ selectedPaymentDescription }}</small>
              <small>{{ accountCheckoutStatus }}</small>
            </div>

            <div class="checkout-payment">
              <span>{{ t.checkoutPaymentLabel }}</span>
              <div class="payment-options">
                <label>
                  <input
                    v-model="checkoutPayment"
                    type="radio"
                    value="card"
                  >
                  {{ t.cardPayment }}
                </label>
                <label>
                  <input
                    v-model="checkoutPayment"
                    type="radio"
                    value="paypal"
                  >
                  {{ t.paypalPayment }}
                </label>
                <label>
                  <input
                    v-model="checkoutPayment"
                    type="radio"
                    value="transfer"
                  >
                  {{ t.bankPayment }}
                </label>
              </div>
            </div>

            <button
              type="button"
              class="primary-btn"
              :disabled="submittingCheckout"
              @click="checkoutCart"
            >
              {{ submittingCheckout ? t.submitting : t.checkout }}
            </button>
          </div>

          <div
            v-if="!authToken && cartItems.length"
            class="checkout-account-box"
          >
            <strong>{{ t.loginRequiredTitle }}</strong>
            <p>{{ t.loginRequiredCopy }}</p>
            <NuxtLink
              class="primary-btn"
              to="/account"
            >
              {{ t.goToAccount }}
            </NuxtLink>
          </div>

          <p
            v-if="checkoutMessage"
            class="success-message"
          >
            {{ checkoutMessage }}
          </p>
          <p
            v-if="checkoutError"
            class="error-message"
          >
            {{ checkoutError }}
          </p>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'

const config = useRuntimeConfig()
const languages = [
  { code: 'ro', label: 'RO' },
  { code: 'en', label: 'EN' },
]
const selectedLanguage = ref('ro')
const authToken = ref('')
const currentUser = ref(null)
const cartItems = ref([])
const checkoutPayment = ref('card')
const submittingCheckout = ref(false)
const checkoutMessage = ref('')
const checkoutError = ref('')

const translations = {
  ro: {
    languageLabel: 'Limba',
    quickRenewal: 'Reinnoire marca',
    quickMonitoring: 'Monitorizare marca',
    quickRegistration: 'Inregistrare marca',
    navAbout: 'Despre noi',
    navAccount: 'Contul meu',
    navContact: 'Contact',
    eyebrow: 'Checkout',
    title: 'Cos si checkout',
    copy: 'Revizuieste produsele din cos, alege metoda de plata si finalizeaza comanda.',
    cartTotal: 'Total cos',
    mixedCurrencyCartTotal: 'Totaluri separate',
    emptyCart: 'Cosul este gol. Alege un serviciu si adauga-l in cos.',
    removeFromCart: 'Sterge',
    ownerChangeCartLabel: 'Include modificare adresa/nume titular',
    checkoutPaymentLabel: 'Metoda de plata',
    cardPayment: 'Card',
    paypalPayment: 'PayPal',
    bankPayment: 'Transfer bancar',
    cardPaymentDescription: 'Stripe Checkout cu redirect securizat',
    paypalPaymentDescription: 'PayPal Checkout cu redirect securizat',
    bankPaymentDescription: 'Vei primi detaliile pentru transfer dupa inregistrarea comenzii.',
    checkout: 'Checkout',
    submitting: 'Se trimite...',
    checkoutSuccess: 'Comanda a fost trimisa.',
    checkoutLoginRequired: 'Autentifica-te in cont inainte de checkout.',
    checkoutBillingRequired: 'Completeaza datele de contact si facturare in cont inainte de plata.',
    checkoutReady: 'Contul are datele necesare pentru checkout.',
    loginRequiredTitle: 'Checkout-ul necesita cont',
    loginRequiredCopy: 'Intra in cont sau creeaza unul, apoi revino aici pentru plata.',
    goToAccount: 'Mergi la cont',
    niceClasses: 'clase NISA',
    accountError: 'Nu am putut trimite comanda. Verifica datele si incearca din nou.',
  },
  en: {
    languageLabel: 'Language',
    quickRenewal: 'Trademark renewal',
    quickMonitoring: 'Trademark monitoring',
    quickRegistration: 'Trademark registration',
    navAbout: 'About us',
    navAccount: 'My account',
    navContact: 'Contact',
    eyebrow: 'Checkout',
    title: 'Cart and checkout',
    copy: 'Review the cart, choose a payment method and complete the order.',
    cartTotal: 'Cart total',
    mixedCurrencyCartTotal: 'Separate totals',
    emptyCart: 'Your cart is empty. Choose a service and add it to the cart.',
    removeFromCart: 'Remove',
    ownerChangeCartLabel: 'Includes owner address/name change',
    checkoutPaymentLabel: 'Payment method',
    cardPayment: 'Card',
    paypalPayment: 'PayPal',
    bankPayment: 'Bank transfer',
    cardPaymentDescription: 'Stripe Checkout with secure redirect',
    paypalPaymentDescription: 'PayPal Checkout with secure redirect',
    bankPaymentDescription: 'You will receive transfer details after the order is registered.',
    checkout: 'Checkout',
    submitting: 'Submitting...',
    checkoutSuccess: 'The order was submitted.',
    checkoutLoginRequired: 'Log in to your account before checkout.',
    checkoutBillingRequired: 'Complete contact and billing details before payment.',
    checkoutReady: 'Your account has the details required for checkout.',
    loginRequiredTitle: 'Checkout requires an account',
    loginRequiredCopy: 'Log in or create an account, then return here for payment.',
    goToAccount: 'Go to account',
    niceClasses: 'NICE classes',
    accountError: 'We could not submit the order. Check the details and try again.',
  },
}

const t = computed(() => translations[selectedLanguage.value])
const locale = computed(() => selectedLanguage.value === 'ro' ? 'ro-RO' : 'en-US')
const cartTotal = computed(() => cartItems.value.reduce((sum, item) => sum + Number(item.total || 0), 0))
const cartCurrencies = computed(() => [...new Set(cartItems.value.map(item => item.currency || 'RON'))])
const formattedCartTotal = computed(() => cartCurrencies.value.length === 1 ? formatMoney(cartTotal.value, cartCurrencies.value[0]) : t.value.mixedCurrencyCartTotal)
const accountCheckoutStatus = computed(() => {
  if (!authToken.value) return t.value.checkoutLoginRequired
  return currentUser.value?.billing_complete ? t.value.checkoutReady : t.value.checkoutBillingRequired
})
const selectedPaymentDescription = computed(() => ({
  card: t.value.cardPaymentDescription,
  paypal: t.value.paypalPaymentDescription,
  transfer: t.value.bankPaymentDescription,
})[checkoutPayment.value])

function setLanguage(code) {
  selectedLanguage.value = code
}

function authHeaders() {
  return authToken.value ? { Authorization: `Bearer ${authToken.value}` } : {}
}

function formatMoney(amount, currency = 'RON') {
  const suffix = currency === 'EUR' ? 'EUR' : 'Lei'
  return `${Number(amount || 0).toLocaleString(locale.value)} ${suffix}`
}

function persistCart() {
  window.localStorage.setItem('cart-items', JSON.stringify(cartItems.value))
}

function loadCart() {
  const storedCart = window.localStorage.getItem('cart-items')

  try {
    const parsedCart = storedCart ? JSON.parse(storedCart) : []
    cartItems.value = Array.isArray(parsedCart) ? parsedCart : []
  }
  catch {
    cartItems.value = []
  }
}

function removeFromCart(id) {
  cartItems.value = cartItems.value.filter(item => item.id !== id)
  persistCart()
}

function errorMessage(payload, fallback) {
  if (payload?.message) return payload.message
  if (!payload?.errors) return fallback

  return Object.entries(payload.errors)
    .map(([field, messages]) => `${field} ${Array.isArray(messages) ? messages.join(', ') : messages}`)
    .join('; ') || fallback
}

async function hydrateSession() {
  const storedToken = window.localStorage.getItem('account-token')
  if (!storedToken) return

  authToken.value = storedToken

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) throw new Error()

    currentUser.value = payload.user
    window.localStorage.setItem('account-user', JSON.stringify(payload.user))
  }
  catch {
    authToken.value = ''
    currentUser.value = null
    window.localStorage.removeItem('account-token')
    window.localStorage.removeItem('account-user')
  }
}

async function submitCartItem(item) {
  const response = await fetch(`${config.public.apiBaseUrl}/api/v1/trademark_requests`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...authHeaders(),
    },
    body: JSON.stringify({
      trademark_request: {
        mark: item.mark,
        product_code: item.productCode,
        classes: item.classes,
        primary_class: item.primaryClass,
        goods: item.goods,
        owner_change_requested: item.ownerChangeRequested,
        payment: checkoutPayment.value,
        terms: item.terms,
      },
    }),
  })
  const payload = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(errorMessage(payload, t.value.accountError))
  }

  return payload
}

async function checkoutCart() {
  checkoutError.value = ''
  checkoutMessage.value = ''

  if (!authToken.value) {
    checkoutError.value = t.value.checkoutLoginRequired
    return
  }

  if (!currentUser.value?.billing_complete) {
    checkoutError.value = t.value.checkoutBillingRequired
    return
  }

  submittingCheckout.value = true

  try {
    const payloads = []

    for (const item of cartItems.value) {
      payloads.push(await submitCartItem(item))
    }

    cartItems.value = []
    persistCart()
    checkoutMessage.value = t.value.checkoutSuccess

    const payloadWithRedirect = payloads.find(result => result.payment?.checkout_url)
    const checkoutUrl = payloadWithRedirect?.payment?.checkout_url

    if (checkoutUrl) window.location.href = checkoutUrl
  }
  catch (error) {
    checkoutError.value = error instanceof Error ? error.message : t.value.accountError
  }
  finally {
    submittingCheckout.value = false
  }
}

onMounted(() => {
  const storedLanguage = window.localStorage.getItem('preferred-language')
  if (storedLanguage && translations[storedLanguage]) selectedLanguage.value = storedLanguage

  loadCart()
  hydrateSession()
})

watch(selectedLanguage, (language) => {
  window.localStorage.setItem('preferred-language', language)
})
</script>

<style scoped>
.checkout-page {
  min-height: 100vh;
  background: var(--paper, #fff);
  color: var(--ink, #1f1d1a);
}

.wrap {
  width: min(100% - 32px, 1120px);
  margin: 0 auto;
}

.top-strip {
  background: var(--brand, #013ebe);
  color: #fff;
}

.top-strip__inner,
.main-header__inner {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: center;
}

.top-strip__inner {
  padding: 9px 0;
}

.contact-line,
.quick-links,
.main-nav,
.language-switcher {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  align-items: center;
}

a {
  color: inherit;
}

.quick-links a,
.main-nav a {
  text-decoration: none;
}

.main-header {
  border-bottom: 1px solid var(--line, #ded8cf);
  background: #fff;
}

.main-header__inner {
  padding: 16px 0;
}

.brand__logo {
  display: block;
  width: 190px;
  height: 64px;
  background-image: var(--fallback-logo-image);
  background-repeat: no-repeat;
  background-position: left center;
  background-size: contain;
}

.language-switcher button {
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  padding: 8px 10px;
  cursor: pointer;
}

.language-switcher button.active {
  border-color: var(--gold, #00add9);
  color: var(--gold-dark, #00add9);
}

.checkout-main {
  padding: 64px 0;
}

.checkout-layout {
  display: grid;
  grid-template-columns: 330px minmax(0, 1fr);
  gap: 28px;
  align-items: start;
}

.eyebrow {
  margin: 0 0 10px;
  color: var(--gold-dark, #00add9);
  font-weight: 700;
  text-transform: uppercase;
}

h1 {
  margin: 0 0 14px;
  font-size: 44px;
  font-weight: 400;
}

.checkout-panel {
  display: grid;
  gap: 16px;
  border: 1px solid var(--line, #ded8cf);
  background: var(--paper, #fff);
  padding: 24px;
}

.cart-list {
  display: grid;
  gap: 12px;
}

.cart-item,
.checkout-box,
.checkout-account-box {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  padding: 16px;
}

.cart-item span,
.cart-item small,
.checkout-box span,
.checkout-box small {
  display: block;
  color: var(--muted, #68635c);
  line-height: 1.5;
}

.cart-item__meta {
  min-width: 130px;
  text-align: right;
}

.checkout-box {
  align-items: center;
  flex-wrap: wrap;
}

.checkout-summary strong {
  display: block;
  margin-top: 4px;
  font-size: 30px;
}

.checkout-payment {
  display: grid;
  gap: 10px;
  min-width: min(100%, 320px);
}

.payment-options {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.payment-options label {
  border: 1px solid var(--line, #ded8cf);
  padding: 10px;
}

.primary-btn,
.text-danger {
  border: 0;
  cursor: pointer;
}

.primary-btn {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  min-height: 44px;
  background: var(--gold, #00add9);
  color: #fff;
  padding: 0 18px;
  text-decoration: none;
}

.primary-btn:disabled {
  cursor: not-allowed;
  opacity: 0.55;
}

.text-danger {
  background: transparent;
  color: #9b2d1f;
  padding: 0;
}

.checkout-account-box {
  display: grid;
}

.success-message,
.error-message {
  margin: 0;
  padding: 12px 14px;
}

.success-message {
  background: #e8f7ee;
  color: #166534;
}

.error-message {
  background: #fff1f0;
  color: #9b2d1f;
}

.muted {
  color: var(--muted, #68635c);
}

@media (max-width: 900px) {
  .checkout-layout,
  .payment-options {
    grid-template-columns: 1fr;
  }

  .top-strip__inner,
  .main-header__inner,
  .cart-item,
  .checkout-box {
    align-items: stretch;
    flex-direction: column;
  }

  .cart-item__meta {
    text-align: left;
  }
}
</style>
