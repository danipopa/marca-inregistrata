<template>
  <div class="account-page">
    <SiteTopStrip :labels="t" />
    <SiteHeader
      :cart-count="cartCount"
      :labels="t"
      :languages="languages"
      :selected-language="selectedLanguage"
      @update:selected-language="setLanguage"
    />

    <main class="account-main">
      <AccountIntro :labels="t" />

      <section class="wrap account-panel">
        <p
          v-if="paymentReturnMessage"
          :class="paymentReturnClass"
        >
          {{ paymentReturnMessage }}
        </p>

        <AccountAuthPanel
          v-if="authHydrating || !authToken"
          :authenticating="authenticating"
          :form="authForm"
          :hydrating="authHydrating"
          :labels="t"
          :mfa-challenge="mfaChallenge"
          :mode="authMode"
          :submit-label="authSubmitLabel"
          @submit="submitAuth"
          @update:form="updateAuthForm"
          @update:mode="setAuthMode"
        />

        <div
          v-else
          class="account-workspace"
        >
          <AccountOverview
            :account="account"
            :display-name="profileDisplayName"
            :initials="profileInitials"
            :labels="t"
            :locale="locale"
            :menu-open="accountMenuOpen"
            :user="currentUser"
            @edit-billing="openBillingModal"
            @logout="logout"
            @reset-mfa="openMfaResetModal"
            @update:menu-open="accountMenuOpen = $event"
          />

          <AccountCartPanel
            :checkout-status="accountCheckoutStatus"
            :error="checkoutError"
            :formatted-total="formattedCartTotal"
            :items="cartItems"
            :labels="t"
            :message="checkoutMessage"
            :payment="checkoutPayment"
            :selected-payment-description="selectedPaymentDescription"
            :submitting="submittingCheckout"
            @checkout="checkoutCart"
            @remove-item="removeFromCart"
            @update:payment="checkoutPayment = $event"
          />

          <AccountOrdersPanel
            :account="account"
            :invoice-label="invoiceLabel"
            :labels="t"
            :product-title="productTitle"
            :removing-purchase-id="removingPurchaseId"
            :status-label="statusLabel"
            @download-invoice="downloadInvoice"
            @remove-purchase="removePurchase"
          />
        </div>

        <p
          v-if="accountError"
          class="error-message"
        >
          {{ accountError }}
        </p>
      </section>

      <AccountBillingModal
        :field-labels="billingFieldLabels"
        :form="billingForm"
        :labels="t"
        :message="billingMessage"
        :open="billingModalOpen"
        :saving="savingBilling"
        @close="closeBillingModal"
        @save="saveBillingProfile"
        @update:form="updateBillingForm"
      />

      <div
        v-if="mfaResetOpen"
        class="modal-backdrop"
        @click.self="closeMfaResetModal"
      >
        <section
          class="modal-panel"
          :aria-label="t.resetMfaTitle"
        >
          <div class="modal-panel__header">
            <div>
              <span>{{ t.resetMfaKicker }}</span>
              <h2>{{ t.resetMfaTitle }}</h2>
            </div>
            <button
              type="button"
              :aria-label="t.close"
              @click="closeMfaResetModal"
            >
              ×
            </button>
          </div>

          <form
            class="billing-form"
            @submit.prevent="resetOwnMfa"
          >
            <p class="muted">
              {{ t.resetMfaCopy }}
            </p>
            <label>
              {{ t.password }}
              <input
                v-model="mfaResetForm.password"
                type="password"
                :placeholder="t.passwordPlaceholder"
                required
              >
            </label>
            <label>
              {{ t.mfaCode }}
              <input
                v-model="mfaResetForm.otpCode"
                type="text"
                :placeholder="t.mfaCodePlaceholder"
                required
              >
            </label>
            <div class="form-actions">
              <button
                class="primary-btn"
                type="submit"
                :disabled="resettingMfa"
              >
                {{ resettingMfa ? t.loading : t.resetMfaSubmit }}
              </button>
              <button
                class="ghost-btn"
                type="button"
                @click="closeMfaResetModal"
              >
                {{ t.cancel }}
              </button>
            </div>
            <p
              v-if="mfaResetError"
              class="error-message"
            >
              {{ mfaResetError }}
            </p>
          </form>
        </section>
      </div>

      <div
        v-if="mfaRecoveryCodes.length"
        class="modal-backdrop"
      >
        <section
          class="modal-panel"
          :aria-label="t.recoveryCodesTitle"
        >
          <div class="modal-panel__header">
            <div>
              <span>{{ t.resetMfaKicker }}</span>
              <h2>{{ t.recoveryCodesTitle }}</h2>
            </div>
          </div>
          <p class="muted">
            {{ t.recoveryCodesCopy }}
          </p>
          <div class="recovery-code-list">
            <code
              v-for="code in mfaRecoveryCodes"
              :key="code"
            >
              {{ code }}
            </code>
          </div>
          <div class="form-actions">
            <button
              class="primary-btn"
              type="button"
              @click="mfaRecoveryCodes = []"
            >
              {{ t.recoveryCodesSaved }}
            </button>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'

