<template>
  <div class="admin-page">
    <AdminHeader :brand-name="themeForm.brand_name || 'SANDU și Asociații IP Attorney'" />

    <main class="admin-main">
      <section class="wrap admin-layout">
        <div class="admin-panel">
          <AdminLoginPanel
            v-if="authHydrating || !authToken"
            :form="loginForm"
            :hydrating="authHydrating"
            :loading="loading"
            :mfa-challenge="mfaChallenge"
            @submit="login"
            @update:form="updateLoginForm"
          />

          <div
            v-else
            class="admin-dashboard"
          >
            <div
              v-if="dashboard"
              class="admin-shell"
              :class="{ collapsed: adminMenuCollapsed }"
            >
              <AdminSidebar
                :active-task="activeAdminTask"
                :collapsed="adminMenuCollapsed"
                :tasks="adminTasks"
                :user="currentUser"
                @logout="logout"
                @update:active-task="activeAdminTask = $event"
                @update:collapsed="adminMenuCollapsed = $event"
              />

              <div class="task-content">
                <AdminProductsSection
                  v-if="activeAdminTask === 'products'"
                  :categories="productCategories"
                  :editing-product-id="editingProductId"
                  :error="productError"
                  :form="productForm"
                  :image-uploading="imageUploading"
                  :product-image="productImage"
                  :saving="productSaving"
                  :saving-price-id="savingProductPriceId"
                  :selected-image-description="selectedImageDescription"
                  :show-form="showProductForm"
                  :upload-image-file="uploadImageFile"
                  :upload-image-name="uploadImageName"
                  :uploaded-images="uploadedProductImages"
                  @delete-product="deleteProduct"
                  @edit-product="editProduct"
                  @hide-product-form="hideProductForm"
                  @save-product="saveProduct"
                  @save-product-price="saveProductPrice"
                  @select-upload-image="selectUploadImage"
                  @show-new-product-form="showNewProductForm"
                  @update:form="updateProductForm"
                  @update:upload-image-name="uploadImageName = $event"
                  @update-product-price-draft="updateProductPriceDraft"
                  @upload-product-image="uploadProductImage"
                />

                <AdminOrdersSection
                  v-else-if="activeAdminTask === 'orders'"
                  :dashboard="dashboard"
                  :event-date="eventDate"
                  :event-label="eventLabel"
                  :loading="loading"
                  :order-date="orderDate"
                  :order-time="orderTime"
                  :order-type-label="orderTypeLabel"
                  :payment-label="paymentLabel"
                  :saving-order-id="savingOrderId"
                  @download-order-invoice="downloadOrderInvoice"
                  @refresh="loadDashboard"
                  @save-order-comments="saveOrderComments"
                  @save-order-status="saveOrderStatus"
                  @update-order-field="updateOrderField"
                />

                <AdminSettingsSection
                  v-else
                  :fields="themeFields"
                  :form="themeForm"
                  :products-count="products.length"
                  :theme-font-stack="themeFontStack"
                  :theme-image-uploading="themeImageUploading"
                  :theme-message="themeMessage"
                  :theme-saving="themeSaving"
                  :upload-theme-image-file="uploadThemeImageFile"
                  :upload-theme-image-name="uploadThemeImageName"
                  :uploaded-images="uploadedThemeImages"
                  :user="currentUser"
                  :users="dashboard.users"
                  @load-theme="loadTheme"
                  @reset-user-mfa="resetUserMfa"
                  @save-theme="saveTheme"
                  @select-upload-theme-image="selectUploadThemeImage"
                  @update:form="updateThemeForm"
                  @update:upload-theme-image-name="uploadThemeImageName = $event"
                  @upload-theme-image="uploadThemeImage"
                />
              </div>
            </div>
          </div>

          <p
            v-if="errorMessage"
            class="error-message"
          >
            {{ errorMessage }}
          </p>

          <div
            v-if="mfaRecoveryCodes.length"
            class="modal-backdrop"
          >
            <section
              class="modal-panel"
              aria-label="Recovery codes"
            >
              <div class="modal-panel__header">
                <div>
                  <span>Security</span>
                  <h2>Save recovery codes</h2>
                </div>
              </div>
              <p class="muted">
                Save these one-time codes now. They are shown only once and can be used if the authenticator is unavailable.
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
                  I saved these codes
                </button>
              </div>
            </section>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import verbalTrademarkUrl from '../assets/images/MARCA_TA_VERBALA-removebg-preview.png'

