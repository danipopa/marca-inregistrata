<template>
  <div class="account-page">
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
          <NuxtLink to="/#despre">
            {{ t.navAbout }}
          </NuxtLink>
          <NuxtLink to="/account">
            {{ t.navAccount }}
          </NuxtLink>
          <NuxtLink to="/#contact">
            {{ t.navContact }}
          </NuxtLink>
        </nav>
      </div>
    </div>

    <header class="main-header">
      <div class="wrap main-header__inner">
        <NuxtLink
          class="brand"
          to="/"
          aria-label="SANDU și Asociații IP Attorney"
        >
          <span
            class="brand__logo"
            :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
            role="img"
            aria-label="SANDU și Asociații IP Attorney"
          />
        </NuxtLink>

        <nav
          aria-label="Servicii rapide"
          class="main-nav"
        >
          <NuxtLink to="/#reinnoire">
            {{ t.quickRenewal }}
          </NuxtLink>
          <NuxtLink to="/#monitorizare">
            {{ t.quickMonitoring }}
          </NuxtLink>
          <NuxtLink to="/#preturi">
            {{ t.quickRegistration }}
          </NuxtLink>
          <NuxtLink to="/#verificare">
            {{ t.quickCheck }}
          </NuxtLink>
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

    <main class="account-main">
      <section class="wrap account-layout">
        <div class="account-copy">
          <p class="eyebrow">
            {{ t.eyebrow }}
          </p>
          <h1>{{ t.title }}</h1>
          <p>
            {{ t.copy }}
          </p>
        </div>

        <div class="account-panel">
          <form
            v-if="!authToken"
            class="account-form"
            @submit.prevent="submitAuth"
          >
            <div class="auth-mode">
              <button
                type="button"
                :class="{ active: authMode === 'login' }"
                @click="authMode = 'login'"
              >
                {{ t.login }}
              </button>
              <button
                type="button"
                :class="{ active: authMode === 'register' }"
                @click="authMode = 'register'"
              >
                {{ t.register }}
              </button>
            </div>

            <label>
              {{ t.email }}
              <input
                v-model="authForm.email"
                type="email"
                placeholder="email@companie.ro"
                required
              >
            </label>

            <label>
              {{ t.password }}
              <input
                v-model="authForm.password"
                type="password"
                :placeholder="t.passwordPlaceholder"
                required
              >
            </label>

            <button
              class="primary-btn"
              type="submit"
              :disabled="authenticating"
            >
              {{ authenticating ? t.loading : authSubmitLabel }}
            </button>

            <div class="google-login">
              <div class="divider">
                <span>{{ t.or }}</span>
              </div>
              <div
                v-if="googleEnabled"
                ref="googleButton"
                class="google-button-host"
              />
              <button
                v-else
                type="button"
                class="google-fallback"
                @click="showGoogleSetupError"
              >
                {{ t.googleLogin }}
              </button>
              <small
                v-if="!googleEnabled"
                class="google-setup"
              >
                {{ t.googleSetupMissing }}
              </small>
            </div>

            <p class="muted">
              {{ t.authNote }}
            </p>
          </form>

          <div
            v-else
            class="account-dashboard"
          >
            <div class="signed-in-bar">
              <div>
                <span>{{ t.signedInAs }}</span>
                <strong>{{ currentUser?.email }}</strong>
              </div>
              <button
                class="ghost-btn"
                type="button"
                @click="logout"
              >
                {{ t.logout }}
              </button>
            </div>

            <form
              class="billing-form"
              @submit.prevent="saveBillingProfile"
            >
              <div>
                <h2>{{ t.billingTitle }}</h2>
                <p>{{ t.billingCopy }}</p>
              </div>

              <label>
                {{ t.phone }}
                <input
                  v-model="billingForm.phone"
                  type="tel"
                  :placeholder="t.phonePlaceholder"
                  required
                >
              </label>

              <label>
                {{ t.ownerType }}
                <select v-model="billingForm.ownerType">
                  <option value="Societate">{{ t.company }}</option>
                  <option value="Persoana fizica">{{ t.person }}</option>
                </select>
              </label>

              <div class="field-grid">
                <label>
                  {{ t.taxId }}
                  <input
                    v-model="billingForm.taxId"
                    type="text"
                    placeholder="RO12345678"
                  >
                </label>
                <label>
                  {{ t.ownerName }}
                  <input
                    v-model="billingForm.ownerName"
                    type="text"
                    :placeholder="t.ownerNamePlaceholder"
                    required
                  >
                </label>
              </div>

              <label>
                {{ t.address }}
                <textarea
                  v-model="billingForm.address"
                  rows="4"
                  :placeholder="t.addressPlaceholder"
                  required
                />
              </label>

              <button
                class="primary-btn"
                type="submit"
                :disabled="savingBilling"
              >
                {{ savingBilling ? t.saving : t.saveBilling }}
              </button>

              <p
                v-if="billingMessage"
                class="success-message"
              >
                {{ billingMessage }}
              </p>
            </form>

            <div
              v-if="account"
              class="account-summary"
            >
              <div>
                <span>{{ t.orders }}</span>
                <strong>{{ account.purchases_count }}</strong>
              </div>
              <div>
                <span>{{ t.total }}</span>
                <strong>{{ account.total_spent.toLocaleString(locale) }} Lei</strong>
              </div>
            </div>

            <div
              v-if="account?.purchases?.length"
              class="purchase-list"
            >
              <article
                v-for="purchase in account.purchases"
                :key="purchase.id"
                class="purchase-item"
              >
                <div>
                  <strong>{{ purchase.product_name || productTitle(purchase.product_code) }}</strong>
                  <span>{{ purchase.mark }} · {{ purchase.classes }} {{ t.niceClasses }}</span>
                </div>
                <div>
                  <strong>{{ purchase.total.formatted }}</strong>
                  <span>{{ statusLabel(purchase.status) }}</span>
                </div>
              </article>
            </div>

            <p
              v-else-if="account"
              class="muted"
            >
              {{ t.noPurchases }}
            </p>
          </div>

          <p
            v-if="accountError"
            class="error-message"
          >
            {{ accountError }}
          </p>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'