const config = useRuntimeConfig()
const route = useRoute()
const authMode = ref('login')
const account = ref(null)
const accountError = ref('')
const authenticating = ref(false)
const savingBilling = ref(false)
const billingMessage = ref('')
const billingModalOpen = ref(false)
const accountMenuOpen = ref(false)
const mfaResetOpen = ref(false)
const resettingMfa = ref(false)
const mfaResetError = ref('')
const mfaRecoveryCodes = ref([])
const removingPurchaseId = ref(null)
const checkoutPayment = ref('card')
const submittingCheckout = ref(false)
const checkoutMessage = ref('')
const checkoutError = ref('')
const paymentVerificationMessage = ref('')
const paymentVerificationState = ref('')
const mfaChallenge = ref(null)

const authForm = reactive({
  email: '',
  password: '',
  otpCode: '',
})

const billingForm = reactive({
  phone: '',
  ownerType: 'Societate',
  taxId: '',
  ownerName: '',
  address: '',
})
const mfaResetForm = reactive({
  password: '',
  otpCode: '',
})

const {
  languages,
  locale,
  selectedLanguage,
  setLanguage,
  t,
} = usePreferredLanguage('account')

useHead(() => ({
  title: t.value.metaTitle,
}))

const {
  cartCount,
  cartCurrencies,
  cartItems,
  cartTotal,
  clearCart,
  loadCart,
  removeFromCart,
} = useCart()
const {
  authHeaders,
  authHydrating,
  authToken,
  clearSession,
  currentUser,
  logout: logoutSession,
  persistSession,
  verifyStoredSession,
} = useAuthSession()
const authSubmitLabel = computed(() => authMode.value === 'login' ? t.value.loginSubmit : t.value.registerSubmit)
const formattedCartTotal = computed(() => cartCurrencies.value.length === 1 ? formatMoney(cartTotal.value, cartCurrencies.value[0]) : t.value.mixedCurrencyCartTotal)
const accountCheckoutStatus = computed(() => currentUser.value?.billing_complete ? t.value.checkoutReady : t.value.checkoutBillingRequired)
const paymentReturnState = computed(() => route.query.payment?.toString() || '')
const paymentReturnOrderId = computed(() => route.query.order?.toString() || '')
const paymentReturnMessage = computed(() => {
  if (paymentVerificationMessage.value) return paymentVerificationMessage.value
  if (paymentReturnState.value === 'success') return t.value.paymentReturnSuccess
  if (paymentReturnState.value === 'cancelled') return t.value.paymentReturnCancelled
  return ''
})
const paymentReturnClass = computed(() => {
  if (paymentVerificationState.value === 'failed') return 'error-message'
  if (paymentReturnState.value === 'cancelled') return 'error-message'
  return 'success-message'
})
const selectedPaymentDescription = computed(() => ({
  card: t.value.cardPaymentDescription,
  paypal: t.value.paypalPaymentDescription,
  transfer: t.value.bankPaymentDescription,
})[checkoutPayment.value])
const profileDisplayName = computed(() => {
  const user = currentUser.value || {}
  return user.name || user.owner_name || user.email?.split('@')[0] || t.value.accountButton
})
const profileInitials = computed(() => {
  const words = profileDisplayName.value
    .split(/\s+/)
    .filter(Boolean)

  if (!words.length) return 'U'

  return words
    .slice(0, 2)
    .map(word => word[0])
    .join('')
    .toUpperCase()
})
const billingFieldLabels = computed(() => {
  const prefix = billingForm.ownerType === 'Persoana fizica' ? 'person' : 'company'

  return {
    taxId: t.value[`${prefix}TaxId`],
    taxIdPlaceholder: t.value[`${prefix}TaxIdPlaceholder`],
    ownerName: t.value[`${prefix}OwnerName`],
    ownerNamePlaceholder: t.value[`${prefix}OwnerNamePlaceholder`],
    address: t.value[`${prefix}Address`],
    addressPlaceholder: t.value[`${prefix}AddressPlaceholder`],
  }
})

