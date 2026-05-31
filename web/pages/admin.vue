<template>
  <div class="admin-page">
    <header class="admin-header">
      <div class="wrap admin-header__inner">
        <NuxtLink
          class="brand"
          to="/"
          :aria-label="themeForm.brand_name || 'SANDU și Asociații IP Attorney'"
        >
          <span
            class="brand__logo"
            :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
            role="img"
            :aria-label="themeForm.brand_name || 'SANDU și Asociații IP Attorney'"
          />
          <small>ADMIN</small>
        </NuxtLink>

        <nav class="admin-nav">
          <NuxtLink to="/">
            Site
          </NuxtLink>
          <NuxtLink to="/account">
            Account
          </NuxtLink>
        </nav>
      </div>
    </header>

    <main class="admin-main">
      <section class="wrap admin-layout">
        <div class="admin-panel">
          <form
            v-if="!authToken"
            class="admin-login"
            @submit.prevent="login"
          >
            <label>
              Email
              <input
                v-model="loginForm.email"
                type="email"
                placeholder="admin@example.com"
                required
              >
            </label>
            <label>
              Password
              <input
                v-model="loginForm.password"
                type="password"
                placeholder="Minimum 8 characters"
                required
              >
            </label>
            <button
              class="primary-btn"
              type="submit"
              :disabled="loading"
            >
              {{ loading ? 'Signing in...' : 'Sign in' }}
            </button>
          </form>

          <div
            v-else
            class="admin-dashboard"
          >
            <div
              v-if="dashboard"
              class="admin-shell"
              :class="{ collapsed: adminMenuCollapsed }"
            >
              <aside class="task-sidebar">
                <button
                  class="sidebar-toggle"
                  type="button"
                  :aria-expanded="!adminMenuCollapsed"
                  :aria-label="adminMenuCollapsed ? 'Show menu' : 'Hide menu'"
                  @click="adminMenuCollapsed = !adminMenuCollapsed"
                >
                  <span
                    class="hamburger-icon"
                    aria-hidden="true"
                  />
                  <span v-if="!adminMenuCollapsed">Hide menu</span>
                </button>

                <button
                  v-for="task in adminTasks"
                  v-show="!adminMenuCollapsed"
                  :key="task.id"
                  class="task-button"
                  :class="{ active: activeAdminTask === task.id }"
                  type="button"
                  @click="activeAdminTask = task.id"
                >
                  <span>{{ task.label }}</span>
                </button>

                <div
                  v-show="!adminMenuCollapsed"
                  class="signed-in-card"
                >
                  <span>Signed in as</span>
                  <strong>{{ currentUser?.email }}</strong>
                  <button
                    class="ghost-btn"
                    type="button"
                    @click="logout"
                  >
                    Logout
                  </button>
                </div>
              </aside>

              <div class="task-content">
                <div
                  v-if="activeAdminTask === 'products'"
                  class="admin-section"
                >
                  <div class="section-title">
                    <h2>Products</h2>
                    <button
                      class="ghost-btn"
                      type="button"
                      @click="showNewProductForm"
                    >
                      Add product
                    </button>
                  </div>

                  <form
                    v-if="showProductForm"
                    class="product-form"
                    @submit.prevent="saveProduct"
                  >
                    <div class="field-grid">
                      <label>
                        Code
                        <input
                          v-model="productForm.code"
                          required
                        >
                      </label>
                      <label>
                        Position
                        <input
                          v-model.number="productForm.position"
                          type="number"
                          min="0"
                          required
                        >
                      </label>
                      <label>
                        Currency
                        <select v-model="productForm.currency">
                          <option value="RON">RON</option>
                          <option value="EUR">EUR</option>
                        </select>
                      </label>
                      <label>
                        Office
                        <input
                          v-model="productForm.region"
                          required
                        >
                      </label>
                      <label>
                        Price label
                        <input
                          v-model="productForm.price_label"
                          required
                        >
                      </label>
                      <label>
                        Base price Lei
                        <input
                          v-model.number="productForm.base_price_lei"
                          type="number"
                          min="0"
                          required
                        >
                      </label>
                      <label style="position:relative;">
                        Image
                        <div style="position:relative;">
                          <select
                            v-model="productForm.image_key"
                            :title="selectedImageDescription"
                          >
                            <option value="">None</option>
                            <option value="verbal">Marca verbala OSIM</option>
                            <option value="black_white">Marca alb-negru</option>
                            <option value="color">Marca color</option>
                            <option
                              v-for="image in uploadedProductImages"
                              :key="image.key"
                              :value="image.key"
                            >
                              {{ image.name }}
                            </option>
                          </select>
                        </div>
                      </label>
                      <label>
                        Upload image
                        <input
                          v-model="uploadImageName"
                          type="text"
                          placeholder="Display name"
                        >
                        <input
                          type="file"
                          accept="image/*"
                          @change="selectUploadImage"
                        >
                        <button
                          class="ghost-btn"
                          type="button"
                          :disabled="imageUploading || !uploadImageFile"
                          @click="uploadProductImage"
                        >
                          {{ imageUploading ? 'Uploading...' : 'Upload image' }}
                        </button>
                      </label>
                      <label class="checkbox-field">
                        <input
                          v-model="productForm.active"
                          type="checkbox"
                        >
                        Active
                      </label>
                    </div>

                    <div class="field-grid">
                      <label>
                        Title RO
                        <input
                          v-model="productForm.title_ro"
                          required
                        >
                      </label>
                      <label>
                        Title EN
                        <input
                          v-model="productForm.title_en"
                          required
                        >
                      </label>
                      <label>
                        Note RO
                        <input v-model="productForm.note_ro">
                      </label>
                      <label>
                        Note EN
                        <input v-model="productForm.note_en">
                      </label>
                      <label>
                        Tax RO
                        <input v-model="productForm.tax_ro">
                      </label>
                      <label>
                        Tax EN
                        <input v-model="productForm.tax_en">
                      </label>
                      <label>
                        Attributes RO
                        <textarea
                          v-model="productForm.items_ro"
                          rows="4"
                        />
                      </label>
                      <label>
                        Attributes EN
                        <textarea
                          v-model="productForm.items_en"
                          rows="4"
                        />
                      </label>
                    </div>

                    <div class="form-actions">
                      <button
                        class="primary-btn"
                        type="submit"
                        :disabled="productSaving"
                      >
                        {{ editingProductId ? 'Save changes' : 'Create product' }}
                      </button>
                      <button
                        class="ghost-btn"
                        type="button"
                        @click="hideProductForm"
                      >
                        Cancel
                      </button>
                    </div>
                  </form>

                  <p
                    v-if="productError"
                    class="error-message"
                  >
                    {{ productError }}
                  </p>

                  <div class="admin-product-grid">
                    <article
                      v-for="product in products"
                      :key="product.id"
                      class="admin-product-card"
                    >
                      <div class="admin-product-card__top">
                        <div class="admin-product-card__meta">
                          <span class="country-pill">{{ product.region }}</span>
                          <span :class="['status-pill', product.active ? 'active' : 'hidden']">
                            {{ product.active ? 'Active' : 'Hidden' }}
                          </span>
                        </div>
                        <h3>{{ product.translations.ro.title }}</h3>
                        <img
                          v-if="productImage(product)"
                          class="admin-product-card__image"
                          :src="productImage(product)"
                          :alt="product.translations.ro.title"
                        >
                        <p v-if="product.translations.ro.note">
                          {{ product.translations.ro.note }}
                        </p>
                      </div>

                      <div class="admin-product-price">
                        <span>{{ product.price }}</span>
                        <small>{{ product.translations.ro.tax }}</small>
                      </div>

                      <ul>
                        <li
                          v-for="item in product.translations.ro.items"
                          :key="item"
                        >
                          {{ item }}
                        </li>
                      </ul>

                      <div class="admin-product-code">
                        <span>{{ product.code }}</span>
                        <span>{{ product.currency }}</span>
                      </div>

                      <div class="product-actions">
                        <button
                          class="ghost-btn"
                          type="button"
                          @click="editProduct(product)"
                        >
                          Edit
                        </button>
                        <button
                          class="ghost-btn danger-btn"
                          type="button"
                          @click="deleteProduct(product)"
                        >
                          Delete
                        </button>
                      </div>
                    </article>
                  </div>
                </div>

                <div
                  v-else-if="activeAdminTask === 'orders'"
                  class="admin-section"
                >
                  <div class="section-title">
                    <h2>Orders</h2>
                    <button
                      class="ghost-btn"
                      type="button"
                      :disabled="loading"
                      @click="loadDashboard"
                    >
                      Refresh
                    </button>
                  </div>

                  <div class="stats-grid">
                    <article>
                      <span>Orders</span>
                      <strong>{{ dashboard.stats.orders_count }}</strong>
                    </article>
                    <article>
                      <span>Pending</span>
                      <strong>{{ dashboard.stats.pending_orders_count }}</strong>
                    </article>
                    <article>
                      <span>Users</span>
                      <strong>{{ dashboard.stats.users_count }}</strong>
                    </article>
                    <article>
                      <span>Revenue</span>
                      <strong>{{ dashboard.stats.revenue_lei.toLocaleString('ro-RO') }} Lei</strong>
                    </article>
                  </div>

                  <div class="orders-table">
                    <div class="orders-row orders-row--head">
                      <span>Date</span>
                      <span>Order</span>
                      <span>Customer</span>
                      <span>Status</span>
                      <span>Total</span>
                      <span>Admin comments</span>
                    </div>
                    <div
                      v-for="order in dashboard.orders"
                      :key="order.id"
                      class="orders-row"
                    >
                      <span>
                        <strong>{{ orderDate(order.created_at) }}</strong>
                        <small>{{ orderTime(order.created_at) }}</small>
                      </span>
                      <span>
                        <strong>#{{ order.id }} {{ order.mark }}</strong>
                        <small>{{ order.product_name }} · {{ order.classes }} classes</small>
                      </span>
                      <span>
                        <strong>{{ order.email }}</strong>
                        <small>{{ order.phone }}</small>
                        <small v-if="order.ip_address">IP: {{ order.ip_address }}</small>
                      </span>
                      <span class="order-payment">
                        <strong>{{ statusLabel(order.status) }}</strong>
                        <small>{{ paymentLabel(order.payment_method) }}</small>
                        <button
                          v-if="canMarkPaid(order)"
                          class="ghost-btn"
                          type="button"
                          :disabled="savingOrderId === order.id"
                          @click="markOrderPaid(order)"
                        >
                          {{ savingOrderId === order.id ? 'Saving...' : 'Mark paid' }}
                        </button>
                      </span>
                      <span>{{ order.total.formatted }}</span>
                      <span class="order-comments">
                        <textarea
                          v-model="order.admin_comments"
                          rows="3"
                          placeholder="Add internal note"
                        />
                        <button
                          class="ghost-btn"
                          type="button"
                          :disabled="savingOrderId === order.id"
                          @click="saveOrderComments(order)"
                        >
                          {{ savingOrderId === order.id ? 'Saving...' : 'Save' }}
                        </button>
                      </span>
                    </div>
                  </div>
                </div>

                <div
                  v-else
                  class="admin-section"
                >
                  <div class="section-title">
                    <h2>Settings</h2>
                  </div>

                  <div class="settings-grid">
                    <article>
                      <span>Admin account</span>
                      <strong>{{ currentUser?.email }}</strong>
                    </article>
                    <article>
                      <span>Product records</span>
                      <strong>{{ products.length }}</strong>
                    </article>
                  </div>

                  <form
                    class="theme-form"
                    @submit.prevent="saveTheme"
                  >
                    <div class="section-title">
                      <h2>Website theme</h2>
                      <button
                        class="ghost-btn"
                        type="button"
                        :disabled="themeSaving"
                        @click="loadTheme"
                      >
                        Reload
                      </button>
                    </div>

                    <div class="theme-grid">
                      <label class="theme-grid__wide">
                        Brand name
                        <input
                          v-model="themeForm.brand_name"
                          type="text"
                          placeholder="SANDU și Asociații IP Attorney"
                        >
                      </label>
                      <label class="theme-grid__wide">
                        Homepage hero image
                        <select v-model="themeForm.hero_image_key">
                          <option value="">Built-in default image</option>
                          <option
                            v-for="image in uploadedThemeImages"
                            :key="image.key"
                            :value="image.key"
                          >
                            {{ image.name }}
                          </option>
                        </select>
                      </label>
                      <label class="theme-grid__wide">
                        Website logo image
                        <select v-model="themeForm.logo_image_key">
                          <option value="">Built-in default logo</option>
                          <option
                            v-for="image in uploadedThemeImages"
                            :key="image.key"
                            :value="image.key"
                          >
                            {{ image.name }}
                          </option>
                        </select>
                      </label>
                      <label class="theme-grid__wide">
                        Upload theme image
                        <input
                          v-model="uploadThemeImageName"
                          type="text"
                          placeholder="Display name"
                        >
                        <input
                          type="file"
                          accept="image/*"
                          @change="selectUploadThemeImage"
                        >
                        <button
                          class="ghost-btn"
                          type="button"
                          :disabled="themeImageUploading || !uploadThemeImageFile"
                          @click="uploadThemeImage"
                        >
                          {{ themeImageUploading ? 'Uploading...' : 'Upload theme image' }}
                        </button>
                      </label>
                      <label class="theme-grid__wide">
                        Footer logo text
                        <textarea
                          v-model="themeForm.footer_text"
                          rows="5"
                          placeholder="Text shown next to the footer logo"
                        />
                      </label>
                      <label class="theme-grid__wide">
                        Terms and conditions
                        <textarea
                          v-model="themeForm.terms_content"
                          rows="12"
                          placeholder="# Termeni si conditii"
                        />
                      </label>
                      <label class="theme-grid__wide">
                        Privacy policy
                        <textarea
                          v-model="themeForm.privacy_policy_content"
                          rows="16"
                          placeholder="# Politica de confidentialitate"
                        />
                      </label>
                      <label
                        v-for="field in themeFields"
                        :key="field.key"
                      >
                        {{ field.label }}
                        <span
                          v-if="field.type === 'color'"
                          class="theme-color-control"
                        >
                          <input
                            v-model="themeForm[field.key]"
                            type="color"
                          >
                          <input
                            v-model="themeForm[field.key]"
                            type="text"
                            placeholder="#00add9"
                            pattern="^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$"
                          >
                        </span>
                        <input
                          v-else
                          v-model="themeForm[field.key]"
                          :placeholder="field.placeholder"
                        >
                      </label>
                    </div>

                    <div class="theme-preview">
                      <span :style="{ background: themeForm.brand_color }" />
                      <span :style="{ background: themeForm.primary_color }" />
                      <span :style="{ background: themeForm.primary_dark_color }" />
                      <strong :style="{ fontFamily: themeFontStack }">Theme preview</strong>
                    </div>

                    <div class="form-actions">
                      <button
                        class="primary-btn"
                        type="submit"
                        :disabled="themeSaving"
                      >
                        {{ themeSaving ? 'Saving theme...' : 'Save theme' }}
                      </button>
                    </div>

                    <p
                      v-if="themeMessage"
                      class="success-message"
                    >
                      {{ themeMessage }}
                    </p>
                  </form>

                  <h2>Recent users</h2>
                  <div class="user-list">
                    <article
                      v-for="user in dashboard.users"
                      :key="user.id"
                    >
                      <div>
                        <strong>{{ user.email }}</strong>
                        <span>{{ user.orders_count }} orders</span>
                      </div>
                      <span>{{ user.admin ? 'Admin' : 'Client' }}</span>
                    </article>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <p
            v-if="errorMessage"
            class="error-message"
          >
            {{ errorMessage }}
          </p>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import verbalTrademarkUrl from '../assets/images/MARCA_TA_VERBALA-removebg-preview.png'