const config = useRuntimeConfig()
const languages = [
  { code: 'ro', label: 'RO' },
  { code: 'en', label: 'EN' },
]
const selectedLanguage = ref('ro')
const authMode = ref('login')
const authToken = ref('')
const currentUser = ref(null)
const account = ref(null)
const accountError = ref('')
const authenticating = ref(false)
const savingBilling = ref(false)
const billingMessage = ref('')
const googleButton = ref(null)
const googleReady = ref(false)

const authForm = reactive({
  email: '',
  password: '',
})

const billingForm = reactive({
  phone: '',
  ownerType: 'Societate',
  taxId: '',
  ownerName: '',
  address: '',
})

const translations = {
  ro: {
    languageLabel: 'Limba',
    quickRenewal: 'Reinnoire marca',
    quickMonitoring: 'Monitorizare marca',
    quickRegistration: 'Inregistrare marca',
    quickCheck: 'Verificare marca',
    navAbout: 'Despre noi',
    navCareers: 'Cariere',
    navPractice: 'Arii de practica',
    navAccount: 'Contul meu',
    navContact: 'Contact',
    eyebrow: 'Cont client',
    title: 'Contul meu',
    copy: 'Autentifica-te pentru a vedea comenzile, statusul platii si istoricul solicitarilor tale.',
    login: 'Login',
    register: 'Creeaza cont',
    email: 'Email',
    password: 'Parola',
    passwordPlaceholder: 'Minimum 8 caractere',
    loading: 'Se incarca...',
    loginSubmit: 'Intra in cont',
    registerSubmit: 'Creeaza cont',
    or: 'sau',
    googleLogin: 'Continua cu Google',
    googleSetupMissing: 'Google login nu este configurat. Adaugati NUXT_PUBLIC_GOOGLE_CLIENT_ID in web/.env si GOOGLE_CLIENT_ID in api/.env, apoi reporniti serverele.',
    authNote: 'Comenzile plasate cand esti autentificat vor fi legate automat de acest cont.',
    signedInAs: 'Autentificat ca',
    logout: 'Logout',
    billingTitle: 'Date contact si facturare',
    billingCopy: 'Completeaza aceste date inainte de checkout. Plata nu porneste fara un profil complet.',
    phone: 'Telefon mobil',
    phonePlaceholder: '07xx xxx xxx',
    ownerType: 'Inregistrati marca pe',
    company: 'Societate',
    person: 'Persoana fizica',
    taxId: 'CUI / identificator fiscal',
    ownerName: 'Denumire titular',
    ownerNamePlaceholder: 'Compania SRL',
    address: 'Adresa de facturare',
    addressPlaceholder: 'Strada, numar, localitate, judet',
    saveBilling: 'Salveaza datele',
    saving: 'Se salveaza...',
    billingSaved: 'Datele de contact si facturare au fost salvate.',
    orders: 'Comenzi',
    total: 'Total',
    niceClasses: 'clase NISA',
    noPurchases: 'Nu exista comenzi pentru acest cont.',
    authError: 'Nu am putut autentifica acest cont.',
    accountError: 'Nu am putut incarca acest cont.',
    products: {
      'ro-word': 'Marca verbala OSIM',
      'ro-monochrome': 'Marca alb-negru',
      'ro-color': 'Marca color',
      'eu-word': 'Marca Uniunea Europeana',
      'eu-logo': 'Logo UE',
    },
    statuses: {
      pending_payment: 'In asteptarea platii',
      paid: 'Platita',
      processing: 'In lucru',
      completed: 'Finalizata',
    },
  },
  en: {
    languageLabel: 'Language',
    quickRenewal: 'Trademark renewal',
    quickMonitoring: 'Trademark monitoring',
    quickRegistration: 'Trademark registration',
    quickCheck: 'Trademark check',
    navAbout: 'About us',
    navCareers: 'Careers',
    navPractice: 'Practice areas',
    navAccount: 'My account',
    navContact: 'Contact',
    eyebrow: 'Client account',
    title: 'My account',
    copy: 'Log in to see your orders, payment status and request history.',
    login: 'Login',
    register: 'Create account',
    email: 'Email',
    password: 'Password',
    passwordPlaceholder: 'Minimum 8 characters',
    loading: 'Loading...',
    loginSubmit: 'Log in',
    registerSubmit: 'Create account',
    or: 'or',
    googleLogin: 'Continue with Google',
    googleSetupMissing: 'Google login is not configured. Add NUXT_PUBLIC_GOOGLE_CLIENT_ID in web/.env and GOOGLE_CLIENT_ID in api/.env, then restart both servers.',
    authNote: 'Orders placed while signed in will be attached to this account automatically.',
    signedInAs: 'Signed in as',
    logout: 'Logout',
    billingTitle: 'Contact and billing details',
    billingCopy: 'Complete these details before checkout. Payment cannot start without a complete profile.',
    phone: 'Mobile phone',
    phonePlaceholder: '+40...',
    ownerType: 'Register the trademark for',
    company: 'Company',
    person: 'Individual',
    taxId: 'VAT / tax identifier',
    ownerName: 'Owner name',
    ownerNamePlaceholder: 'Company LLC',
    address: 'Billing address',
    addressPlaceholder: 'Street, number, city, county',
    saveBilling: 'Save details',
    saving: 'Saving...',
    billingSaved: 'Contact and billing details were saved.',
    orders: 'Orders',
    total: 'Total',
    niceClasses: 'NICE classes',
    noPurchases: 'There are no orders for this account.',
    authError: 'We could not authenticate this account.',
    accountError: 'We could not load this account.',
    products: {
      'ro-word': 'Word trademark',
      'ro-monochrome': 'Black-and-white trademark',
      'ro-color': 'Color trademark',
      'eu-word': 'European Union trademark',
      'eu-logo': 'EU logo',
    },
    statuses: {
      pending_payment: 'Pending payment',
      paid: 'Paid',
      processing: 'Processing',
      completed: 'Completed',
    },
  },
}