function productTitle(code) {
  return t.value.products[code] || code
}

function formatMoney(amount, currency = 'RON') {
  const suffix = currency === 'EUR' ? 'EUR' : 'Lei'
  return `${Number(amount || 0).toLocaleString(locale.value)} ${suffix}`
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

function updateAuthForm(form) {
  Object.assign(authForm, form)
}

function setAuthMode(mode) {
  authMode.value = mode
  mfaChallenge.value = null
  authForm.otpCode = ''
}

function updateBillingForm(form) {
  Object.assign(billingForm, form)
}

function openBillingModal() {
  billingMessage.value = ''
  accountMenuOpen.value = false
  billingModalOpen.value = true
}

function closeBillingModal() {
  if (savingBilling.value) return

  billingModalOpen.value = false
}

function openMfaResetModal() {
  mfaResetError.value = ''
  mfaResetForm.password = ''
  mfaResetForm.otpCode = ''
  mfaResetOpen.value = true
  accountMenuOpen.value = false
}

function closeMfaResetModal() {
  if (resettingMfa.value) return

  mfaResetOpen.value = false
}

function populateBillingForm(profile = {}) {
  billingForm.phone = profile.phone || ''
  billingForm.ownerType = profile.owner_type || 'Societate'
  billingForm.taxId = profile.tax_id || ''
  billingForm.ownerName = profile.owner_name || ''
  billingForm.address = profile.address || ''
}

function invoiceLabel(purchase) {
  return purchase.payment_method === 'transfer' ? t.value.downloadProforma : t.value.downloadInvoice
}

function downloadBlob(blob, filename) {
  const objectUrl = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = objectUrl
  link.download = filename
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(objectUrl)
}

async function downloadInvoice(purchase) {
  accountError.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account/purchases/${purchase.id}/invoice`, {
      headers: authHeaders(),
    })

    if (!response.ok) throw new Error(t.value.accountError)

    const blob = await response.blob()
    const prefix = purchase.payment_method === 'transfer' ? 'proforma' : 'factura'
    downloadBlob(blob, `${prefix}-${purchase.id}.pdf`)
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.accountError
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
  billingMessage.value = ''

  if (!currentUser.value?.billing_complete) {
    checkoutError.value = t.value.checkoutBillingRequired
    openBillingModal()
    return
  }

  submittingCheckout.value = true

  try {
    const payloads = []

    for (const item of cartItems.value) {
      payloads.push(await submitCartItem(item))
    }

    clearCart()
    checkoutMessage.value = t.value.checkoutSuccess
    await loadAccount()

    const payloadWithRedirect = payloads.find(result => result.payment?.checkout_url)
    const checkoutUrl = payloadWithRedirect?.payment?.checkout_url

    if (checkoutUrl) {
      window.location.href = checkoutUrl
    }
  }
  catch (error) {
    checkoutError.value = error instanceof Error ? error.message : t.value.accountError
  }
  finally {
    submittingCheckout.value = false
  }
}

async function submitAuth() {
  accountError.value = ''
  authenticating.value = true

  try {
    if (mfaChallenge.value) {
      await submitMfaCode()
      return
    }

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

    if (payload.mfa_required) {
      mfaChallenge.value = payload
      authForm.otpCode = ''
      return
    }

    persistSession(payload.token, payload.user)
    await loadAccount()
    await verifyReturnedPayment()
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.authError
  }
  finally {
    authenticating.value = false
  }
}

async function submitMfaCode() {
  const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session/mfa`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      session: {
        mfa_token: mfaChallenge.value.mfa_token,
        otp_code: authForm.otpCode,
      },
    }),
  })
  const payload = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(errorMessage(payload, t.value.mfaError))
  }

  mfaChallenge.value = null
  authForm.otpCode = ''
  persistSession(payload.token, payload.user)
  mfaRecoveryCodes.value = payload.recovery_codes || []
  await loadAccount()
  await verifyReturnedPayment()
}

