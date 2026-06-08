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
          <NuxtLink to="/#preturi">
            {{ t.quickRegistration }}
          </NuxtLink>
          <NuxtLink to="/#reinnoire">
            {{ t.quickRenewal }}
          </NuxtLink>
          <NuxtLink to="/#monitorizare">
            {{ t.quickMonitoring }}
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
          <NuxtLink
            v-if="cartItems.length"
            class="cart-nav-link"
            to="/checkout"
            :aria-label="`${t.cartNavLabel}: ${cartItems.length}`"
          >
            <span
              class="cart-nav-icon"
              aria-hidden="true"
            />
            <span class="cart-nav-count">{{ cartItems.length }}</span>
          </NuxtLink>
        </nav>
      </div>
    </header>

    <main class="account-main">
      <section class="wrap account-intro">
        <div>
          <p class="eyebrow">
            {{ t.eyebrow }}
          </p>
          <h1>{{ t.title }}</h1>
          <p>
            {{ t.copy }}
          </p>
        </div>
      </section>

      <section class="wrap account-panel">
        <p
          v-if="paymentReturnMessage"
          :class="paymentReturnClass"
        >
          {{ paymentReturnMessage }}
        </p>

        <div
          v-if="authHydrating"
          class="auth-shell"
        >
          <p class="muted">
            {{ t.loading }}
          </p>
        </div>

        <div
          v-else-if="!authToken"
          class="auth-shell"
        >
          <form
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

            <p class="muted">
              {{ t.authNote }}
            </p>
          </form>
        </div>

        <div
          v-else
          class="account-workspace"
        >
          <div class="account-overview">
            <div
              v-if="account"
              class="account-metrics"
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

            <div class="account-menu">
              <button
                type="button"
                class="account-menu__button"
                :aria-expanded="accountMenuOpen"
                @click="accountMenuOpen = !accountMenuOpen"
              >
                <span
                  class="account-avatar"
                  aria-hidden="true"
                >
                  {{ profileInitials }}
                </span>
                <span class="account-menu__label">
                  <span>{{ t.accountButton }}</span>
                  <strong>{{ profileDisplayName }}</strong>
                  <small>{{ t.accountSettingsHint }}</small>
                </span>
              </button>
              <div
                v-if="accountMenuOpen"
                class="account-menu__panel"
              >
                <div class="account-menu__user">
                  <strong>{{ profileDisplayName }}</strong>
                  <span>{{ currentUser?.email }}</span>
                  <button
                    type="button"
                    class="account-menu__edit"
                    @click="openBillingModal"
                  >
                    {{ t.editAccount }}
                  </button>
                </div>
                <div class="account-menu__status">
                  <span>{{ currentUser?.billing_complete ? t.billingCompleteTitle : t.billingIncompleteTitle }}</span>
                  <small>{{ currentUser?.billing_complete ? t.billingCompleteCopy : t.billingIncompleteCopy }}</small>
                </div>
                <button
                  type="button"
                  @click="logout"
                >
                  {{ t.logout }}
                </button>
              </div>
            </div>
          </div>

          <section class="orders-panel">
            <div class="panel-head">
              <div>
                <p class="panel-kicker">
                  {{ t.cartKicker }}
                </p>
                <h2>{{ t.cartTitle }}</h2>
              </div>
            </div>

            <p>{{ t.cartCopy }}</p>

            <div
              v-if="cartItems.length"
              class="account-cart-list"
            >
              <article
                v-for="item in cartItems"
                :key="item.id"
                class="account-cart-item"
              >
                <div>
                  <strong>{{ item.productTitle }}</strong>
                  <span>{{ item.mark }} · {{ item.classes }} {{ t.niceClasses }}</span>
                  <small v-if="item.ownerChangeRequested">{{ t.ownerChangeCartLabel }}</small>
                  <small>{{ item.primaryClass }}</small>
                </div>
                <div class="account-cart-item__meta">
                  <strong>{{ item.formattedTotal }}</strong>
                  <button
                    type="button"
                    class="remove-order-btn"
                    @click="removeFromCart(item.id)"
                  >
                    {{ t.removeFromCart }}
                  </button>
                </div>
              </article>
            </div>

            <p
              v-else
              class="muted empty-orders"
            >
              {{ t.emptyCart }}
            </p>

            <div
              v-if="cartItems.length"
              class="account-checkout-box"
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
                :disabled="!cartItems.length || submittingCheckout"
                @click="checkoutCart"
              >
                {{ submittingCheckout ? t.submitting : t.checkout }}
              </button>
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
          </section>

          <section class="orders-panel">
            <div class="panel-head">
              <div>
                <p class="panel-kicker">
                  {{ t.ordersKicker }}
                </p>
                <h2>{{ t.ordersTitle }}</h2>
              </div>
            </div>

            <p>{{ t.ordersCopy }}</p>

            <div
              v-if="account?.purchases?.length"
              class="purchase-list"
            >
              <article
                v-for="purchase in account.purchases"
                :key="purchase.id"
                class="purchase-item"
              >
                <div class="purchase-item__main">
                  <strong>{{ purchase.product_name || productTitle(purchase.product_code) }}</strong>
                  <span>{{ purchase.mark }} · {{ purchase.classes }} {{ t.niceClasses }}</span>
                  <small v-if="purchase.owner_change_requested">{{ t.ownerChangeCartLabel }}</small>
                </div>
                <div class="purchase-item__meta">
                  <strong>{{ purchase.total.formatted }}</strong>
                  <span>{{ statusLabel(purchase.status) }}</span>
                </div>
                <div class="purchase-item__actions">
                  <button
                    type="button"
                    class="remove-order-btn"
                    @click="downloadInvoice(purchase)"
                  >
                    {{ invoiceLabel(purchase) }}
                  </button>
                  <button
                    v-if="purchase.removable"
                    type="button"
                    class="remove-order-btn"
                    :disabled="removingPurchaseId === purchase.id"
                    @click="removePurchase(purchase)"
                  >
                    {{ removingPurchaseId === purchase.id ? t.removingPurchase : t.removePurchase }}
                  </button>
                </div>
              </article>
            </div>

            <p
              v-else-if="account"
              class="muted empty-orders"
            >
              {{ t.noPurchases }}
            </p>
          </section>
        </div>

        <p
          v-if="accountError"
          class="error-message"
        >
          {{ accountError }}
        </p>
      </section>

      <div
        v-if="billingModalOpen"
        class="modal-backdrop"
        @click.self="closeBillingModal"
      >
        <section
          class="billing-modal"
          role="dialog"
          aria-modal="true"
          :aria-label="t.billingTitle"
        >
          <div class="modal-head">
            <div>
              <p class="panel-kicker">
                {{ t.billingKicker }}
              </p>
              <h2>{{ t.billingTitle }}</h2>
            </div>
            <button
              type="button"
              class="modal-close"
              :aria-label="t.close"
              @click="closeBillingModal"
            >
              x
            </button>
          </div>

          <form
            class="billing-form"
            @submit.prevent="saveBillingProfile"
          >
            <p>{{ t.billingCopy }}</p>

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
                {{ billingFieldLabels.taxId }}
                <input
                  v-model="billingForm.taxId"
                  type="text"
                  :placeholder="billingFieldLabels.taxIdPlaceholder"
                >
              </label>
              <label>
                {{ billingFieldLabels.ownerName }}
                <input
                  v-model="billingForm.ownerName"
                  type="text"
                  :placeholder="billingFieldLabels.ownerNamePlaceholder"
                  required
                >
              </label>
            </div>

            <label>
              {{ billingFieldLabels.address }}
              <textarea
                v-model="billingForm.address"
                rows="4"
                :placeholder="billingFieldLabels.addressPlaceholder"
                required
              />
            </label>

            <div class="modal-actions">
              <button
                class="primary-btn"
                type="submit"
                :disabled="savingBilling"
              >
                {{ savingBilling ? t.saving : t.saveBilling }}
              </button>
              <button
                type="button"
                class="ghost-btn"
                @click="closeBillingModal"
              >
                {{ t.cancel }}
              </button>
            </div>

            <p
              v-if="billingMessage"
              class="success-message"
            >
              {{ billingMessage }}
            </p>
          </form>
        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'