const t = computed(() => translations[selectedLanguage.value])
const locale = computed(() => selectedLanguage.value === 'ro' ? 'ro-RO' : 'en-US')
const authSubmitLabel = computed(() => authMode.value === 'login' ? t.value.loginSubmit : t.value.registerSubmit)
const googleEnabled = computed(() => Boolean(config.public.googleClientId))

function setLanguage(code) {
  selectedLanguage.value = code
}

function authHeaders() {
  return authToken.value ? { Authorization: `Bearer ${authToken.value}` } : {}
}

function productTitle(code) {
  return t.value.products[code] || code
}

function statusLabel(status) {
  return t.value.statuses[status] || status
}

function errorMessage(payload, fallback) {
  if (payload?.message) return payload.message
  if (!payload?.errors) return fallback

  return Object.entries(payload.errors)
    .map(([field, messages]) => `${field} ${Array.isArray(messages) ? messages.join(', ') : messages}`)
    .join('; ') || fallback
}

function showGoogleSetupError() {
  accountError.value = t.value.googleSetupMissing
}

function persistSession(token, user) {
  authToken.value = token
  currentUser.value = user
  window.localStorage.setItem('account-token', token)
  window.localStorage.setItem('account-user', JSON.stringify(user))
}

function clearSession() {
  authToken.value = ''
  currentUser.value = null
  account.value = null
  window.localStorage.removeItem('account-token')
  window.localStorage.removeItem('account-user')
}

