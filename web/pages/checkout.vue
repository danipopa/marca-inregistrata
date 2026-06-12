<template>
  <div class="checkout-page">
    <SiteTopStrip :labels="t" />
    <SiteHeader
      :cart-count="cartCount"
      :labels="t"
      :languages="languages"
      :selected-language="selectedLanguage"
      :show-account="true"
      :show-cart="false"
      :show-check="false"
      @update:selected-language="setLanguage"
    />

    <main class="checkout-main">
      <section class="wrap checkout-layout">
        <CheckoutIntro :labels="t" />

        <CheckoutPanel
          :account-checkout-status="accountCheckoutStatus"
          :authenticated="Boolean(authToken)"
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
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'

const config = useRuntimeConfig()
const checkoutPayment = ref('card')
const submittingCheckout = ref(false)
const checkoutMessage = ref('')
const checkoutError = ref('')

const {
  languages,
  locale,
  selectedLanguage,
  setLanguage,
  t,
} = usePreferredLanguage('checkout')

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
  authToken,
  currentUser,
  verifyStoredSession,
} = useAuthSession()
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

function formatMoney(amount, currency = 'RON') {
  const suffix = currency === 'EUR' ? 'EUR' : 'Lei'
  return `${Number(amount || 0).toLocaleString(locale.value)} ${suffix}`
}

function errorMessage(payload, fallback) {
  if (payload?.message) return payload.message
  if (!payload?.errors) return fallback

  return Object.entries(payload.errors)
    .map(([field, messages]) => `${field} ${Array.isArray(messages) ? messages.join(', ') : messages}`)
    .join('; ') || fallback
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

    clearCart()
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
  loadCart()
  verifyStoredSession()
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

@media (max-width: 900px) {
  .checkout-layout {
    grid-template-columns: 1fr;
  }

  .top-strip__inner,
  .main-header__inner {
    align-items: stretch;
    flex-direction: column;
  }
}
</style>
