<template>
  <div class="page-shell">
    <SiteTopStrip
      :labels="t"
      :show-office-email="true"
    />
    <SiteHeader
      :brand-name="brandName"
      :cart-count="cartCount"
      :labels="t"
      :languages="languages"
      :selected-language="selectedLanguage"
      @update:selected-language="setLanguage"
    />

    <main>
      <HomeHeroSection
        :hero-image-url="heroHomeUrl"
        :labels="t"
        @open-order-form="openOrderForm"
      />

      <HomePricingSection
        :currencies="currencies"
        :labels="t"
        :plans="visiblePlans"
        :selected-currency="selectedCurrency"
        :selected-product-code="selectedProductCode"
        @open-order-form="openOrderForm"
        @update:selected-currency="selectedCurrency = $event"
      />

      <HomeRenewalSection
        :labels="t"
        :plans="renewalPlans"
        :selected-product-code="selectedProductCode"
        @open-order-form="openOrderForm"
      />

      <HomeStartBand
        :labels="t"
        @open-verification-form="openVerificationForm"
      />

      <HomeMonitoringSection
        :can-submit="canAddMonitoringToCart"
        :error="monitoringError"
        :form="monitoringForm"
        :labels="t"
        :message="cartMessage"
        :nice-classes="niceClasses"
        :price-label="monitoringPriceLabel"
        :selected-language="selectedLanguage"
        @add-monitoring-to-cart="addMonitoringToCart"
        @update:form="updateMonitoringForm"
      />

      <HomeContactSection
        :error="contactError"
        :form="contactForm"
        :labels="t"
        :submitting="contactSubmitting"
        :success="contactSuccess"
        @submit="submitContactMessage"
        @update:form="updateContactForm"
      />
    </main>

    <SiteFooter
      :brand-name="brandName"
      :copyright-text="copyrightText"
      :footer-copy="footerCopy"
      :labels="t"
      @open-order-form="openOrderForm"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { niceClasses2024 } from '~/data/niceClasses2024'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import heroHomeUrl from '../assets/images/home_img.png'
import verbalTrademarkUrl from '../assets/images/MARCA_TA_VERBALA-removebg-preview.png'

const currencies = [
  { code: 'RON', label: 'OSIM' },
  { code: 'EUR', label: 'EUIPO' },
]
const selectedCurrency = ref('RON')
const selectedProductCode = ref('ro-word')
const productCatalog = ref([])
const siteTheme = ref({})
const cartMessage = ref('')
const monitoringError = ref('')
const contactSubmitting = ref(false)
const contactError = ref('')
const contactSuccess = ref('')
const config = useRuntimeConfig()

const {
  languages,
  locale,
  selectedLanguage,
  setLanguage: setPreferredLanguage,
  t,
} = usePreferredLanguage('home')
const {
  addCartItem,
  cartCount,
  loadCart,
} = useCart()
const brandName = computed(() => siteTheme.value.brand_name || 'SANDU și Asociații IP Attorney')
const footerCopy = computed(() => siteTheme.value.footer_text || t.value.footerCopy)
const copyrightText = computed(() => `© 2026 ${brandName.value}. ${t.value.rightsReserved}`)

useHead(() => ({
  title: t.value.metaTitle,
}))

const monitoringForm = reactive({
  mark: '',
  offices: ['RO', 'EM'],
  classes: [],
  notes: '',
  terms: false,
})
const contactForm = reactive({
  name: '',
  email: '',
  phone: '',
  message: '',
})

const productImages = {
  verbal: verbalTrademarkUrl,
  black_white: blackWhiteTrademarkUrl,
  color: colorTrademarkUrl,
}

const plans = computed(() => productCatalog.value.map((product) => {
  const translatedProduct = product.translations?.[selectedLanguage.value] || t.value.products[product.code]

  return {
    ...product,
    ...translatedProduct,
    image: product.image || productImages[product.image_key],
    baseLei: product.baseLei ?? product.base_lei,
  }
}))
function niceClassTitle(niceClass) {
  const text = selectedLanguage.value === 'ro' ? niceClass.officialRo : niceClass.summaryEn
  return text.split(';')[0].trim()
}