const config = useRuntimeConfig()
const authToken = ref('')
const currentUser = ref(null)
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

const loginForm = reactive({
  email: '',
  password: '',
})
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

function authHeaders() {
  return authToken.value ? { Authorization: `Bearer ${authToken.value}` } : {}
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
  dashboard.value = null
  window.localStorage.removeItem('account-token')
  window.localStorage.removeItem('account-user')
}

function statusLabel(status) {
  const labels = {
    pending_payment: 'Pending payment',
    paid: 'Paid',
    processing: 'Processing',
    completed: 'Completed',
  }

  return labels[status] || status
}

function paymentLabel(paymentMethod) {
  const labels = {
    card: 'Card',
    paypal: 'PayPal',
    transfer: 'Bank transfer',
  }

  return labels[paymentMethod] || paymentMethod || 'Payment not selected'
}

function canMarkPaid(order) {
  return order.payment_method === 'transfer' && order.status !== 'paid'
}

function productImage(product) {
  return product.image || productImages[product.image_key]
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

    persistSession(payload.token, payload.user)
    await loadDashboard()
    await loadProducts()
    await loadProductImages()
    await loadThemeImages()
    await loadTheme()
  }
  catch (error) {
    clearSession()
    errorMessage.value = error instanceof Error ? error.message : 'Could not sign in.'
  }
  finally {
    loading.value = false
  }
}

async function hydrateSession() {
  const storedToken = window.localStorage.getItem('account-token')
  const storedUser = window.localStorage.getItem('account-user')

  if (!storedToken) return

  authToken.value = storedToken
  currentUser.value = storedUser ? JSON.parse(storedUser) : null

  if (!currentUser.value?.admin) {
    clearSession()
    return
  }

  await loadDashboard()
  await loadProducts()
  await loadProductImages()
  await loadThemeImages()
  await loadTheme()
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

    products.value = payload.products || []
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
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not save admin comments.'
  }
  finally {
    savingOrderId.value = null
  }
}

async function markOrderPaid(order) {
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
          status: 'paid',
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Could not mark payment.')
    }

    order.status = payload.order?.status || 'paid'
  }
  catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Could not mark payment.'
  }
  finally {
    savingOrderId.value = null
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

.error-message {
  margin: 18px 0 0;
  border: 1px solid #d7b7a9;
  background: #fff1eb;
  color: #8f3d22;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

@media (max-width: 920px) {
  .admin-layout,
  .admin-shell,
  .stats-grid,
  .settings-grid,
  .theme-grid,
  .orders-row,
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