const config = useRuntimeConfig()
const dashboard = ref(null)
const products = ref([])
const uploadedProductImages = ref([])
const uploadedThemeImages = ref([])
const loading = ref(false)
const productSaving = ref(false)
const imageUploading = ref(false)
const themeImageUploading = ref(false)
const themeSaving = ref(false)
const savingOrderId = ref(null)
const savingProductPriceId = ref(null)
const errorMessage = ref('')
const productError = ref('')
const themeMessage = ref('')
const uploadImageName = ref('')
const uploadImageFile = ref(null)
const uploadThemeImageName = ref('')
const uploadThemeImageFile = ref(null)
const editingProductId = ref(null)
const showProductForm = ref(false)
const activeAdminTask = ref('products')
const adminMenuCollapsed = ref(false)
const adminTasks = [
  { id: 'products', label: 'Products' },
  { id: 'orders', label: 'Orders' },
  { id: 'settings', label: 'Settings' },
]
const productImages = {
  verbal: verbalTrademarkUrl,
  black_white: blackWhiteTrademarkUrl,
  color: colorTrademarkUrl,
}
const imageDescriptions = {
  verbal: 'Word mark without logo or special styling.',
  black_white: 'Monochrome logo, symbol, or special lettering.',
  color: 'Color logo, design, or colored lettering.',
}
const themeFields = [
  { key: 'brand_color', label: 'Header/footer color', type: 'color' },
  { key: 'primary_color', label: 'Primary button color', type: 'color' },
  { key: 'primary_dark_color', label: 'Primary text color', type: 'color' },
  { key: 'text_color', label: 'Text color', type: 'color' },
  { key: 'muted_color', label: 'Muted text color', type: 'color' },
  { key: 'line_color', label: 'Border color', type: 'color' },
  { key: 'background_color', label: 'Background color', type: 'color' },
  { key: 'font_family', label: 'Font family', type: 'text', placeholder: 'Montserrat' },
]
const selectedImageDescription = computed(() => {
  const uploadedImage = uploadedProductImages.value.find(image => image.key === productForm.image_key)
  return uploadedImage?.name || imageDescriptions[productForm.image_key] || ''
})
const themeFontStack = computed(() => `'${themeForm.font_family || 'Montserrat'}', sans-serif`)
const {
  authHeaders,
  authHydrating,
  authToken,
  currentUser,
  logout: logoutSession,
  persistSession,
  verifyStoredSession,
} = useAuthSession()
const productCategories = computed(() => {
  const categories = [
    { id: 'registration', label: 'Inregistrare marca', products: products.value.filter(product => productCategory(product) === 'registration') },
    { id: 'renewal', label: 'Reinnoire marca', products: products.value.filter(product => productCategory(product) === 'renewal') },
    { id: 'monitoring', label: 'Monitorizare marca', products: products.value.filter(product => productCategory(product) === 'monitoring') },
    { id: 'verification', label: 'Verificare marca', products: products.value.filter(product => productCategory(product) === 'verification') },
  ]

  return categories.filter(category => category.products.length)
})

const loginForm = reactive({
  email: '',
  password: '',
  otpCode: '',
})
const mfaChallenge = ref(null)
const mfaRecoveryCodes = ref([])
const productForm = reactive(defaultProductForm())
const themeForm = reactive(defaultThemeForm())

function defaultProductForm() {
  return {
    code: '',
    currency: 'RON',
    region: 'OSIM',
    price_label: '',
    base_price_lei: 0,
    title_ro: '',
    title_en: '',
    note_ro: '',
    note_en: '',
    tax_ro: 'include TVA',
    tax_en: 'includes VAT',
    items_ro: '',
    items_en: '',
    image_key: '',
    position: 0,
    active: true,
  }
}