async function resetOwnMfa() {
  mfaResetError.value = ''
  resettingMfa.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account/mfa/reset`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({
        mfa: {
          password: mfaResetForm.password,
          otp_code: mfaResetForm.otpCode,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(errorMessage(payload, t.value.mfaError))
    }

    mfaResetOpen.value = false
    clearSession()
    account.value = null
    mfaChallenge.value = payload
    authForm.otpCode = ''
  }
  catch (error) {
    mfaResetError.value = error instanceof Error ? error.message : t.value.mfaError
  }
  finally {
    resettingMfa.value = false
  }
}

async function hydrateAccountSession() {
  if (await verifyStoredSession()) {
    await loadAccount()
    await verifyReturnedPayment()
  }
  else {
    account.value = null
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

async function verifyReturnedPayment() {
  if (paymentReturnState.value !== 'success' || !paymentReturnOrderId.value || paymentVerificationMessage.value) return

  paymentVerificationState.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account/purchases/${paymentReturnOrderId.value}/verify_payment`, {
      method: 'POST',
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || t.value.paymentNotVerified)
    }

    paymentVerificationState.value = payload.verified ? 'verified' : 'failed'
    paymentVerificationMessage.value = payload.verified ? t.value.paymentVerified : t.value.paymentNotVerified
    await loadAccount()
  }
  catch (error) {
    paymentVerificationState.value = 'failed'
    paymentVerificationMessage.value = error instanceof Error ? error.message : t.value.paymentNotVerified
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
    billingModalOpen.value = false
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.accountError
  }
  finally {
    savingBilling.value = false
  }
}

