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

    <main class="order-main">
      <section class="wrap order-intro">
        <div>
          <p class="eyebrow">
            {{ t.wizardEyebrow }}
          </p>
          <h1>{{ t.wizardTitle }}</h1>
          <p class="lead">
            {{ t.wizardCopy }}
          </p>
        </div>
        <NuxtLink
          class="outline-btn"
          to="/"
        >
          {{ t.backToHome }}
        </NuxtLink>
      </section>

      <HomeOrderFormSection
        :cart-message="cartMessage"
        :class-label="classLabel"
        :current-step="currentStep"
        :form="form"
        :formatted-total="formattedTotal"
        :is-osim-renewal-product="Boolean(isOsimRenewalProduct)"
        :labels="t"
        :nice-classes="niceClasses"
        :nisa-picker-open="nisaPickerOpen"
        :plans="orderFormPlans"
        :selected-nice-class="selectedNiceClass"
        :selected-product="selectedProduct"
        :selected-product-code="selectedProductCode"
        :steps="steps"
        :submit-error="submitError"
        :visible="true"
        @add-to-cart="addToCart"
        @select-nice-class="selectNiceClass"
        @update:current-step="currentStep = $event"
        @update:form="updateOrderForm"
        @update:nisa-picker-open="nisaPickerOpen = $event"
        @update:selected-product-code="selectProduct"
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
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { niceClasses2024 } from '~/data/niceClasses2024'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import verbalTrademarkUrl from '../assets/images/MARCA_TA_VERBALA-removebg-preview.png'

const config = useRuntimeConfig()
const route = useRoute()
const selectedProductCode = ref('')
const productCatalog = ref([])
const siteTheme = ref({})
const currentStep = ref(0)
const cartMessage = ref('')
const submitError = ref('')
const nisaPickerOpen = ref(false)