function defaultThemeForm() {
  return {
    primary_color: '#00add9',
    primary_dark_color: '#00add9',
    brand_color: '#013ebe',
    text_color: '#1f1d1a',
    muted_color: '#68635c',
    line_color: '#ded8cf',
    background_color: '#ffffff',
    font_family: 'Montserrat',
    brand_name: 'SANDU și Asociații IP Attorney',
    hero_image_key: '',
    hero_image: '',
    logo_image_key: '',
    logo_image: '',
    footer_logo_image_key: '',
    footer_logo_image: '',
    footer_text: '',
    terms_content: '',
    privacy_policy_content: '',
  }
}

function applyTheme(theme) {
  const selectedTheme = { ...defaultThemeForm(), ...theme }
  const root = document.documentElement.style

  root.setProperty('--ink', selectedTheme.text_color)
  root.setProperty('--muted', selectedTheme.muted_color)
  root.setProperty('--line', selectedTheme.line_color)
  root.setProperty('--paper', selectedTheme.background_color)
  root.setProperty('--cream', selectedTheme.background_color)
  root.setProperty('--gold', selectedTheme.primary_color)
  root.setProperty('--gold-dark', selectedTheme.primary_dark_color)
  root.setProperty('--brand', selectedTheme.brand_color)
  root.setProperty('--font-family', `'${selectedTheme.font_family || 'Montserrat'}', sans-serif`)

  if (selectedTheme.hero_image) {
    root.setProperty('--hero-image', `url(${selectedTheme.hero_image})`)
  }
  else {
    root.removeProperty('--hero-image')
  }

  if (selectedTheme.logo_image) {
    root.setProperty('--logo-image', `url(${selectedTheme.logo_image})`)
  }
  else {
    root.removeProperty('--logo-image')
  }
}

function resetProductForm() {
  editingProductId.value = null
  productError.value = ''
  Object.assign(productForm, defaultProductForm())
}

function showNewProductForm() {
  if (showProductForm.value && !editingProductId.value) {
    hideProductForm()
    return
  }

  resetProductForm()
  showProductForm.value = true
}

function hideProductForm() {
  resetProductForm()
  showProductForm.value = false
}

function clearAdminSession() {
  dashboard.value = null
}

function updateLoginForm(form) {
  Object.assign(loginForm, form)
}

function updateProductForm(form) {
  Object.assign(productForm, form)
}

function updateThemeForm(form) {
  Object.assign(themeForm, form)
}

function updateProductPriceDraft(product, field, value) {
  product.priceDraft[field] = value
}

function updateOrderField(order, field, value) {
  order[field] = value
}

function paymentLabel(paymentMethod) {
  const labels = {
    card: 'Card',
    paypal: 'PayPal',
    transfer: 'Bank transfer',
  }

  return labels[paymentMethod] || paymentMethod || 'Payment not selected'
}

function orderTypeLabel(orderType) {
  const labels = {
    monitoring: 'Monitoring',
    renewal: 'Renewal',
    registration: 'Registration',
  }

  return labels[orderType] || orderType || 'Registration'
}

function eventLabel(event) {
  if (event.field_name === 'status') {
    return `Status: ${statusText(event.old_value)} -> ${statusText(event.new_value)}`
  }

  if (event.field_name === 'admin_comments') {
    return 'Admin comments updated'
  }

  return event.action
}

function statusText(status) {
  const labels = {
    pending_payment: 'Pending payment',
    paid: 'Paid',
    processing: 'Processing',
    completed: 'Completed',
  }

  return labels[status] || status || '-'
}