const niceClasses = computed(() => niceClasses2024.map(niceClass => ({
  ...niceClass,
  title: niceClassTitle(niceClass),
  label: selectedLanguage.value === 'ro'
    ? `Clasa ${niceClass.number}: ${niceClassTitle(niceClass)}`
    : `Class ${niceClass.number}: ${niceClassTitle(niceClass)}`,
  value: selectedLanguage.value === 'ro'
    ? `Clasa ${niceClass.number}: ${niceClassTitle(niceClass)}`
    : `Class ${niceClass.number}: ${niceClassTitle(niceClass)}`,
  typeLabel: niceClass.type === 'goods' ? t.value.niceGoods : t.value.niceServices,
  detail: selectedLanguage.value === 'ro' ? niceClass.officialRo : niceClass.summaryEn,
})))
const registrationPlans = computed(() => plans.value.filter(plan => !isRenewalCode(plan.code) && !isMonitoringCode(plan.code) && !isVerificationCode(plan.code)))
const renewalPlans = computed(() => plans.value.filter(plan => isRenewalCode(plan.code)))
const visiblePlans = computed(() => registrationPlans.value.filter(plan => plan.currency === selectedCurrency.value))
const monitoringProduct = computed(() => plans.value.find(plan => plan.code === 'monitoring-brand') || t.value.products['monitoring-brand'])
const monitoringTotal = computed(() => Number(monitoringProduct.value?.baseLei || monitoringProduct.value?.base_lei || 726))
const monitoringPriceLabel = computed(() => formatMoney(monitoringTotal.value, 'RON'))
const canAddMonitoringToCart = computed(() => monitoringForm.mark.trim().length >= 2 && monitoringForm.terms)

async function loadProducts() {
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/trademark_products`)
    const payload = await response.json().catch(() => ({}))

    if (!response.ok || !Array.isArray(payload.products)) return

    productCatalog.value = payload.products

    if (!productCatalog.value.some(product => product.code === selectedProductCode.value)) {
      selectedProductCode.value = productCatalog.value[0]?.code || ''
    }
  }
  catch {
    productCatalog.value = []
  }
}

async function loadSiteTheme() {
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/site_theme`)
    const payload = await response.json().catch(() => ({}))

    if (response.ok) siteTheme.value = payload.theme || {}
  }
  catch {
    siteTheme.value = {}
  }
}

function isRenewalCode(code) {
  return code?.startsWith('renew-')
}

function isMonitoringCode(code) {
  return code?.startsWith('monitoring-')
}

function isVerificationCode(code) {
  return code?.startsWith('verification-')
}

function formatMoney(amount, currency = 'RON') {
  const suffix = currency === 'EUR' ? 'EUR' : 'Lei'
  return `${Number(amount || 0).toLocaleString(locale.value)} ${suffix}`
}

function openOrderForm(code = selectedProductCode.value) {
  navigateTo({
    path: '/order',
    query: { code },
  })
}

function openVerificationForm() {
  const verificationCode = plans.value.find(plan => isVerificationCode(plan.code))?.code || 'verification-brand'
  openOrderForm(verificationCode)
}

function setLanguage(code) {
  setPreferredLanguage(code)
}

function updateMonitoringForm(updatedForm) {
  Object.assign(monitoringForm, updatedForm)
}

function updateContactForm(updatedForm) {
  Object.assign(contactForm, updatedForm)
}

function monitoringGoodsDescription() {
  const offices = monitoringForm.offices.length ? monitoringForm.offices.join(', ') : 'OSIM, EUIPO, WIPO'
  const classes = monitoringForm.classes.length ? monitoringForm.classes.join(', ') : '-'
  const notes = monitoringForm.notes.trim() || '-'
  return `Oficii monitorizate: ${offices}\nClase NISA urmarite: ${classes}\nObservatii: ${notes}`
}