async function removePurchase(purchase) {
  if (!window.confirm(t.value.removePurchaseConfirm)) return

  accountError.value = ''
  billingMessage.value = ''
  removingPurchaseId.value = purchase.id

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account/purchases/${purchase.id}`, {
      method: 'DELETE',
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(errorMessage(payload, t.value.accountError))
    }

    billingMessage.value = payload.message || t.value.purchaseRemoved
    await loadAccount()
  }
  catch (error) {
    accountError.value = error instanceof Error ? error.message : t.value.accountError
  }
  finally {
    removingPurchaseId.value = null
  }
}

async function logout() {
  await logoutSession()
  account.value = null
}

onMounted(() => {
  hydrateAccountSession()
  loadCart()
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
  text-transform: uppercase;
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

.cart-nav-link {
  position: relative;
  display: inline-grid;
  place-items: center;
  width: 38px;
  height: 32px;
  border: 1px solid var(--gold);
  background: #f4fbfd;
  color: #126175;
  text-decoration: none;
}

.cart-nav-icon {
  position: relative;
  width: 18px;
  height: 13px;
  border: 2px solid currentColor;
  border-top: 0;
}

.cart-nav-icon::before {
  content: "";
  position: absolute;
  left: -3px;
  top: -5px;
  width: 8px;
  height: 2px;
  background: currentColor;
  transform: rotate(-18deg);
  transform-origin: right center;
}

.cart-nav-icon::after {
  content: "";
  position: absolute;
  left: 2px;
  right: 2px;
  bottom: -6px;
  height: 4px;
  border-right: 2px solid currentColor;
  border-left: 2px solid currentColor;
}

.cart-nav-count {
  position: absolute;
  top: -8px;
  right: -8px;
  display: grid;
  place-items: center;
  min-width: 20px;
  height: 20px;
  border: 2px solid #fff;
  background: #2b2926;
  color: #fff;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 11px;
  font-weight: 700;
  line-height: 1;
  padding: 0 5px;
}

.account-main {
  background: #fff;
  padding: 44px 0 70px;
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

.account-intro {
  display: flex;
  justify-content: space-between;
  gap: 32px;
  align-items: end;
  margin-bottom: 28px;
}

.account-intro h1 {
  max-width: 760px;
  margin: 0;
  font-size: clamp(38px, 5vw, 58px);
  font-weight: 400;
  line-height: 1.04;
}

.account-intro p:not(.eyebrow) {
  max-width: 660px;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 16px;
  line-height: 1.7;
}

.account-panel {
  display: grid;
  gap: 16px;
}

.auth-shell {
  max-width: 560px;
}

.account-form,
.billing-form,
.account-workspace {
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

.mfa-panel {
  display: grid;
  gap: 12px;
  padding: 16px;
  border: 1px solid rgba(0, 173, 217, 0.28);
  background: rgba(0, 173, 217, 0.08);
}

.mfa-panel p {
  margin: 0;
  color: var(--muted);
}

.mfa-secret {
  display: grid;
  gap: 6px;
}

.mfa-secret img {
  width: 192px;
  max-width: 100%;
  border: 1px solid var(--line);
  background: #fff;
}

.mfa-secret span {
  font-size: 0.82rem;
  color: var(--muted);
}

.mfa-secret code {
  padding: 10px 12px;
  border: 1px solid var(--line);
  background: var(--paper);
  overflow-wrap: anywhere;
  font-size: 0.88rem;
}

.recovery-code-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.recovery-code-list code {
  padding: 10px 12px;
  border: 1px solid var(--line);
  background: var(--paper);
  text-align: center;
  font-weight: 700;
}

.billing-form,
.account-form {
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.orders-panel {
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.billing-form h2,
.orders-panel h2 {
  margin: 0;
  font-size: 28px;
  font-weight: 400;
}

.billing-form p,
.orders-panel p {
  margin: 8px 0 0;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.6;
}

.account-overview {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: stretch;
  justify-content: space-between;
  gap: 14px;
  border-bottom: 1px solid var(--line);
  padding-bottom: 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.account-metrics span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.account-metrics {
  display: flex;
  align-items: center;
  gap: 0;
  border: 1px solid var(--line);
  background: #fff;
}

.account-metrics div {
  min-width: 112px;
  padding: 9px 14px;
}

.account-metrics div + div {
  border-left: 1px solid var(--line);
}

.account-metrics strong {
  display: block;
  margin-top: 2px;
  font-size: 20px;
  font-weight: 500;
}

.account-menu {
  position: relative;
  min-width: min(100%, 260px);
}

.account-menu__button {
  display: grid;
  grid-template-columns: 36px minmax(0, 1fr);
  align-items: center;
  gap: 10px;
  width: 100%;
  min-height: 54px;
  border: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  padding: 8px 12px;
  text-align: left;
}

.account-avatar {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border: 1px solid #b7ccd6;
  background: #edf8fb;
  color: #126175;
  font-size: 13px;
  font-weight: 700;
}

.account-menu__label {
  min-width: 0;
}

.account-menu__label span {
  display: block;
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.account-menu__label strong {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.account-menu__label small {
  display: block;
  overflow: hidden;
  color: #426471;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.35;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.account-menu__panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 12;
  display: grid;
  width: min(320px, calc(100vw - 32px));
  border: 1px solid var(--line);
  background: #fff;
  box-shadow: 0 18px 50px rgba(13, 31, 46, 0.14);
  padding: 10px;
}

.account-menu__user {
  display: grid;
  gap: 4px;
  padding: 10px 12px 12px;
}

.account-menu__user span {
  overflow: hidden;
  color: var(--muted);
  font-size: 13px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.account-menu__edit {
  min-height: auto;
  border: 0;
  background: transparent;
  color: var(--gold-dark);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 700;
  margin-top: 4px;
  padding: 0;
  text-align: left;
  text-decoration: underline;
  text-underline-offset: 4px;
}

.account-menu__status {
  border-left: 4px solid var(--gold);
  background: #f4fbfd;
  padding: 12px;
}

.account-menu__status span,
.account-menu__status small {
  display: block;
}

.account-menu__status span {
  font-weight: 700;
}

.account-menu__status small {
  margin-top: 4px;
  color: var(--muted);
  line-height: 1.5;
}

.account-menu__panel button {
  min-height: 42px;
  border: 0;
  border-top: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  text-align: left;
}

.account-menu__panel button:hover,
.account-menu__panel button:focus-visible {
  color: var(--gold-dark);
}

.panel-head {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 16px;
}

.panel-kicker {
  margin: 0 0 6px;
  color: #426471;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
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

.purchase-item {
  border: 1px solid var(--line);
  background: #fff;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.purchase-item {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 130px auto;
  align-items: center;
  gap: 14px;
}

.purchase-item span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.purchase-list {
  display: grid;
  gap: 8px;
  margin-top: 16px;
}

.purchase-item__meta {
  text-align: right;
}

.remove-order-btn {
  min-height: 34px;
  border: 1px solid transparent;
  background: #f5f8fa;
  color: #5e737c;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
  margin-top: 10px;
  padding: 0 12px;
  text-transform: uppercase;
}

.remove-order-btn:hover,
.remove-order-btn:focus-visible {
  border-color: #b7ccd6;
  background: #fff;
  color: #2c5968;
}

.remove-order-btn:disabled {
  cursor: not-allowed;
  opacity: 0.55;
}

.account-cart-list {
  display: grid;
  gap: 8px;
  margin-top: 16px;
}

.account-cart-item {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 150px;
  align-items: center;
  gap: 14px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.account-cart-item span,
.account-cart-item small,
.checkout-summary span,
.checkout-summary small,
.checkout-payment span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.account-cart-item small {
  margin-top: 2px;
}

.account-cart-item__meta {
  text-align: right;
}

.account-checkout-box {
  display: grid;
  grid-template-columns: minmax(180px, 0.8fr) minmax(260px, 1fr) auto;
  align-items: center;
  gap: 14px;
  border: 1px solid var(--line);
  background: #f8fbfc;
  margin-top: 16px;
  padding: 14px;
}

.checkout-summary strong {
  display: block;
  margin-top: 2px;
  font-size: 22px;
  font-weight: 500;
}

.checkout-payment {
  display: grid;
  gap: 8px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.payment-options {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.payment-options label {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  border: 1px solid #cfdce1;
  background: #fff;
  color: #2d3f47;
  cursor: pointer;
  font-size: 13px;
  font-weight: 700;
  min-height: 38px;
  padding: 0 10px;
}

.empty-orders {
  border: 1px solid var(--line);
  background: var(--paper);
  margin-top: 16px;
  padding: 16px;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 40;
  display: grid;
  place-items: center;
  background: rgba(9, 18, 32, 0.46);
  padding: 18px;
}

.modal-panel {
  width: min(680px, 100%);
  max-height: min(92vh, 820px);
  overflow: auto;
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.modal-panel__header {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 16px;
}

.modal-panel__header span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.modal-panel__header h2 {
  margin: 4px 0 0;
}

.modal-panel__header button {
  width: 36px;
  height: 36px;
  border: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.billing-modal {
  width: min(720px, 100%);
  max-height: min(92vh, 860px);
  overflow: auto;
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.modal-head {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 16px;
}

.modal-head h2 {
  margin: 0;
  font-size: 30px;
  font-weight: 400;
}

.modal-close {
  width: 36px;
  height: 36px;
  border: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  text-transform: uppercase;
}

.billing-modal .billing-form {
  border: 0;
  padding: 0;
}

.modal-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
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
  .account-intro,
  .account-overview,
  .field-grid,
  .purchase-item,
  .account-cart-item,
  .account-checkout-box {
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

  .account-metrics {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .account-menu,
  .account-menu__panel {
    position: static;
    width: 100%;
  }

  .purchase-item__meta,
  .account-cart-item__meta {
    text-align: left;
  }

  .modal-actions .primary-btn,
  .modal-actions .ghost-btn {
    width: 100%;
  }
}
</style>