function eventDate(date) {
  return new Intl.DateTimeFormat('ro-RO', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(new Date(date))
}

function productImage(product) {
  return product.image || productImages[product.image_key]
}

function productCategory(product) {
  const code = product.code || ''
  if (code.startsWith('renew-')) return 'renewal'
  if (code.startsWith('monitoring-')) return 'monitoring'
  if (code.startsWith('verification-')) return 'verification'
  return 'registration'
}

function withPriceDraft(product) {
  return {
    ...product,
    priceDraft: {
      price_label: product.price,
      base_price_lei: product.base_lei,
    },
  }
}

function orderDate(value) {
  return new Intl.DateTimeFormat('ro-RO', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(new Date(value))
}

function orderTime(value) {
  return new Intl.DateTimeFormat('ro-RO', {
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value))
}

async function login() {
  errorMessage.value = ''
  loading.value = true

  try {
    if (mfaChallenge.value) {
      await submitMfaCode()
      return
    }

    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        session: {
          email: loginForm.email,
          password: loginForm.password,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error('Invalid email or password.')
    }

    if (!payload.user?.admin) {
      throw new Error('This account does not have admin access.')
    }

    if (payload.mfa_required) {
      mfaChallenge.value = payload
      loginForm.otpCode = ''
      return
    }

    persistSession(payload.token, payload.user)
    await loadDashboard()
    await loadProducts()
    await loadProductImages()
    await loadThemeImages()
    await loadTheme()
  }
  catch (error) {
    clearAdminSession()
    errorMessage.value = error instanceof Error ? error.message : 'Could not sign in.'
  }
  finally {
    loading.value = false
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
        otp_code: loginForm.otpCode,
      },
    }),
  })
  const payload = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(payload.message || 'Invalid authenticator code.')
  }

  if (!payload.user?.admin) {
    throw new Error('This account does not have admin access.')
  }

  mfaChallenge.value = null
  loginForm.otpCode = ''
  persistSession(payload.token, payload.user)
  mfaRecoveryCodes.value = payload.recovery_codes || []
  await loadDashboard()
  await loadProducts()
  await loadProductImages()
  await loadThemeImages()
  await loadTheme()
}

async function hydrateSession() {
  if (await verifyStoredSession({ requireAdmin: true })) {
    await loadDashboard()
    await loadProducts()
    await loadProductImages()
    await loadThemeImages()
    await loadTheme()
  }
  else {
    clearAdminSession()
  }
}

async function loadDashboard() {
  errorMessage.value = ''
  loading.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/dashboard`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(response.status === 403 ? 'This account does not have admin access.' : 'Could not load admin data.')
    }

    dashboard.value = payload
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not load admin data.'
  }
  finally {
    loading.value = false
  }
}

async function loadProducts() {
  productError.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_products`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error('Could not load products.')
    }

    products.value = (payload.products || []).map(withPriceDraft)
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not load products.'
  }
}

async function loadTheme() {
  themeMessage.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/site_theme`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error('Could not load theme.')
    }

    Object.assign(themeForm, defaultThemeForm(), payload.theme || {})
    applyTheme(themeForm)
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not load theme.'
  }
}

async function saveTheme() {
  errorMessage.value = ''
  themeMessage.value = ''
  themeSaving.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/site_theme`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({ theme: themeForm }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not save theme.')
    }

    Object.assign(themeForm, defaultThemeForm(), payload.theme || {})
    applyTheme(themeForm)
    themeMessage.value = 'Theme saved.'
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not save theme.'
  }
  finally {
    themeSaving.value = false
  }
}

async function loadProductImages() {
  productError.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/product_images`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error('Could not load images.')
    }

    uploadedProductImages.value = payload.images || []
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not load images.'
  }
}

async function loadThemeImages() {
  errorMessage.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/theme_images`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error('Could not load theme images.')
    }

    uploadedThemeImages.value = payload.images || []
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not load theme images.'
  }
}

function selectUploadImage(event) {
  uploadImageFile.value = event.target.files?.[0] || null
  if (!uploadImageName.value && uploadImageFile.value) {
    uploadImageName.value = uploadImageFile.value.name.replace(/\.[^.]+$/, '')
  }
}

