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
          class="back-home-link"
          to="/"
        >
          {{ t.backToHome }}
        </NuxtLink>
      </section>

      <HomeOrderFormSection
        :cart-message="cartMessage"
        :class-prices="classPrices"
        :current-step="currentStep"
        :form="form"
        :formatted-class-price="formattedClassPrice"
        :formatted-total="formattedTotal"
        :is-osim-renewal-product="Boolean(isOsimRenewalProduct)"
        :labels="t"
        :nice-classes="niceClasses"
        :selected-product="selectedProduct"
        :selected-product-code="selectedProductCode"
        :steps="steps"
        :submit-error="submitError"
        :visible="true"
        @add-to-cart="addToCart"
        @update:current-step="currentStep = $event"
        @update:form="updateOrderForm"
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
import { productClassTotal, supportsClassPricing } from '../utils/productPricing'
import { normalizeNiceClassNumbers, formatNiceClassSelection } from '../utils/niceClassSelection'
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
const isVerificationProduct = computed(() => selectedProductCode.value.startsWith('verification-'))
const steps = computed(() => [t.value.steps[0], t.value.steps[2]])

useHead(() => ({
  title: t.value.wizardMetaTitle,
}))

const form = reactive({
  mark: '',
  classes: 0,
  niceClassNumbers: [],
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
const selectedProduct = computed(() => plans.value.find(plan => plan.code === selectedProductCode.value) || plans.value[0] || null)
const selectedProductCurrency = computed(() => selectedProduct.value?.currency || 'RON')
const isOsimRenewalProduct = computed(() => selectedProduct.value && isOsimRenewalCode(selectedProduct.value.code))
const total = computed(() => selectedProduct.value ? productClassTotal(selectedProduct.value, form.classes) + ownerChangeTotal.value : 0)
const ownerChangeTotal = computed(() => isOsimRenewalProduct.value && form.ownerChangeRequested ? 477 : 0)
const formattedClassPrice = computed(() => formatMoney(selectedProduct.value ? productClassTotal(selectedProduct.value, form.classes) : 0, selectedProductCurrency.value))
const formattedTotal = computed(() => formatMoney(total.value, selectedProductCurrency.value))
const classPrices = computed(() => {
  if (!selectedProduct.value || !supportsClassPricing(selectedProduct.value)) return []
  return Array.from({ length: 11 }, (_, index) => ({
    count: index + 1,
    price: formatMoney(productClassTotal(selectedProduct.value, index + 1), selectedProductCurrency.value),
  }))
})
const niceClasses = computed(() => niceClasses2024.map(niceClass => ({
  ...niceClass,
  title: niceClassTitle(niceClass),
  label: selectedLanguage.value === 'ro'
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

function updateOrderForm(updatedForm) {
  const numbers = isVerificationProduct.value ? [] : normalizeNiceClassNumbers(updatedForm.niceClassNumbers)
  Object.assign(form, updatedForm, {
    niceClassNumbers: numbers,
    classes: isVerificationProduct.value ? 1 : numbers.length,
    primaryClass: formatNiceClassSelection(numbers, selectedLanguage.value),
  })
}

function buildCartItem() {
  if (!selectedProduct.value) return null

  return {
    id: crypto.randomUUID(),
    productCode: selectedProductCode.value,
    productTitle: selectedProduct.value.title,
    mark: form.mark,
    classes: isVerificationProduct.value ? 1 : form.classes,
    primaryClass: isVerificationProduct.value ? '' : form.primaryClass,
    niceClassNumbers: isVerificationProduct.value ? [] : [...form.niceClassNumbers],
    goods: selectedProductCode.value.startsWith('renew-') ? '' : form.goods,
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

  const missingNiceClass = !isVerificationProduct.value && !form.niceClassNumbers.length
  if (!selectedProduct.value || !form.mark || missingNiceClass || !form.terms) {
    if (!form.mark) submitError.value = t.value.missingMark
    else if (missingNiceClass) submitError.value = t.value.missingNiceClass
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
  if (code.startsWith('verification-')) {
    form.classes = 1
    form.primaryClass = ''
    form.niceClassNumbers = []
  }
  else {
    form.classes = form.niceClassNumbers.length
  }
})

watch(selectedLanguage, () => {
  form.primaryClass = formatNiceClassSelection(form.niceClassNumbers, selectedLanguage.value)
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

.back-home-link {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  justify-content: center;
  min-height: 44px;
  border: 1px solid rgba(31, 29, 26, 0.14);
  background: rgba(255, 255, 255, 0.78);
  color: var(--ink, #1f1d1a);
  padding: 0 16px 0 14px;
  box-shadow: 0 12px 30px rgba(31, 29, 26, 0.07);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
  transition: border-color 0.2s ease, box-shadow 0.2s ease, color 0.2s ease, transform 0.2s ease;
}

.back-home-link::before {
  content: "";
  display: block;
  width: 9px;
  height: 9px;
  border-bottom: 2px solid currentColor;
  border-left: 2px solid currentColor;
  transform: rotate(45deg);
}

.back-home-link:hover,
.back-home-link:focus-visible {
  border-color: var(--gold, #00add9);
  box-shadow: 0 16px 34px rgba(31, 29, 26, 0.1);
  color: var(--brand, #1f1d1a);
  transform: translateX(-2px);
}

.back-home-link:focus-visible {
  outline: 3px solid rgba(0, 173, 217, 0.22);
  outline-offset: 3px;
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

  .back-home-link {
    align-self: start;
  }
}
</style>