function populateBillingForm(profile = {}) {
  billingForm.phone = profile.phone || ''
  billingForm.ownerType = profile.owner_type || 'Societate'
  billingForm.taxId = profile.tax_id || ''
  billingForm.ownerName = profile.owner_name || ''
  billingForm.address = profile.address || ''
}

async function submitAuth() {
  accountError.value = ''
  authenticating.value = true

  try {
    const isRegistering = authMode.value === 'register'
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/${isRegistering ? 'users' : 'session'}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        [isRegistering ? 'user' : 'session']: {
          email: authForm.email,
          password: authForm.password,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(errorMessage(payload, t.value.authError))
    }

    persistSession(payload.token, payload.user)
    await loadAccount()
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.authError
  }
  finally {
    authenticating.value = false
  }
}

function loadGoogleScript() {
  if (!googleEnabled.value || document.querySelector('script[src="https://accounts.google.com/gsi/client"]')) {
    googleReady.value = Boolean(window.google?.accounts?.id)
    return
  }

  const script = document.createElement('script')
  script.src = 'https://accounts.google.com/gsi/client'
  script.async = true
  script.defer = true
  script.onload = () => {
    googleReady.value = true
    renderGoogleButton()
  }
  document.head.appendChild(script)
}

async function renderGoogleButton() {
  await nextTick()

  if (!googleEnabled.value || !googleReady.value || !googleButton.value || authToken.value) return

  googleButton.value.innerHTML = ''
  window.google.accounts.id.initialize({
    client_id: config.public.googleClientId,
    callback: submitGoogleCredential,
  })
  window.google.accounts.id.renderButton(googleButton.value, {
    theme: 'outline',
    size: 'large',
    width: 320,
    text: authMode.value === 'register' ? 'signup_with' : 'signin_with',
  })
}

async function submitGoogleCredential(response) {
  accountError.value = ''
  authenticating.value = true

  try {
    const result = await fetch(`${config.public.apiBaseUrl}/api/v1/session/google`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ credential: response.credential }),
    })
    const payload = await result.json().catch(() => ({}))

    if (!result.ok) {
      throw new Error(errorMessage(payload, t.value.authError))
    }

    persistSession(payload.token, payload.user)
    await loadAccount()
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.authError
  }
  finally {
    authenticating.value = false
  }
}

