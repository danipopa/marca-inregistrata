<template>
  <div class="admin-page">
    <header class="admin-header">
      <div class="wrap admin-header__inner">
        <NuxtLink
          class="brand"
          to="/"
          aria-label="Sandu si asociatii"
        >
          <span class="brand__mark">DS</span>
          <span>
            <strong>SANDU</strong>
            <small>ADMIN</small>
          </span>
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
        <div class="admin-copy">
          <p class="eyebrow">
            Back office
          </p>
          <h1>Admin</h1>
          <p>
            Manage trademark orders, customer accounts, payment status, and operational totals.
          </p>
        </div>

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
            <div class="signed-in-bar">
              <div>
                <span>Signed in as</span>
                <strong>{{ currentUser?.email }}</strong>
              </div>
              <button
                class="ghost-btn"
                type="button"
                @click="logout"
              >
                Logout
              </button>
            </div>

            <div
              v-if="dashboard"
              class="stats-grid"
            >
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

            <div
              v-if="dashboard"
              class="admin-section"
            >
              <div class="section-title">
                <h2>Recent orders</h2>
                <button
                  class="ghost-btn"
                  type="button"
                  :disabled="loading"
                  @click="loadDashboard"
                >
                  Refresh
                </button>
              </div>

              <div class="orders-table">
                <div class="orders-row orders-row--head">
                  <span>Order</span>
                  <span>Customer</span>
                  <span>Status</span>
                  <span>Total</span>
                </div>
                <div
                  v-for="order in dashboard.orders"
                  :key="order.id"
                  class="orders-row"
                >
                  <span>
                    <strong>#{{ order.id }} {{ order.mark }}</strong>
                    <small>{{ order.product_name }} · {{ order.classes }} classes</small>
                  </span>
                  <span>
                    <strong>{{ order.email }}</strong>
                    <small>{{ order.phone }}</small>
                  </span>
                  <span>{{ statusLabel(order.status) }}</span>
                  <span>{{ order.total.formatted }}</span>
                </div>
              </div>
            </div>

            <div
              v-if="dashboard"
              class="admin-section"
            >
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
import { onMounted, reactive, ref } from 'vue'

const config = useRuntimeConfig()
const authToken = ref('')
const currentUser = ref(null)
const dashboard = ref(null)
const loading = ref(false)
const errorMessage = ref('')

const loginForm = reactive({
  email: '',
  password: '',
})

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
  --paper: #fbfaf7;
  --gold: #b79254;
  --gold-dark: #8a6837;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--paper);
  color: var(--ink);
  font-family: Georgia, 'Times New Roman', serif;
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

.admin-header {
  border-bottom: 1px solid var(--line);
  background: rgba(251, 250, 247, 0.96);
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

.brand__mark {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border: 1px solid var(--gold);
  color: var(--gold-dark);
  font-size: 26px;
  line-height: 1;
}

.brand strong,
.brand small {
  display: block;
  letter-spacing: 0.12em;
}

.brand strong {
  font-size: 18px;
}

.brand small,
.admin-nav,
.admin-copy p:not(.eyebrow),
.orders-row small,
.signed-in-bar span,
.user-list span {
  color: var(--muted);
  font-family: Arial, sans-serif;
}

.brand small {
  font-size: 10px;
  margin-top: 2px;
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
  padding: 56px 0;
}

.admin-layout {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 34px;
  align-items: start;
}

.eyebrow {
  margin: 0 0 10px;
  color: var(--gold);
  font-family: Arial, sans-serif;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.admin-copy h1 {
  margin: 0;
  font-size: 62px;
  font-weight: 400;
  line-height: 1;
}

.admin-copy p:not(.eyebrow) {
  line-height: 1.7;
}

.admin-panel {
  border: 1px solid var(--line);
  background: #fff;
  padding: 24px;
}

.admin-login,
.admin-dashboard {
  display: grid;
  gap: 18px;
}

.admin-login label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: Arial, sans-serif;
  font-weight: 700;
}

.admin-login input {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.primary-btn,
.ghost-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border-radius: 2px;
  cursor: pointer;
  font-family: Arial, sans-serif;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.primary-btn {
  border: 0;
  background: var(--gold);
  color: #191713;
  padding: 0 22px;
}

.ghost-btn {
  border: 1px solid var(--gold);
  background: transparent;
  color: var(--gold-dark);
  padding: 0 20px;
}

.signed-in-bar,
.section-title,
.user-list article {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.signed-in-bar,
.stats-grid article,
.user-list article {
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 16px;
  font-family: Arial, sans-serif;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.stats-grid span {
  display: block;
  color: var(--muted);
  font-family: Arial, sans-serif;
  margin-bottom: 8px;
}

.stats-grid strong {
  font-family: Georgia, 'Times New Roman', serif;
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
.user-list {
  display: grid;
  gap: 8px;
}

.orders-row {
  display: grid;
  grid-template-columns: 1.4fr 1.3fr 0.8fr 0.7fr;
  gap: 14px;
  align-items: center;
  border: 1px solid var(--line);
  padding: 14px;
  font-family: Arial, sans-serif;
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

.error-message {
  margin: 18px 0 0;
  border: 1px solid #d7b7a9;
  background: #fff1eb;
  color: #8f3d22;
  padding: 14px;
  font-family: Arial, sans-serif;
  font-weight: 700;
}

@media (max-width: 920px) {
  .admin-layout,
  .stats-grid,
  .orders-row {
    grid-template-columns: 1fr;
  }

  .admin-header__inner,
  .signed-in-bar,
  .section-title,
  .user-list article {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