async function uploadProductImage() {
  if (!uploadImageFile.value) return

  productError.value = ''
  imageUploading.value = true

  try {
    const formData = new FormData()
    formData.append('product_image[name]', uploadImageName.value)
    formData.append('product_image[file]', uploadImageFile.value)

    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/product_images`, {
      method: 'POST',
      headers: authHeaders(),
      body: formData,
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not upload image.')
    }

    uploadedProductImages.value = [...uploadedProductImages.value, payload.image]
    productForm.image_key = payload.image.key
    uploadImageName.value = ''
    uploadImageFile.value = null
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not upload image.'
  }
  finally {
    imageUploading.value = false
  }
}

function selectUploadThemeImage(event) {
  uploadThemeImageFile.value = event.target.files?.[0] || null
  if (!uploadThemeImageName.value && uploadThemeImageFile.value) {
    uploadThemeImageName.value = uploadThemeImageFile.value.name.replace(/\.[^.]+$/, '')
  }
}

async function uploadThemeImage() {
  if (!uploadThemeImageFile.value) return

  errorMessage.value = ''
  themeImageUploading.value = true

  try {
    const formData = new FormData()
    formData.append('theme_image[name]', uploadThemeImageName.value)
    formData.append('theme_image[file]', uploadThemeImageFile.value)

    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/theme_images`, {
      method: 'POST',
      headers: authHeaders(),
      body: formData,
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not upload theme image.')
    }

    uploadedThemeImages.value = [...uploadedThemeImages.value, payload.image]
    uploadThemeImageName.value = ''
    uploadThemeImageFile.value = null
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not upload theme image.'
  }
  finally {
    themeImageUploading.value = false
  }
}

async function saveOrderComments(order) {
  errorMessage.value = ''
  savingOrderId.value = order.id

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_requests/${order.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({
        trademark_request: {
          admin_comments: order.admin_comments || '',
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not save admin comments.')
    }

    order.admin_comments = payload.order?.admin_comments || ''
    order.events = payload.order?.events || order.events || []
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not save admin comments.'
  }
  finally {
    savingOrderId.value = null
  }
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

async function downloadOrderInvoice(order) {
  errorMessage.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_requests/${order.id}/invoice`, {
      headers: authHeaders(),
    })

    if (!response.ok) {
      throw new Error('Could not download invoice.')
    }

    const blob = await response.blob()
    const prefix = order.payment_method === 'transfer' ? 'proforma' : 'invoice'
    downloadBlob(blob, `${prefix}-${order.id}.pdf`)
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not download invoice.'
  }
}

async function saveOrderStatus(order) {
  errorMessage.value = ''
  savingOrderId.value = order.id

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_requests/${order.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({
        trademark_request: {
          status: order.status,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not update order status.')
    }

    order.status = payload.order?.status || order.status
    order.events = payload.order?.events || order.events || []
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not update order status.'
  }
  finally {
    savingOrderId.value = null
  }
}

async function saveProductPrice(product) {
  productError.value = ''
  savingProductPriceId.value = product.id

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_products/${product.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify({
        trademark_product: {
          price_label: product.priceDraft.price_label,
          base_price_lei: product.priceDraft.base_price_lei,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not save price.')
    }

    const updatedProduct = withPriceDraft(payload.product)
    const index = products.value.findIndex(item => item.id === product.id)
    if (index >= 0) products.value.splice(index, 1, updatedProduct)
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not save price.'
  }
  finally {
    savingProductPriceId.value = null
  }
}

function editProduct(product) {
  editingProductId.value = product.id
  showProductForm.value = true
  productError.value = ''
  Object.assign(productForm, {
    code: product.code,
    currency: product.currency,
    region: product.region,
    price_label: product.price,
    base_price_lei: product.base_lei,
    title_ro: product.translations.ro.title,
    title_en: product.translations.en.title,
    note_ro: product.translations.ro.note,
    note_en: product.translations.en.note,
    tax_ro: product.translations.ro.tax,
    tax_en: product.translations.en.tax,
    items_ro: product.translations.ro.items.join('\n'),
    items_en: product.translations.en.items.join('\n'),
    image_key: product.image_key || '',
    position: product.position,
    active: product.active,
  })
}

function productPayload() {
  return {
    trademark_product: {
      code: productForm.code,
      currency: productForm.currency,
      region: productForm.region,
      price_label: productForm.price_label,
      base_price_lei: productForm.base_price_lei,
      title_ro: productForm.title_ro,
      title_en: productForm.title_en,
      note_ro: productForm.note_ro,
      note_en: productForm.note_en,
      tax_ro: productForm.tax_ro,
      tax_en: productForm.tax_en,
      items_ro: productForm.items_ro.split('\n').map(item => item.trim()).filter(Boolean),
      items_en: productForm.items_en.split('\n').map(item => item.trim()).filter(Boolean),
      image_key: productForm.image_key,
      position: productForm.position,
      active: productForm.active,
    },
  }
}

async function saveProduct() {
  productError.value = ''
  productSaving.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_products${editingProductId.value ? `/${editingProductId.value}` : ''}`, {
      method: editingProductId.value ? 'PATCH' : 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
      },
      body: JSON.stringify(productPayload()),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not save product.')
    }

    hideProductForm()
    await loadProducts()
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not save product.'
  }
  finally {
    productSaving.value = false
  }
}

async function deleteProduct(product) {
  productError.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/trademark_products/${product.id}`, {
      method: 'DELETE',
      headers: authHeaders(),
    })

    if (!response.ok) {
      throw new Error('Could not delete product.')
    }

    if (editingProductId.value === product.id) hideProductForm()
    await loadProducts()
  }
  catch (error) {
    productError.value = error instanceof Error ? error.message : 'Could not delete product.'
  }
}

async function resetUserMfa(user) {
  if (!window.confirm(`Reset MFA for ${user.email}?`)) return

  errorMessage.value = ''

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/users/${user.id}/mfa`, {
      method: 'DELETE',
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not reset MFA.')
    }

    themeMessage.value = payload.message || 'MFA was reset for this user.'
    await loadDashboard()
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not reset MFA.'
  }
}