async function hydrateSession() {
  const storedToken = window.localStorage.getItem('account-token')
  const storedUser = window.localStorage.getItem('account-user')

  if (!storedToken) return

  authToken.value = storedToken
  currentUser.value = storedUser ? JSON.parse(storedUser) : null

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) throw new Error()

    currentUser.value = payload.user
    window.localStorage.setItem('account-user', JSON.stringify(payload.user))
    await loadAccount()
  }
  catch {
    clearSession()
  }
}

async function loadAccount() {
  accountError.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(errorMessage(payload, t.value.accountError))
    }

    account.value = payload.account
    populateBillingForm(payload.account.billing_profile)
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.accountError
  }
}

async function saveBillingProfile() {
  accountError.value = ''
  billingMessage.value = ''
  savingBilling.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({
        account: {
          phone: billingForm.phone,
          owner_type: billingForm.ownerType,
          tax_id: billingForm.taxId,
          owner_name: billingForm.ownerName,
          address: billingForm.address,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(errorMessage(payload, t.value.accountError))
    }

    currentUser.value = payload.user
    window.localStorage.setItem('account-user', JSON.stringify(payload.user))
    billingMessage.value = payload.message || t.value.billingSaved
    await loadAccount()
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.accountError
  }
  finally {
    savingBilling.value = false
  }
}

async function logout() {
  if (authToken.value) {
    await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      method: 'DELETE',
      headers: authHeaders(),
    }).catch(() => {})
  }

  clearSession()
}

onMounted(() => {
  const storedLanguage = window.localStorage.getItem('preferred-language')

  if (storedLanguage && translations[storedLanguage]) {
    selectedLanguage.value = storedLanguage
  }

  hydrateSession()
  loadGoogleScript()
  renderGoogleButton()
})

watch(selectedLanguage, (language) => {
  window.localStorage.setItem('preferred-language', language)
})

watch([authMode, authToken], () => {
  renderGoogleButton()
})
</script>

<style>
:root {
  color-scheme: light;
  --ink: #1f1d1a;
  --muted: #68635c;
  --line: #ded8cf;
  --paper: #fff;
  --gold: #00add9;
  --gold-dark: #00add9;
  --brand: #013ebe;
  --font-family: 'Montserrat', sans-serif;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--paper);
  color: var(--ink);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

button,
input,
select,
textarea {
  font: inherit;
}

a {
  color: inherit;
}

.wrap {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
}

.top-strip {
  background: var(--brand);
  color: #f8f3ea;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  letter-spacing: 0.02em;
}

.top-strip__inner,
.main-header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.top-strip__inner {
  min-height: 38px;
}

.contact-line,
.quick-links,
.main-nav {
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
}

.quick-links a,
.main-nav a {
  text-decoration: none;
}

.main-header {
  background: #fff;
  border-bottom: 1px solid var(--line);
  position: sticky;
  top: 0;
  z-index: 10;
}

.main-header__inner {
  min-height: 86px;
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  min-width: max-content;
}

.brand__logo {
  display: block;
  background: var(--logo-image, var(--fallback-logo-image)) center / contain no-repeat;
  width: clamp(180px, 22vw, 257px);
  height: clamp(58px, 7vw, 83px);
  aspect-ratio: 257 / 83;
}