const {
  languages,
  locale,
  selectedLanguage,
  setLanguage,
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
const steps = computed(() => t.value.steps)

useHead(() => ({
  title: t.value.wizardMetaTitle,
}))

const form = reactive({
  mark: '',
  classes: 1,
  primaryClass: '',
  goods: '',
  ownerChangeRequested: false,
  terms: false,
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
const orderFormPlans = computed(() => plans.value.filter(plan => !isMonitoringCode(plan.code)))
const selectedProduct = computed(() => plans.value.find(plan => plan.code === selectedProductCode.value) || plans.value[0] || null)
const selectedProductCurrency = computed(() => selectedProduct.value?.currency || 'RON')
const isOsimRenewalProduct = computed(() => selectedProduct.value && isOsimRenewalCode(selectedProduct.value.code))
const total = computed(() => selectedProduct.value ? selectedProduct.value.baseLei + extraClassTotal(form.classes, selectedProduct.value.code) + ownerChangeTotal.value : 0)
const ownerChangeTotal = computed(() => isOsimRenewalProduct.value && form.ownerChangeRequested ? 477 : 0)
const formattedTotal = computed(() => formatMoney(total.value, selectedProductCurrency.value))
const selectedNiceClass = computed(() => niceClasses.value.find(niceClass => niceClass.value === form.primaryClass))
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

function niceClassTitle(niceClass) {
  const text = selectedLanguage.value === 'ro' ? niceClass.officialRo : niceClass.summaryEn
  return text.split(';')[0].trim()
}

function isOsimRenewalCode(code) {
  return code?.startsWith('renew-ro-')
}

function isMonitoringCode(code) {
  return code?.startsWith('monitoring-')
}

function isEuipoCode(code) {
  return code?.startsWith('eu-') || code?.startsWith('renew-eu-')
}

function isOsimCode(code) {
  return code?.startsWith('ro-') || code?.startsWith('renew-ro-')
}

function formatMoney(amount, currency = 'RON') {
  const suffix = currency === 'EUR' ? 'EUR' : 'Lei'
  return `${Number(amount || 0).toLocaleString(locale.value)} ${suffix}`
}

function extraClassTotal(count, productCode) {
  const classCount = Math.max(1, Math.min(Number(count || 1), 11))
  if (isOsimCode(productCode)) return (classCount - 1) * 254
  if (isEuipoCode(productCode)) {
    return {
      1: 0,
      2: 50,
      3: 200,
      4: 350,
      5: 500,
      6: 650,
      7: 800,
      8: 950,
      9: 1100,
      10: 1250,
      11: 1400,
    }[classCount] || 0
  }
  return (classCount - 1) * 449
}

function classLabel(count) {
  if (count === 1) return t.value.oneClass
  if (selectedProduct.value) {
    return t.value.renewalMultipleClasses(count, extraClassTotal(count, selectedProduct.value.code), selectedProductCurrency.value === 'EUR' ? 'EUR' : 'Lei')
  }
  return t.value.multipleClasses(count)
}

function selectProduct(code) {
  selectedProductCode.value = code
  if (!isOsimRenewalCode(code)) form.ownerChangeRequested = false
}

function openOrderForm(code = selectedProductCode.value) {
  navigateTo({
    path: '/order',
    query: { code },
  })
}

function updateOrderForm(updatedForm) {
  Object.assign(form, updatedForm)
}

function selectNiceClass(niceClass) {
  form.primaryClass = niceClass.value
  nisaPickerOpen.value = false
}

function buildCartItem() {
  if (!selectedProduct.value) return null

  return {
    id: crypto.randomUUID(),
    productCode: selectedProductCode.value,
    productTitle: selectedProduct.value.title,
    mark: form.mark,
    classes: form.classes,
    primaryClass: form.primaryClass,
    goods: form.goods,
    ownerChangeRequested: isOsimRenewalProduct.value && form.ownerChangeRequested,
    terms: form.terms,
    total: total.value,
    currency: selectedProductCurrency.value,
    formattedTotal: formattedTotal.value,
  }
}

function addToCart() {
  submitError.value = ''
  cartMessage.value = ''

  if (!selectedProduct.value || !form.mark || !form.primaryClass || !form.terms) {
    if (!form.mark) submitError.value = t.value.missingMark
    else if (!form.primaryClass) submitError.value = t.value.missingNiceClass
    else if (!form.terms) submitError.value = t.value.missingTerms
    else submitError.value = t.value.submitError
    return
  }

  const cartItem = buildCartItem()
  if (!cartItem) return

  addCartItem(cartItem)
  cartMessage.value = t.value.cartAdded
}

async function loadProducts() {
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/trademark_products`)
    const payload = await response.json().catch(() => ({}))

    if (!response.ok || !Array.isArray(payload.products)) return

    productCatalog.value = payload.products

    const routeCode = route.query.code?.toString() || ''
    const fallbackCode = payload.products[0]?.code || ''
    const targetCode = payload.products.some(product => product.code === routeCode) ? routeCode : fallbackCode
    if (targetCode) selectedProductCode.value = targetCode
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

watch(
  () => route.query.code,
  (code) => {
    if (!code) return
    const value = code.toString()
    if (productCatalog.value.some(product => product.code === value)) {
      selectedProductCode.value = value
    }
  },
)

watch(selectedProductCode, (code) => {
  if (!isOsimRenewalCode(code)) form.ownerChangeRequested = false
})

onMounted(() => {
  loadCart()
  loadProducts()
  loadSiteTheme()
})
</script>

<style scoped>
.order-main {
  background: linear-gradient(180deg, #fbf7f0 0%, #fff 100%);
  padding: 48px 0 72px;
}

.order-intro {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 24px;
  margin-bottom: 32px;
}

.order-intro h1 {
  margin: 0 0 14px;
  color: var(--ink, #1f1d1a);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: clamp(34px, 5vw, 58px);
  font-weight: 400;
  line-height: 1;
}

.order-intro .lead {
  max-width: 54ch;
  margin: 0;
  color: var(--muted, #68635c);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 18px;
  line-height: 1.45;
}

.eyebrow {
  margin: 0 0 12px;
  color: var(--muted, #68635c);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.outline-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  color: var(--ink, #1f1d1a);
  padding: 0 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
}

.wrap {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
}

@media (max-width: 900px) {
  .order-intro {
    flex-direction: column;
    align-items: start;
  }
}
</style>