function addMonitoringToCart() {
  monitoringError.value = ''
  cartMessage.value = ''

  if (!canAddMonitoringToCart.value) {
    monitoringError.value = !monitoringForm.mark ? t.value.missingMark : t.value.missingTerms
    return
  }

  addCartItem({
    id: crypto.randomUUID(),
    productCode: 'monitoring-brand',
    productTitle: monitoringProduct.value?.title || t.value.products['monitoring-brand'].title,
    mark: monitoringForm.mark,
    classes: 1,
    primaryClass: t.value.monitoringPrimaryClass,
    goods: monitoringGoodsDescription(),
    ownerChangeRequested: false,
    terms: monitoringForm.terms,
    total: monitoringTotal.value,
    currency: 'RON',
    formattedTotal: monitoringPriceLabel.value,
  })
  cartMessage.value = t.value.cartAdded
}

async function submitContactMessage() {
  contactError.value = ''
  contactSuccess.value = ''
  contactSubmitting.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/contact_messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contact_message: {
          name: contactForm.name,
          email: contactForm.email,
          phone: contactForm.phone,
          message: contactForm.message,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || t.value.contactError)
    }

    contactForm.name = ''
    contactForm.email = ''
    contactForm.phone = ''
    contactForm.message = ''
    contactSuccess.value = payload.message || t.value.contactSuccess
  }
  catch (error) {
    contactError.value = error instanceof Error ? error.message : t.value.contactError
  }
  finally {
    contactSubmitting.value = false
  }
}

onMounted(() => {
  loadCart()
  loadProducts()
  loadSiteTheme()
})
</script>

<style>
:root {
  color-scheme: light;
  --ink: #1f1d1a;
  --muted: #68635c;
  --line: #ded8cf;
  --paper: #fff;
  --cream: #fff;
  --gold: #00add9;
  --gold-dark: #00add9;
  --brand: #013ebe;
  --font-family: 'Montserrat', sans-serif;
  --green: #52695a;
}

* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
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
.main-header__inner,
.site-footer__inner {
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

.language-switcher {
  display: inline-flex;
  border: 1px solid var(--line);
}

.language-switcher button {
  width: 38px;
  height: 30px;
  border: 0;
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 11px;
  font-weight: 700;
}

.language-switcher button + button {
  border-left: 1px solid var(--line);
}

.language-switcher button.active {
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

.hero {
  background:
    linear-gradient(90deg, rgba(8, 22, 50, 0.86), rgba(8, 22, 50, 0.56), rgba(8, 22, 50, 0.28)),
    var(--hero-image, var(--fallback-hero-image)) center / cover no-repeat,
    var(--brand);
  color: #fffaf2;
}

.hero__grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 48px;
  min-height: 440px;
  align-items: center;
  padding: 56px 0;
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

.hero .eyebrow {
  color: #fffaf2;
}

.hero h1 {
  max-width: 760px;
  margin: 0;
  font-size: clamp(40px, 7vw, 76px);
  font-weight: 400;
  line-height: 0.98;
}

.lead {
  max-width: 680px;
  margin: 24px 0 0;
  color: #eee3d1;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 18px;
  line-height: 1.7;
}

.hero__actions {
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
  margin-top: 34px;
}

.primary-btn,
.outline-btn,
.outline-light-btn,
.register-btn,
.ghost-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border: 0;
  border-radius: 2px;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  letter-spacing: 0.06em;
  text-decoration: none;
  text-transform: uppercase;
}

.primary-btn,
.register-btn {
  background: var(--gold);
  color: #fff;
  padding: 0 22px;
}

.text-link {
  color: #fff;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  text-underline-offset: 4px;
}

.outline-light-btn {
  border: 1px solid rgba(255, 255, 255, 0.72);
  background: transparent;
  color: #fffaf2;
  padding: 0 20px;
}

.secure-panel {
  display: grid;
  grid-template-columns: 72px 1fr;
  gap: 16px;
  align-items: center;
  border: 1px solid rgba(255, 255, 255, 0.34);
  background: rgba(255, 255, 255, 0.08);
  padding: 24px;
}

.secure-panel__icon {
  display: grid;
  place-items: center;
  height: 72px;
  border: 1px solid rgba(255, 255, 255, 0.55);
  color: #f6dfad;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.secure-panel strong,
.secure-panel span {
  display: block;
}

.secure-panel strong {
  font-size: 22px;
  font-weight: 400;
}

.secure-panel span {
  margin-top: 8px;
  color: #eadfcd;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 14px;
  line-height: 1.5;
}

.pricing-section,
.form-section,
.cart-section,
.account-section,
.contact-section,
.monitoring-section {
  padding: 64px 0;
}

.cart-section {
  border-top: 1px solid var(--line);
  background: #fff;
}

.monitoring-section {
  background: #fff;
  border-bottom: 1px solid var(--line);
}

.monitoring-shell {
  display: grid;
  gap: 28px;
}

.monitoring-header {
  max-width: 860px;
}

.monitoring-header h2 {
  margin: 0;
  font-size: 42px;
  font-weight: 400;
}

.monitoring-layout {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 28px;
  align-items: stretch;
}

.monitoring-copy {
  display: grid;
  align-content: start;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 24px;
}

.monitoring-copy p {
  line-height: 1.65;
}

.monitoring-benefits {
  display: grid;
  gap: 12px;
  margin-top: 22px;
  border-top: 1px solid var(--line);
  padding-top: 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.monitoring-benefits ul {
  margin: 0;
  padding-left: 18px;
  color: var(--muted);
  line-height: 1.6;
}

.monitoring-benefit {
  border-left: 4px solid var(--gold);
  background: var(--paper);
  padding: 14px 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.monitoring-panel {
  justify-self: end;
  display: grid;
  gap: 18px;
  width: 100%;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 24px;
}

.monitoring-form {
  display: grid;
  gap: 16px;
  width: 100%;
}

.monitoring-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.monitoring-form .checkbox {
  display: flex;
  align-items: center;
}

.monitoring-form .checkbox input {
  margin-top: 0;
}

.monitoring-form input:not([type="checkbox"]),
.monitoring-form select,
.monitoring-form textarea {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.monitoring-form textarea {
  resize: vertical;
}

.monitoring-form select[multiple] {
  min-height: 150px;
}

.monitoring-price {
  display: grid;
  gap: 4px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.monitoring-price span,
.monitoring-price small {
  color: var(--muted);
}

.monitoring-price strong {
  font-size: 34px;
  font-weight: 700;
}

.monitoring-results {
  display: grid;
  gap: 12px;
}

.monitoring-results__head,
.monitoring-item {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.monitoring-results__head {
  align-items: center;
}

.monitoring-results__head span,
.monitoring-item span,
.monitoring-item small {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.monitoring-item small {
  margin-top: 4px;
}

.renewal-section {
  padding: 96px 0;
  background: #f4fbfd;
}

.renewal-layout {
  display: grid;
  gap: 30px;
}

.renewal-copy h2 {
  margin: 0 0 18px;
  font-family: var(--display-font-family, 'Playfair Display', serif);
  font-size: 46px;
  font-weight: 500;
  line-height: 1;
}

.renewal-copy {
  max-width: 900px;
}

.renewal-benefits {
  margin-top: 24px;
  display: grid;
  gap: 12px;
  border-top: 1px solid var(--line);
  padding-top: 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.renewal-benefits ul {
  margin: 0;
  padding-left: 18px;
  color: var(--muted);
  line-height: 1.6;
}

.renewal-plans {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}

.renewal-card {
  min-height: 0;
  background: #fff;
  padding: 20px;
}

.renewal-card .price-card__top {
  min-height: 0;
}

.renewal-card .price {
  margin: 16px 0;
}

.renewal-card ul {
  margin-bottom: 18px;
}

.cart-layout {
  display: grid;
  grid-template-columns: 330px minmax(0, 1fr);
  gap: 28px;
  align-items: start;
}

.cart-layout h2 {
  margin: 0;
  font-size: 42px;
  font-weight: 400;
}

.cart-panel {
  display: grid;
  gap: 16px;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 24px;
}

.cart-list {
  display: grid;
  gap: 12px;
}

.cart-item,
.checkout-box {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.cart-item span,
.cart-item small,
.checkout-box span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.cart-item small {
  margin-top: 4px;
}

.cart-item div:last-child {
  min-width: 130px;
  text-align: right;
}

.checkout-box {
  align-items: center;
  flex-wrap: wrap;
}

.checkout-summary {
  min-width: 180px;
}

.checkout-summary small {
  display: block;
  margin-top: 6px;
  color: var(--muted);
  line-height: 1.5;
}

.checkout-payment {
  display: grid;
  gap: 10px;
  min-width: min(100%, 320px);
}

.checkout-payment .payment-options {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.checkout-payment .payment-options label {
  align-items: flex-start;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 10px;
}

.checkout-box strong {
  display: block;
  margin-top: 4px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 30px;
  font-weight: 400;
}

.text-danger {
  border: 0;
  background: transparent;
  color: #8f3d22;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  margin-top: 8px;
  padding: 0;
}

.section-head {
  text-align: center;
}

.section-head h2,
.start-band h2,
.form-summary h2,
.registration-form h2 {
  margin: 0;
  font-weight: 400;
}

.section-head h2 {
  font-size: 42px;
}

.currency-tabs {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin: 28px 0;
}

.currency-tabs button {
  width: 72px;
  height: 42px;
  border: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
}

.currency-tabs button.active {
  background: #2b2926;
  border-color: #2b2926;
  color: #fff;
}

.price-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.price-card {
  display: flex;
  flex-direction: column;
  min-height: 460px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 28px;
}

.price-card.selected {
  border-color: var(--gold);
  box-shadow: inset 0 0 0 2px rgba(0, 173, 217, 0.25);
}

.price-card__top {
  min-height: 126px;
}

.country-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 40px;
  height: 28px;
  border: 1px solid var(--gold);
  color: var(--gold-dark);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
}

.price-card h3 {
  margin: 16px 0 6px;
  font-size: 25px;
  font-weight: 400;
  text-transform: uppercase;
}

.price-card__image {
  display: block;
  max-width: 170px;
  height: 42px;
}

.price-card p,
.muted {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.6;
}

.price {
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  margin: 18px 0;
  padding: 18px 0;
}

.price span {
  display: block;
  font-size: 38px;
}

.price small {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.price-card ul {
  display: grid;
  gap: 10px;
  margin: 0 0 22px;
  padding: 0;
  list-style: none;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.45;
}

.price-card li::before {
  content: '+';
  margin-right: 8px;
  color: var(--gold-dark);
  font-weight: 700;
}

.register-btn {
  width: 100%;
  margin-top: auto;
}

.card-foot {
  margin: 12px 0 0;
  text-align: center;
  font-size: 12px;
}

.empty-products {
  border: 1px solid var(--line);
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  margin: 18px 0 0;
  padding: 18px;
  text-align: center;
}

.start-band {
  background: var(--cream);
  border-block: 1px solid var(--line);
  padding: 36px 0;
}

.start-band__inner {
  display: grid;
  grid-template-columns: 1.1fr 1.4fr auto;
  gap: 28px;
  align-items: center;
}

.start-band h2 {
  font-size: 32px;
}

.start-band p {
  margin: 0;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.6;
}

.outline-btn,
.ghost-btn {
  border: 1px solid var(--gold);
  background: transparent;
  color: var(--gold-dark);
  padding: 0 20px;
}

.form-layout {
  display: grid;
  grid-template-columns: 330px minmax(0, 1fr);
  gap: 28px;
  align-items: start;
}

.form-summary,
.registration-form {
  border: 1px solid var(--line);
  background: #fff;
  padding: 28px;
}

.form-summary {
  position: sticky;
  top: 110px;
}

.form-summary h2 {
  margin-top: 16px;
  font-size: 32px;
  text-transform: uppercase;
}

.summary-box {
  display: grid;
  gap: 8px;
  margin: 24px 0;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.summary-box span,
.summary-box small {
  color: var(--muted);
}

.summary-box strong {
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 30px;
  font-weight: 400;
}

.steps {
  display: grid;
  gap: 12px;
  margin: 0;
  padding: 0;
  list-style: none;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.steps li {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--muted);
}

.steps span {
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border: 1px solid var(--line);
  border-radius: 50%;
}

.steps li.active {
  color: var(--ink);
  font-weight: 700;
}

.steps li.active span {
  border-color: var(--gold);
  background: var(--gold);
  color: #191713;
}

.registration-form h2 {
  font-size: 34px;
}

.form-step {
  display: grid;
  gap: 18px;
}

.registration-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.registration-form input,
.registration-form select,
.registration-form textarea {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.nisa-picker {
  position: relative;
}

.nisa-picker__trigger {
  width: 100%;
  min-height: 48px;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  padding: 13px 14px;
  text-align: left;
}

.nisa-picker__trigger.empty {
  color: var(--muted);
}

.nisa-picker__menu {
  position: absolute;
  inset-inline: 0;
  top: calc(100% + 6px);
  z-index: 20;
  display: grid;
  max-height: 320px;
  overflow: auto;
  border: 1px solid var(--line);
  background: #fff;
  box-shadow: 0 18px 48px rgba(13, 31, 46, 0.14);
}

.nisa-picker__option {
  position: relative;
  display: grid;
  gap: 3px;
  border: 0;
  border-bottom: 1px solid var(--line);
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  padding: 12px 14px;
  text-align: left;
}

.nisa-picker__option:hover,
.nisa-picker__option:focus-visible,
.nisa-picker__option.selected {
  background: #f4fbfd;
}

.nisa-picker__option small {
  color: var(--muted);
  font-size: 12px;
}

.nisa-picker__tooltip {
  position: absolute;
  left: calc(100% + 10px);
  top: 8px;
  z-index: 30;
  display: none;
  width: min(360px, calc(100vw - 40px));
  border: 1px solid var(--line);
  background: #1f1d1a;
  color: #fff;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 400;
  line-height: 1.55;
  padding: 12px;
}

.nisa-picker__option:hover .nisa-picker__tooltip,
.nisa-picker__option:focus-visible .nisa-picker__tooltip {
  display: block;
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.included-box,
.payment-card {
  display: grid;
  gap: 8px;
  border-left: 4px solid var(--gold);
  background: var(--paper);
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.nice-class-details {
  display: grid;
  gap: 12px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 16px;
}

.nice-class-details__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  flex-wrap: wrap;
}

.nice-class-details strong {
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.nice-class-details p,
.nice-class-details small {
  margin: 0;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.6;
}

.payment-options {
  display: grid;
  gap: 12px;
}

.payment-options label,
.checkbox {
  display: flex;
  grid-template-columns: none;
  flex-direction: row;
  align-items: flex-start;
  gap: 10px;
}

.payment-options input,
.checkbox input {
  flex: 0 0 auto;
  margin-top: 3px;
  width: auto;
}

.registration-form .checkbox {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  align-items: start;
}

.checkbox span {
  min-width: 0;
  line-height: 1.5;
}

.payment-card strong {
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 34px;
  font-weight: 400;
}

.payment-card small {
  color: var(--muted);
}

.form-actions {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-top: 28px;
  border-top: 1px solid var(--line);
  padding-top: 22px;
}

.ghost-btn:disabled {
  cursor: not-allowed;
  opacity: 0.45;
}

.success-message {
  margin: 18px 0 0;
  border: 1px solid #b9c7bd;
  background: #edf4ef;
  color: var(--green);
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
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

.account-section {
  border-top: 1px solid var(--line);
  background: #fff;
}

.account-layout {
  display: grid;
  grid-template-columns: minmax(0, 0.78fr) minmax(0, 1.22fr);
  gap: 32px;
  align-items: start;
}

.account-copy h2 {
  margin: 0;
  font-size: 42px;
  font-weight: 400;
}

.account-copy p:not(.eyebrow) {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 16px;
  line-height: 1.7;
}

.account-panel {
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 24px;
}

.account-search {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  align-items: end;
}

.account-search label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.account-search input {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.auth-mode {
  display: inline-flex;
  border: 1px solid var(--line);
}

.auth-mode button {
  min-height: 44px;
  border: 0;
  background: #fff;
  color: var(--ink);
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  padding: 0 16px;
}

.auth-mode button + button {
  border-left: 1px solid var(--line);
}

.auth-mode button.active {
  background: #2b2926;
  color: #fff;
}

.signed-in-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.signed-in-bar span {
  display: block;
  color: var(--muted);
  margin-bottom: 4px;
}

.auth-note {
  margin: 18px 0 0;
}

.account-result {
  display: grid;
  gap: 16px;
  margin-top: 18px;
}

.account-total,
.purchase-item {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.account-total {
  align-items: center;
}

.account-total span,
.account-total small,
.purchase-item span {
  display: block;
  color: var(--muted);
  line-height: 1.5;
}

.purchase-list {
  display: grid;
  gap: 10px;
}

.purchase-item div:last-child {
  text-align: right;
}

.contact-section {
  border-top: 1px solid var(--line);
  background: var(--paper);
}

.contact-layout {
  display: grid;
  grid-template-columns: minmax(0, 0.82fr) minmax(0, 1.18fr);
  gap: 32px;
  align-items: start;
}

.contact-copy h2 {
  margin: 0;
  font-size: 42px;
  font-weight: 400;
}

.contact-details {
  display: grid;
  gap: 14px;
  margin-top: 24px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.contact-details div {
  display: grid;
  gap: 5px;
  border-left: 4px solid var(--gold);
  background: #fff;
  padding: 14px 16px;
}

.contact-details span {
  color: var(--muted);
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
}

.contact-details strong,
.contact-details a {
  color: var(--ink);
  line-height: 1.45;
  text-decoration: none;
}

.contact-details a:hover {
  color: var(--gold-dark);
  text-decoration: underline;
  text-underline-offset: 4px;
}

.contact-form {
  display: grid;
  gap: 16px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 28px;
}

.contact-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.contact-form input,
.contact-form textarea {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.contact-form .primary-btn {
  justify-self: start;
}

@media (max-width: 980px) {
  .main-header__inner,
  .top-strip__inner,
  .start-band__inner,
  .form-layout,
  .cart-layout,
  .account-layout,
  .contact-layout,
  .monitoring-layout,
  .renewal-layout,
  .hero__grid {
    grid-template-columns: 1fr;
  }

  .main-header__inner,
  .top-strip__inner {
    align-items: flex-start;
    flex-direction: column;
    padding: 14px 0;
  }

  .hero__grid,
  .form-layout,
  .cart-layout,
  .account-layout {
    display: grid;
  }

  .price-grid {
    grid-template-columns: 1fr;
  }

  .renewal-plans {
    grid-template-columns: 1fr;
  }

  .form-summary {
    position: static;
  }

  .nisa-picker__tooltip {
    left: 0;
    top: calc(100% + 6px);
  }
}

@media (max-width: 640px) {
  .wrap {
    width: min(100% - 22px, 1120px);
  }

  .hero__grid {
    min-height: auto;
    padding: 42px 0;
  }

  .hero h1 {
    font-size: 42px;
  }

  .secure-panel,
  .field-grid {
    grid-template-columns: 1fr;
  }

  .pricing-section,
  .renewal-section,
  .form-section,
  .cart-section,
  .account-section,
  .contact-section,
  .monitoring-section {
    padding: 42px 0;
  }

  .form-summary,
  .registration-form,
  .cart-panel,
  .account-panel,
  .contact-form,
  .monitoring-panel,
  .price-card {
    padding: 20px;
  }

  .form-actions {
    flex-direction: column-reverse;
  }

  .form-actions .primary-btn,
  .form-actions .ghost-btn {
    width: 100%;
  }

  .account-search,
  .signed-in-bar,
  .account-total,
  .cart-item,
  .checkout-box,
  .purchase-item,
  .contact-form .field-grid,
  .monitoring-results__head,
  .monitoring-item {
    grid-template-columns: 1fr;
    flex-direction: column;
    align-items: stretch;
  }

  .account-search .primary-btn {
    width: 100%;
  }

  .purchase-item div:last-child {
    text-align: left;
  }

  .checkout-payment .payment-options {
    grid-template-columns: 1fr;
  }

  .cart-item div:last-child {
    min-width: 0;
    text-align: left;
  }

}
</style>