async function logout() {
  await logoutSession()
  clearAdminSession()
}

onMounted(() => {
  hydrateSession()
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
input {
  font: inherit;
}

a {
  color: inherit;
}

.wrap {
  width: min(1180px, calc(100% - 32px));
  margin: 0 auto;
}

.admin-page .wrap {
  width: min(1440px, calc(100% - 32px));
}

.admin-header {
  border-bottom: 1px solid var(--line);
  background: #fff;
}

.admin-header__inner,
.admin-nav,
.brand {
  display: flex;
  align-items: center;
}

.admin-header__inner {
  min-height: 86px;
  justify-content: space-between;
  gap: 24px;
}

.brand {
  gap: 12px;
  text-decoration: none;
}

.brand small,
.admin-nav,
.orders-row small,
.signed-in-card span,
.user-list span,
.admin-product-card p,
.admin-product-price small,
.admin-product-code {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.brand__logo {
  display: block;
  background: var(--logo-image, var(--fallback-logo-image)) center / contain no-repeat;
  width: clamp(180px, 22vw, 257px);
  height: clamp(58px, 7vw, 83px);
  aspect-ratio: 257 / 83;
}

.brand small {
  display: block;
  letter-spacing: 0.12em;
  font-size: 10px;
}

.admin-nav {
  gap: 18px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.admin-nav a {
  text-decoration: none;
}

.admin-main {
  padding: 32px 0 56px;
}

.admin-layout {
  display: block;
}

.admin-panel {
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.admin-login,
.product-form,
.admin-dashboard {
  display: grid;
  gap: 18px;
}

.admin-shell {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  gap: 22px;
  align-items: start;
}

.admin-shell.collapsed {
  grid-template-columns: 56px minmax(0, 1fr);
}

.task-sidebar {
  position: sticky;
  top: 18px;
  display: grid;
  gap: 10px;
}

.sidebar-toggle,
.task-button {
  display: flex;
  align-items: center;
  width: 100%;
  min-height: 50px;
  border: 1px solid var(--line);
  background: var(--paper);
  color: var(--ink);
  padding: 0 14px;
  cursor: pointer;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
  text-align: left;
}

.sidebar-toggle {
  gap: 12px;
}

.admin-shell.collapsed .sidebar-toggle {
  justify-content: center;
  padding: 0;
}

.task-button {
  justify-content: space-between;
}

.task-button::after {
  content: '';
  width: 7px;
  height: 7px;
  border-top: 2px solid currentColor;
  border-right: 2px solid currentColor;
  transform: rotate(45deg);
  opacity: 0.42;
}

.sidebar-toggle:hover,
.sidebar-toggle:focus-visible,
.task-button:hover,
.task-button:focus-visible,
.task-button.active {
  border-color: var(--gold);
  background: #fff;
  color: var(--gold-dark);
}

.hamburger-icon,
.hamburger-icon::before,
.hamburger-icon::after {
  display: block;
  width: 18px;
  height: 2px;
  border-radius: 2px;
  background: currentColor;
}

.hamburger-icon {
  position: relative;
  flex: 0 0 auto;
}

.hamburger-icon::before,
.hamburger-icon::after {
  position: absolute;
  left: 0;
  content: '';
}

.hamburger-icon::before {
  top: -6px;
}

.hamburger-icon::after {
  top: 6px;
}

.task-content {
  min-width: 0;
}

.admin-login label,
.product-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.admin-login input,
.product-form input,
.product-form select,
.product-form textarea {
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

.product-form textarea {
  resize: vertical;
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.checkbox-field {
  align-content: end;
  grid-template-columns: auto 1fr;
}

.checkbox-field input {
  width: auto;
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

.danger-btn {
  border-color: #b3261e;
  color: #b3261e;
}

.section-title,
.user-list article,
.signed-in-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.stats-grid article,
.user-list article,
.signed-in-card,
.settings-grid article {
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 16px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.signed-in-card {
  display: grid;
  align-items: start;
}

.signed-in-card .ghost-btn {
  width: 100%;
  margin-top: 8px;
}

.signed-in-card strong {
  overflow-wrap: anywhere;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.stats-grid span {
  display: block;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  margin-bottom: 8px;
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.settings-grid span {
  display: block;
  color: var(--muted);
  margin-bottom: 8px;
}

.theme-form {
  display: grid;
  gap: 14px;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 16px;
}

.theme-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.theme-grid label {
  display: grid;
  gap: 8px;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
}

.theme-grid input,
.theme-grid select,
.theme-grid textarea {
  width: 100%;
}

.theme-grid textarea {
  min-height: 120px;
  resize: vertical;
}

.theme-grid__wide {
  grid-column: 1 / -1;
}

.theme-color-control {
  display: grid;
  grid-template-columns: 52px minmax(0, 1fr);
  gap: 8px;
  align-items: center;
}

.theme-grid .theme-color-control input[type='color'] {
  height: 44px;
  padding: 4px;
}

.theme-grid .theme-color-control input[type='text'] {
  height: 44px;
  text-transform: uppercase;
}

.theme-preview {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 48px;
  border: 1px solid var(--line);
  padding: 10px 12px;
}

.theme-preview span {
  display: block;
  width: 26px;
  height: 26px;
  border: 1px solid var(--line);
}

.stats-grid strong {
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 30px;
  font-weight: 400;
}

.admin-section {
  display: grid;
  gap: 14px;
}

.admin-section h2 {
  margin: 0;
  font-size: 28px;
  font-weight: 400;
}

.orders-table,
.user-list,
.admin-product-grid {
  display: grid;
  gap: 8px;
}

.admin-product-categories {
  display: grid;
  gap: 28px;
}

.admin-product-category {
  display: grid;
  gap: 14px;
}

.product-category-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  border-bottom: 1px solid var(--line);
  padding-bottom: 10px;
}

.product-category-heading h3 {
  margin: 0;
  font-size: 22px;
  font-weight: 400;
}

.product-category-heading span {
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.admin-product-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.admin-product-card {
  display: flex;
  flex-direction: column;
  min-height: 440px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.admin-product-card__top {
  min-height: 150px;
}

.admin-product-card__meta,
.admin-product-code {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
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

.status-pill {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  border: 1px solid #cfc7bc;
  padding: 0 10px;
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
}

.status-pill.active {
  border-color: rgba(0, 173, 217, 0.28);
  color: var(--gold-dark);
}

.status-pill.hidden {
  border-color: #d7b7a9;
  color: #8f3d22;
}

.admin-product-card h3 {
  margin: 16px 0 6px;
  font-size: 24px;
  font-weight: 400;
  text-transform: uppercase;
}

.admin-product-card__image {
  display: block;
  max-width: 170px;
  height: 42px;
}

.admin-product-card p {
  line-height: 1.6;
}

.admin-product-price {
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  margin: 18px 0;
  padding: 18px 0;
}

.admin-product-price span {
  display: block;
  font-size: 34px;
}

.inline-price-form {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(110px, 0.65fr) auto;
  gap: 10px;
  align-items: end;
  margin: 0 0 18px;
  border: 1px solid var(--line);
  background: #fff;
  padding: 12px;
}

.inline-price-form label {
  display: grid;
  gap: 6px;
  color: var(--muted);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.inline-price-form input {
  width: 100%;
  border: 1px solid #cfc7bc;
  color: var(--ink);
  padding: 10px 11px;
  font-size: 14px;
  font-weight: 500;
  text-transform: none;
}

.admin-product-card ul {
  display: grid;
  gap: 10px;
  margin: 0 0 22px;
  padding: 0;
  list-style: none;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  line-height: 1.45;
}

.admin-product-card li::before {
  content: '+';
  margin-right: 8px;
  color: var(--gold-dark);
  font-weight: 700;
}

.admin-product-code {
  margin-top: auto;
  border-top: 1px solid var(--line);
  padding-top: 14px;
  font-size: 12px;
  font-weight: 700;
}

.product-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.form-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.orders-row {
  display: grid;
  grid-template-columns: 0.72fr 1.2fr 1.2fr 0.75fr 0.7fr minmax(220px, 1.3fr);
  gap: 14px;
  align-items: start;
  border: 1px solid var(--line);
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.orders-row--head {
  background: #2b2926;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.orders-row strong,
.orders-row small {
  display: block;
}

.orders-row small {
  margin-top: 4px;
}

.order-payment,
.order-comments {
  display: grid;
  gap: 8px;
}

.status-select {
  display: grid;
  gap: 5px;
}

.status-select span {
  color: var(--muted);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}

.status-select select {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  font: inherit;
  min-height: 36px;
  padding: 0 8px;
}

.order-payment .ghost-btn,
.order-comments .ghost-btn {
  width: max-content;
  min-height: 36px;
  padding: 0 14px;
}

.order-comments textarea {
  width: 100%;
  min-height: 74px;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 10px 12px;
  resize: vertical;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.order-log {
  display: grid;
  gap: 6px;
  border-top: 1px solid var(--line);
  padding-top: 8px;
}

.order-log ul {
  display: grid;
  gap: 6px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.order-log li {
  border-left: 3px solid #b7ccd6;
  background: #f8fbfc;
  padding: 7px 9px;
}

.order-log li span {
  display: block;
  font-size: 12px;
  font-weight: 700;
  line-height: 1.4;
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

.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 50;
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

.recovery-code-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
  margin: 18px 0;
}

.recovery-code-list code {
  padding: 10px 12px;
  border: 1px solid var(--line);
  background: var(--paper);
  text-align: center;
  font-weight: 700;
}

@media (max-width: 920px) {
  .admin-layout,
  .admin-shell,
  .stats-grid,
  .settings-grid,
  .theme-grid,
  .orders-row,
  .inline-price-form,
  .field-grid {
    grid-template-columns: 1fr;
  }

  .admin-header__inner,
  .section-title,
  .user-list article,
  .admin-product-card__meta,
  .admin-product-code {
    flex-direction: column;
    align-items: stretch;
  }

  .task-sidebar {
    position: static;
  }

  .admin-product-grid {
    grid-template-columns: 1fr;
  }
}
</style>