const config = useRuntimeConfig()
const route = useRoute()
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
const authHydrating = ref(true)
const authenticating = ref(false)
const savingBilling = ref(false)
const billingMessage = ref('')
const billingModalOpen = ref(false)
const accountMenuOpen = ref(false)
const removingPurchaseId = ref(null)
const cartItems = ref([])
const checkoutPayment = ref('card')
const submittingCheckout = ref(false)
const checkoutMessage = ref('')
const checkoutError = ref('')
const paymentVerificationMessage = ref('')
const paymentVerificationState = ref('')

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
    authNote: 'Comenzile plasate cand esti autentificat vor fi legate automat de acest cont.',
    signedInAs: 'Autentificat ca',
    accountButton: 'Cont si setari',
    accountSettingsHint: 'Profil si facturare',
    editAccount: 'Editeaza contul',
    logout: 'Logout',
    billingTitle: 'Date contact si facturare',
    billingKicker: 'Profil',
    billingCopy: 'Completeaza aceste date inainte de checkout. Plata nu porneste fara un profil complet.',
    billingComplete: 'Profil complet',
    billingIncomplete: 'Date incomplete',
    billingCompleteTitle: 'Datele de facturare sunt completate',
    billingCompleteCopy: 'Le poti modifica oricand daca se schimba titularul sau adresa.',
    billingIncompleteTitle: 'Completeaza datele de facturare',
    billingIncompleteCopy: 'Ai nevoie de aceste date doar pentru checkout si procesarea comenzilor.',
    completeBilling: 'Completeaza datele',
    editBilling: 'Editeaza datele',
    close: 'Inchide',
    cancel: 'Renunta',
    phone: 'Telefon mobil',
    phonePlaceholder: '07xx xxx xxx',
    ownerType: 'Inregistrati marca pe',
    company: 'Societate',
    person: 'Persoana fizica',
    companyTaxId: 'CUI',
    companyTaxIdPlaceholder: 'RO12345678',
    companyOwnerName: 'Denumire societate',
    companyOwnerNamePlaceholder: 'Compania SRL',
    companyAddress: 'Sediu social / adresa de facturare',
    companyAddressPlaceholder: 'Strada, numar, localitate, judet',
    personTaxId: 'CNP',
    personTaxIdPlaceholder: 'CNP',
    personOwnerName: 'Nume si prenume',
    personOwnerNamePlaceholder: 'Nume Prenume',
    personAddress: 'Adresa domiciliu / facturare',
    personAddressPlaceholder: 'Strada, numar, localitate, judet',
    saveBilling: 'Salveaza datele',
    saving: 'Se salveaza...',
    billingSaved: 'Datele de contact si facturare au fost salvate.',
    removePurchase: 'Elimina din cont',
    removingPurchase: 'Se elimina...',
    removePurchaseConfirm: 'Elimini aceasta comanda din cont?',
    purchaseRemoved: 'Comanda a fost eliminata din cont.',
    downloadInvoice: 'Descarca factura',
    downloadProforma: 'Descarca proforma',
    ordersKicker: 'Istoric',
    ordersTitle: 'Comenzile mele',
    ordersCopy: 'Comenzile eliminate dispar doar din contul tau. Ele raman disponibile intern pentru procesare si suport.',
    orders: 'Comenzi',
    cartKicker: 'Cos',
    cartTitle: 'Cos si checkout',
    cartCopy: 'Finalizeaza produsele salvate in cos direct din contul tau.',
    cartTotal: 'Total cos',
    mixedCurrencyCartTotal: 'Totaluri separate',
    cartNavLabel: 'Cos',
    emptyCart: 'Cosul este gol. Configureaza o marca si adaug-o in cos.',
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
    paymentReturnSuccess: 'Verificam plata cu procesatorul...',
    paymentVerified: 'Plata a fost confirmata. Comanda a fost marcata ca platita.',
    paymentNotVerified: 'Nu am putut confirma inca plata. Verifica tranzactia in procesator sau incearca din nou.',
    paymentReturnCancelled: 'Plata a fost anulata. Comanda ramane salvata in cont si poate fi reluata sau verificata.',
    checkoutBillingRequired: 'Completeaza datele de contact si facturare inainte de plata.',
    checkoutReady: 'Contul are datele necesare pentru checkout.',
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
      'monitoring-brand': 'Monitorizare marca',
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
    authNote: 'Orders placed while signed in will be attached to this account automatically.',
    signedInAs: 'Signed in as',
    accountButton: 'Account & settings',
    accountSettingsHint: 'Profile and billing',
    editAccount: 'Edit account',
    logout: 'Logout',
    billingTitle: 'Contact and billing details',
    billingKicker: 'Profile',
    billingCopy: 'Complete these details before checkout. Payment cannot start without a complete profile.',
    billingComplete: 'Complete profile',
    billingIncomplete: 'Incomplete details',
    billingCompleteTitle: 'Billing details are complete',
    billingCompleteCopy: 'You can edit them any time if the owner or address changes.',
    billingIncompleteTitle: 'Complete billing details',
    billingIncompleteCopy: 'These details are only needed for checkout and order processing.',
    completeBilling: 'Complete details',
    editBilling: 'Edit details',
    close: 'Close',
    cancel: 'Cancel',
    phone: 'Mobile phone',
    phonePlaceholder: '+40...',
    ownerType: 'Register the trademark for',
    company: 'Company',
    person: 'Individual',
    companyTaxId: 'VAT / tax identifier',
    companyTaxIdPlaceholder: 'RO12345678',
    companyOwnerName: 'Company name',
    companyOwnerNamePlaceholder: 'Company LLC',
    companyAddress: 'Registered office / billing address',
    companyAddressPlaceholder: 'Street, number, city, county',
    personTaxId: 'Personal numeric code',
    personTaxIdPlaceholder: 'CNP',
    personOwnerName: 'Full name',
    personOwnerNamePlaceholder: 'First name Last name',
    personAddress: 'Home / billing address',
    personAddressPlaceholder: 'Street, number, city, county',
    saveBilling: 'Save details',
    saving: 'Saving...',
    billingSaved: 'Contact and billing details were saved.',
    removePurchase: 'Remove from account',
    removingPurchase: 'Removing...',
    removePurchaseConfirm: 'Remove this order from your account?',
    purchaseRemoved: 'The order was removed from your account.',
    downloadInvoice: 'Download invoice',
    downloadProforma: 'Download proforma',
    ordersKicker: 'History',
    ordersTitle: 'My orders',
    ordersCopy: 'Removed orders disappear only from your account. They remain available internally for processing and support.',
    orders: 'Orders',
    cartKicker: 'Cart',
    cartTitle: 'Cart and checkout',
    cartCopy: 'Complete your saved cart items directly from your account.',
    cartTotal: 'Cart total',
    mixedCurrencyCartTotal: 'Separate totals',
    cartNavLabel: 'Cart',
    emptyCart: 'Your cart is empty. Configure a trademark and add it to the cart.',
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
    paymentReturnSuccess: 'Checking the payment with the processor...',
    paymentVerified: 'Payment was confirmed. The order was marked as paid.',
    paymentNotVerified: 'We could not confirm the payment yet. Check the processor transaction or try again.',
    paymentReturnCancelled: 'Payment was cancelled. The order remains saved in your account and can be retried or checked.',
    checkoutBillingRequired: 'Complete contact and billing details before payment.',
    checkoutReady: 'Your account has the details required for checkout.',
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
      'monitoring-brand': 'Trademark monitoring',
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
const cartTotal = computed(() => cartItems.value.reduce((sum, item) => sum + Number(item.total || 0), 0))
const cartCurrencies = computed(() => [...new Set(cartItems.value.map(item => item.currency || 'RON'))])
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

function setLanguage(code) {
  selectedLanguage.value = code
}

function authHeaders() {
  return authToken.value ? { Authorization: `Bearer ${authToken.value}` } : {}
}

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

function openBillingModal() {
  billingMessage.value = ''
  accountMenuOpen.value = false
  billingModalOpen.value = true
}

function closeBillingModal() {
  if (savingBilling.value) return

  billingModalOpen.value = false
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

    cartItems.value = []
    persistCart()
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
    await verifyReturnedPayment()
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

  if (!storedToken) {
    authHydrating.value = false
    return
  }

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      headers: { Authorization: `Bearer ${storedToken}` },
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) throw new Error()

    persistSession(storedToken, payload.user)
    await loadAccount()
    await verifyReturnedPayment()
  }
  catch {
    clearSession()
  }
  finally {
    authHydrating.value = false
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
  loadCart()
})

watch(selectedLanguage, (language) => {
  window.localStorage.setItem('preferred-language', language)
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