.muted {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.main-nav {
  color: #38332d;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 700;
  gap: 10px;
  justify-content: flex-end;
}

.main-nav a {
  border-bottom: 2px solid rgba(0, 173, 217, 0.28);
  color: var(--gold-dark);
  padding: 10px 2px 8px;
}

.main-nav a:hover,
.main-nav a:focus-visible {
  border-bottom-color: var(--gold);
  background: rgba(0, 173, 217, 0.06);
  color: var(--gold-dark);
}

.language-switcher,
.auth-mode {
  display: inline-flex;
  border: 1px solid var(--line);
}

.language-switcher button,
.auth-mode button {
  border: 0;
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.language-switcher button {
  width: 38px;
  height: 30px;
  font-size: 11px;
}

.auth-mode button {
  min-height: 44px;
  padding: 0 16px;
}

.language-switcher button + button,
.auth-mode button + button {
  border-left: 1px solid var(--line);
}

.language-switcher button.active,
.auth-mode button.active {
  background: #2b2926;
  color: #fff;
}

.account-main {
  padding: 70px 0;
}

.account-layout {
  display: grid;
  grid-template-columns: minmax(0, 0.75fr) minmax(0, 1.25fr);
  gap: 34px;
  align-items: start;
}

.eyebrow {
  margin: 0 0 10px;
  color: var(--gold);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.account-copy h1 {
  margin: 0;
  font-size: clamp(42px, 6vw, 68px);
  font-weight: 400;
  line-height: 1;
}

.account-copy p:not(.eyebrow) {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 17px;
  line-height: 1.7;
}

.account-panel {
  border: 1px solid var(--line);
  background: #fff;
  padding: 28px;
}

.account-form,
.billing-form,
.account-dashboard {
  display: grid;
  gap: 18px;
}

.account-form label,
.billing-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.account-form input,
.billing-form input,
.billing-form select,
.billing-form textarea {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.billing-form {
  border: 1px solid var(--line);
  background: #fff;
  padding: 18px;
}

.billing-form h2 {
  margin: 0;
  font-size: 28px;
  font-weight: 400;
}

.billing-form p {
  margin: 8px 0 0;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.6;
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.google-login {
  display: grid;
  justify-items: center;
  gap: 14px;
}

.google-button-host {
  min-height: 40px;
}

.google-fallback {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  width: min(100%, 320px);
  border: 1px solid var(--line);
  background: #fff;
  color: #2d2924;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.google-setup {
  max-width: 420px;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.5;
  text-align: center;
}

.divider {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: 12px;
  width: 100%;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  text-transform: uppercase;
}

.divider::before,
.divider::after {
  content: '';
  border-top: 1px solid var(--line);
}

.primary-btn,
.ghost-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border-radius: 2px;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.primary-btn {
  border: 0;
  background: var(--gold);
  color: #fff;
  padding: 0 22px;
}

.ghost-btn {
  border: 1px solid var(--gold);
  background: transparent;
  color: var(--gold-dark);
  padding: 0 20px;
}

.signed-in-bar,
.account-summary,
.purchase-item {
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.signed-in-bar,
.account-summary,
.purchase-item {
  display: flex;
  justify-content: space-between;
  gap: 18px;
}

.signed-in-bar {
  align-items: center;
}

.signed-in-bar span,
.account-summary span,
.purchase-item span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.account-summary strong {
  display: block;
  margin-top: 6px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 28px;
  font-weight: 400;
}

.purchase-list {
  display: grid;
  gap: 10px;
}

.purchase-item div:last-child {
  text-align: right;
}

.error-message {
  margin: 18px 0 0;
  border: 1px solid #d7b7a9;
  background: #fff1eb;
  color: #8f3d22;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.success-message {
  margin: 0;
  border: 1px solid #c8d9bf;
  background: #f2f8ef;
  color: #3b6d2b;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

@media (max-width: 800px) {
  .main-header__inner,
  .top-strip__inner,
  .account-layout,
  .field-grid,
  .signed-in-bar,
  .account-summary,
  .purchase-item {
    grid-template-columns: 1fr;
    flex-direction: column;
    align-items: stretch;
  }

  .main-header__inner,
  .top-strip__inner {
    padding: 14px 0;
  }

  .main-nav {
    flex-wrap: wrap;
  }

  .purchase-item div:last-child {
    text-align: left;
  }
}
</style>
