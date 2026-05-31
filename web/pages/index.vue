<template>
  <div class="page-shell">
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
          <a href="#despre">{{ t.navAbout }}</a>
          <NuxtLink to="/account">{{ t.navAccount }}</NuxtLink>
          <a href="#contact">{{ t.navContact }}</a>
        </nav>
      </div>
    </div>

    <header class="main-header">
      <div class="wrap main-header__inner">
        <a
          class="brand"
          href="#"
          :aria-label="brandName"
        >
          <span
            class="brand__logo"
            :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
            role="img"
            :aria-label="brandName"
          />
        </a>
        <nav
          aria-label="Servicii rapide"
          class="main-nav"
        >
          <a href="#reinnoire">{{ t.quickRenewal }}</a>
          <a href="#monitorizare">{{ t.quickMonitoring }}</a>
          <a href="#preturi">{{ t.quickRegistration }}</a>
          <a href="#verificare">{{ t.quickCheck }}</a>
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

    <main>
      <section
        class="hero"
        :style="{ '--fallback-hero-image': `url(${heroHomeUrl})` }"
      >
        <div class="wrap hero__grid">
          <div class="hero__copy">
            <p class="eyebrow">
              {{ t.heroEyebrow }}
            </p>
            <h1>{{ t.heroTitle }}</h1>
            <p class="lead">
              {{ t.heroLead }}
            </p>
            <div class="hero__actions">
              <a
                class="primary-btn"
                href="#preturi"
              >{{ t.heroPackages }}</a>
              <a
                class="outline-light-btn"
                href="/account"
              >{{ t.heroAccount }}</a>
              <a
                class="text-link"
                href="#formular"
              >{{ t.heroForm }}</a>
            </div>
          </div>

          <aside
            class="secure-panel"
            :aria-label="t.secureTitle"
          >
            <div class="secure-panel__icon">
              SSL
            </div>
            <div>
              <strong>{{ t.secureTitle }}</strong>
              <span>{{ t.secureCopy }}</span>
            </div>
          </aside>
        </div>
      </section>

      <section
        id="preturi"
        class="pricing-section"
      >
        <div class="wrap">
          <div class="section-head">
            <p class="eyebrow">
              OSIM / EUIPO
            </p>
            <h2>{{ t.pricingTitle }}</h2>
          </div>

          <div
            class="currency-tabs"
            role="tablist"
            :aria-label="t.currencyLabel"
          >
            <button
              v-for="currency in currencies"
              :key="currency.code"
              type="button"
              :class="{ active: selectedCurrency === currency.code }"
              @click="selectedCurrency = currency.code"
            >
              {{ currency.label }}
            </button>
          </div>

          <div class="price-grid">
            <article
              v-for="plan in visiblePlans"
              :key="plan.code"
              class="price-card"
              :class="{ selected: selectedProductCode === plan.code }"
            >
              <div class="price-card__top">
                <span class="country-pill">{{ plan.region }}</span>
                <h3>{{ plan.title }}</h3>
                <img
                  v-if="plan.image"
                  class="price-card__image"
                  :src="plan.image"
                  :alt="plan.title"
                >
                <p v-if="plan.note">
                  {{ plan.note }}
                </p>
              </div>
              <div class="price">
                <span>{{ plan.price }}</span>
                <small>{{ plan.tax }}</small>
              </div>
              <ul>
                <li
                  v-for="item in plan.items"
                  :key="item"
                >
                  {{ item }}
                </li>
              </ul>
              <a
                href="#formular"
                class="register-btn"
                @click="selectProduct(plan.code)"
              >{{ t.buy }}</a>
              <p class="card-foot">
                {{ t.secureTitle }}
              </p>
            </article>
          </div>

          <p
            v-if="!visiblePlans.length"
            class="empty-products"
          >
            {{ t.emptyProducts }}
          </p>
        </div>
      </section>

      <section
        id="verificare"
        class="start-band"
      >
        <div class="wrap start-band__inner">
          <div>
            <p class="eyebrow">
              {{ t.startEyebrow }}
            </p>
            <h2>{{ t.startTitle }}</h2>
          </div>
          <p>
            {{ t.startCopy }}
          </p>
          <a
            class="outline-btn"
            href="#formular"
          >{{ t.startCta }}</a>
        </div>
      </section>

      <section
        id="monitorizare"
        class="monitoring-section"
      >
        <div class="wrap monitoring-layout">
          <div class="monitoring-copy">
            <p class="eyebrow">
              {{ t.monitoringEyebrow }}
            </p>
            <h2>{{ t.monitoringTitle }}</h2>
            <p class="muted">
              {{ t.monitoringCopy }}
            </p>
          </div>

          <div class="monitoring-panel">
            <form
              class="monitoring-form"
              @submit.prevent="searchMonitoring"
            >
              <label>
                {{ t.monitoringMarkLabel }}
                <input
                  v-model="monitoringForm.mark"
                  type="search"
                  :placeholder="t.monitoringMarkPlaceholder"
                  required
                  minlength="2"
                >
              </label>

              <div class="field-grid">
                <label>
                  {{ t.monitoringOfficeLabel }}
                  <select
                    v-model="monitoringForm.offices"
                    multiple
                  >
                    <option value="RO">
                      OSIM / RO
                    </option>
                    <option value="EM">
                      EUIPO / UE
                    </option>
                    <option value="WO">
                      WIPO
                    </option>
                  </select>
                </label>

                <label>
                  {{ t.monitoringClassLabel }}
                  <select
                    v-model="monitoringForm.classes"
                    multiple
                  >
                    <option
                      v-for="niceClass in niceClasses"
                      :key="niceClass.number"
                      :value="String(niceClass.number)"
                    >
                      {{ selectedLanguage === 'ro' ? `Clasa ${niceClass.number}` : `Class ${niceClass.number}` }}
                    </option>
                  </select>
                </label>
              </div>

              <button
                class="primary-btn"
                type="submit"
                :disabled="monitoringLoading"
              >
                {{ monitoringLoading ? t.monitoringLoading : t.monitoringSubmit }}
              </button>
            </form>

            <p
              v-if="monitoringError"
              class="error-message"
            >
              {{ monitoringError }}
            </p>

            <div
              v-if="monitoringSearched && !monitoringLoading"
              class="monitoring-results"
            >
              <div class="monitoring-results__head">
                <span>{{ t.monitoringResults }}</span>
                <strong>{{ monitoringTotalLabel }}</strong>
              </div>

              <article
                v-for="result in monitoringResults"
                :key="result.id || `${result.name}-${result.office}`"
                class="monitoring-item"
              >
                <div>
                  <strong>{{ result.name || t.monitoringUntitled }}</strong>
                  <span>{{ result.office || t.monitoringUnknownOffice }} · {{ result.status || t.monitoringUnknownStatus }}</span>
                  <small v-if="result.owner">{{ result.owner }}</small>
                  <small v-if="result.nice_classes?.length">{{ t.monitoringClasses }} {{ result.nice_classes.join(', ') }}</small>
                </div>
                <a
                  v-if="result.source_url"
                  class="text-danger"
                  :href="result.source_url"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {{ t.monitoringOpen }}
                </a>
              </article>

              <p
                v-if="!monitoringResults.length"
                class="muted"
              >
                {{ t.monitoringNoResults }}
              </p>
            </div>
          </div>
        </div>
      </section>

      <section
        id="formular"
        class="form-section"
      >
        <div class="wrap form-layout">
          <aside class="form-summary">
            <span class="country-pill">RO</span>
            <h2>{{ selectedProduct?.title || t.emptyProducts }}</h2>
            <p
              v-if="selectedProduct"
              class="muted"
            >
              {{ selectedProduct.note }}.
            </p>

            <div class="summary-box">
              <span>{{ t.summaryTotal }}</span>
              <strong>{{ formattedTotal }}</strong>
              <small>{{ t.summaryNote }}</small>
            </div>

            <ol class="steps">
              <li
                v-for="(step, index) in steps"
                :key="step"
                :class="{ active: currentStep === index }"
              >
                <span>{{ index + 1 }}</span>
                {{ step }}
              </li>
            </ol>
          </aside>

          <div
            class="registration-form"
          >
            <div
              v-if="currentStep === 0"
              class="form-step"
            >
              <h2>{{ t.stepOneTitle }}</h2>
              <p class="muted">
                {{ t.stepOneCopy }}
              </p>
              <label>
                {{ t.productLabel }} *
                <select
                  v-model="selectedProductCode"
                  required
                >
                  <option
                    v-for="plan in plans"
                    :key="plan.code"
                    :value="plan.code"
                  >
                    {{ plan.region }} - {{ plan.title }} ({{ plan.price }})
                  </option>
                </select>
              </label>
              <label>
                {{ t.markLabel }} *
                <input
                  v-model="form.mark"
                  type="text"
                  :placeholder="t.markPlaceholder"
                  required
                >
              </label>
              <label>
                {{ t.classesLabel }} *
                <select v-model.number="form.classes">
                  <option
                    v-for="count in 11"
                    :key="count"
                    :value="count"
                  >
                    {{ classLabel(count) }}
                  </option>
                </select>
              </label>
              <div class="included-box">
                <strong>{{ t.includedTitle }}</strong>
                <span>{{ t.includedCopy }}</span>
              </div>
            </div>

            <div
              v-else-if="currentStep === 1"
              class="form-step"
            >
              <h2>{{ t.stepTwoTitle }}</h2>
              <p class="muted">
                {{ t.stepTwoCopy }}
              </p>
              <label>
                {{ t.primaryClassLabel }} *
                <select
                  v-model="form.primaryClass"
                  required
                >
                  <option
                    value=""
                    disabled
                  >{{ t.primaryClassPlaceholder }}</option>
                  <option
                    v-for="niceClass in niceClasses"
                    :key="niceClass.number"
                    :value="niceClass.value"
                  >
                    {{ niceClass.label }}
                  </option>
                </select>
              </label>
              <div
                v-if="selectedNiceClass"
                class="nice-class-details"
              >
                <div class="nice-class-details__head">
                  <span class="country-pill">{{ selectedNiceClass.typeLabel }}</span>
                  <small>{{ t.niceSource }}</small>
                </div>
                <strong>{{ t.niceOfficialTitle }}</strong>
                <p>{{ selectedNiceClass.detail }}</p>
                <div class="included-box">
                  <strong>{{ t.niceGuidanceTitle }}</strong>
                  <span>{{ t.niceGuidanceCopy }}</span>
                  <span v-if="form.classes > 1">{{ t.extraClassesHint }}</span>
                </div>
              </div>
              <label>
                {{ t.goodsLabel }}
                <textarea
                  v-model="form.goods"
                  rows="5"
                  :placeholder="t.goodsPlaceholder"
                />
              </label>
            </div>

            <div
              v-else-if="currentStep === 2"
              class="form-step"
            >
              <h2>{{ t.stepFourTitle }}</h2>
              <p class="muted">
                {{ t.stepFourCopy }}
              </p>
              <div class="payment-card">
                <strong>{{ formattedTotal }}</strong>
                <span v-if="selectedProduct">{{ selectedProduct.title }}</span>
                <span>{{ form.mark }}</span>
                <small>{{ t.addToCartPaymentNote }}</small>
              </div>
              <label class="checkbox">
                <input
                  v-model="form.terms"
                  type="checkbox"
                  required
                >
                {{ t.termsLabel }}
              </label>
            </div>

            <div class="form-actions">
              <button
                type="button"
                class="ghost-btn"
                :disabled="currentStep === 0"
                @click="currentStep--"
              >
                {{ t.back }}
              </button>
              <button
                v-if="currentStep < steps.length - 1"
                type="button"
                class="primary-btn"
                @click="currentStep++"
              >
                {{ t.next }}
              </button>
              <button
                v-else
                type="button"
                class="primary-btn"
                :disabled="!canAddToCart"
                @click="addToCart"
              >
                {{ t.addToCart }}
              </button>
            </div>

            <p
              v-if="cartMessage"
              class="success-message"
            >
              {{ cartMessage }}
            </p>

            <p
              v-if="submitError"
              class="error-message"
            >
              {{ submitError }}
            </p>
          </div>
        </div>
      </section>

      <section
        id="cos"
        class="cart-section"
      >
        <div class="wrap cart-layout">
          <div>
            <p class="eyebrow">
              {{ t.cartEyebrow }}
            </p>
            <h2>{{ t.cartTitle }}</h2>
            <p class="muted">
              {{ t.cartCopy }}
            </p>
          </div>

          <div class="cart-panel">
            <div
              v-if="cartItems.length"
              class="cart-list"
            >
              <article
                v-for="item in cartItems"
                :key="item.id"
                class="cart-item"
              >
                <div>
                  <strong>{{ item.productTitle }}</strong>
                  <span>{{ item.mark }} · {{ item.classes }} {{ t.niceClassesShort }}</span>
                  <small>{{ item.primaryClass }}</small>
                </div>
                <div>
                  <strong>{{ item.formattedTotal }}</strong>
                  <button
                    type="button"
                    class="text-danger"
                    @click="removeFromCart(item.id)"
                  >
                    {{ t.remove }}
                  </button>
                </div>
              </article>
            </div>

            <p
              v-else
              class="muted"
            >
              {{ t.emptyCart }}
            </p>

            <div class="checkout-box">
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
                :disabled="!cartItems.length || submitting"
                @click="checkoutCart"
              >
                {{ submitting ? t.submitting : t.checkout }}
              </button>
            </div>
          </div>
        </div>
      </section>
    </main>

    <footer
      id="contact"
      class="site-footer"
    >
      <div class="wrap footer-grid">
        <div class="footer-brand">
          <span
            class="footer-brand__logo"
            :style="{ '--footer-fallback-logo-image': `url(${footerLogoUrl})` }"
            role="img"
            :aria-label="brandName"
          />
          <p>
            {{ footerCopy }}
          </p>
        </div>

        <nav
          aria-label="Servicii"
          class="footer-column"
        >
          <h2>{{ t.footerResources }}</h2>
          <a href="#verificare">{{ t.quickCheck }}</a>
          <a href="#formular">{{ t.quickRegistration }}</a>
          <a href="#monitorizare">{{ t.quickMonitoring }}</a>
          <a href="#reinnoire">{{ t.quickRenewal }}</a>
        </nav>

        <div class="footer-column">
          <h2>Contact</h2>
          <a href="tel:0770898767">0770 898 767</a>
          <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
          <span>{{ t.businessHours }}</span>
        </div>

        <nav
          aria-label="Linkuri ANPC"
          class="footer-column anpc-links"
        >
          <h2>ANPC</h2>
          <a
            href="https://anpc.ro/"
            target="_blank"
            rel="noopener noreferrer"
          >ANPC</a>
          <a
            href="https://ec.europa.eu/consumers/odr"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{ t.odr }}
          </a>
          <a
            href="https://anpc.ro/ce-este-sal/"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{ t.sal }}
          </a>
        </nav>
      </div>

      <div class="wrap footer-bottom">
        <span>{{ copyrightText }}</span>
        <span class="legal-links">
          <NuxtLink to="/politica-de-confidentialitate">
            {{ t.privacyPolicy }}
          </NuxtLink>
          <NuxtLink to="/termeni-si-conditii">
            {{ t.termsOfUse }}
          </NuxtLink>
        </span>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { niceClasses2024 } from '~/data/niceClasses2024'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'
import footerLogoUrl from '../assets/images/logo_footbar-removebg-preview.png'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import heroHomeUrl from '../assets/images/img_home.png'
import verbalTrademarkUrl from '../assets/images/MARCA_TA_VERBALA-removebg-preview.png'

const currencies = [
  { code: 'RON', label: 'OSIM' },
  { code: 'EUR', label: 'EUIPO' },
]
const languages = [
  { code: 'ro', label: 'RO' },
  { code: 'en', label: 'EN' },
]
const selectedLanguage = ref('ro')
const selectedCurrency = ref('RON')
const selectedProductCode = ref('ro-word')
const productCatalog = ref([])
const siteTheme = ref({})
const currentStep = ref(0)
const submitting = ref(false)
const submitError = ref('')
const cartMessage = ref('')
const cartItems = ref([])
const authToken = ref('')
const currentUser = ref(null)
const checkoutPayment = ref('card')
const monitoringLoading = ref(false)
const monitoringError = ref('')
const monitoringSearched = ref(false)
const monitoringResults = ref([])
const monitoringTotal = ref(0)
const config = useRuntimeConfig()

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
    heroEyebrow: 'Proprietate industriala',
    heroTitle: 'Inregistrare marca in Romania/UE',
    heroLead: 'Procedura asistata pentru OSIM si EUIPO, cu onorarii clare, taxe oficiale incluse si documentatie pregatita pe baza datelor completate online.',
    heroPackages: 'Vezi pachetele',
    heroAccount: 'Contul meu',
    heroForm: 'Completeaza formularul',
    secureTitle: 'Conexiune securizata',
    secureCopy: 'Plata online si datele de contact sunt gestionate in pasi separati.',
    pricingTitle: 'Alege tipul de marca',
    emptyProducts: 'Nu exista produse configurate inca.',
    currencyLabel: 'Oficiu',
    buy: 'Adauga in cos',
    startEyebrow: 'Nu stiti de unde sa incepeti?',
    startTitle: 'Incepeti cu o verificare de marca',
    startCopy: 'O analiza prealabila ajuta la identificarea riscurilor inainte de depunere. Pentru comenzi complexe, echipa poate clarifica produsele si serviciile potrivite.',
    startCta: 'Solicita verificare',
    monitoringEyebrow: 'Monitorizare marca',
    monitoringTitle: 'Cautare rapida marci',
    monitoringCopy: 'Verificati denumiri similare in registrele publice pentru Romania, Uniunea Europeana si WIPO.',
    monitoringMarkLabel: 'Denumire marca',
    monitoringMarkPlaceholder: 'Ex: NUMELE BRANDULUI',
    monitoringOfficeLabel: 'Oficii',
    monitoringClassLabel: 'Clase NISA',
    monitoringSubmit: 'Cauta marca',
    monitoringLoading: 'Se cauta...',
    monitoringResults: 'Rezultate',
    monitoringOpen: 'Deschide',
    monitoringClasses: 'Clase:',
    monitoringUntitled: 'Marca fara denumire',
    monitoringUnknownOffice: 'Oficiu necunoscut',
    monitoringUnknownStatus: 'Status necunoscut',
    monitoringNoResults: 'Nu am gasit rezultate pentru cautarea curenta.',
    monitoringError: 'Nu am putut interoga registrele publice. Incercati din nou.',
    summaryTotal: 'Cost total estimat',
    summaryNote: 'include TVA, onorariu si taxe oficiale pentru selectia curenta',
    stepOneTitle: 'Inregistrare marca verbala OSIM',
    stepOneCopy: 'Completati atent. Documentatia pentru OSIM se pregateste pe baza acestor informatii.',
    productLabel: 'Produs',
    markLabel: 'Marca pe care doriti sa o inregistrati',
    markPlaceholder: 'Ex: NUMELE BRANDULUI',
    classesLabel: 'Cate clase NISA doriti sa protejati?',
    oneClass: 'O clasa NISA (inclusa)',
    multipleClasses: count => `${count} clase NISA (+${(count - 1) * 449} Lei)`,
    includedTitle: 'Pretul include',
    includedCopy: 'consultanta prealabila, detaliere clase NISA, depunere, raportari si certificatul original.',
    stepTwoTitle: 'Selectie clase NISA',
    stepTwoCopy: 'Alegeti clasele dorite. Dupa depunere, clasele si produsele nu pot fi adaugate retroactiv.',
    primaryClassLabel: 'Clasa NISA inclusa',
    primaryClassPlaceholder: 'Selectati clasa NISA inclusa',
    niceSource: 'Sursa: Clasificarea Nisa, editia a 12-a, versiunea 2024, OSIM',
    niceGoods: 'Produse',
    niceServices: 'Servicii',
    niceOfficialTitle: 'Titlul clasei conform PDF',
    niceGuidanceTitle: 'Detalii pentru formular',
    niceGuidanceCopy: 'Folositi descrierea de mai jos ca reper, apoi scrieti concret produsele sau serviciile brandului dumneavoastra in campul urmator.',
    extraClassesHint: 'Ati ales mai multe clase. Treceti clasele suplimentare si produsele/serviciile aferente in descriere.',
    goodsLabel: 'Descrieti produsele sau serviciile',
    goodsPlaceholder: 'Ex: magazin online de haine, productie software, servicii de marketing',
    stepThreeTitle: 'Date contact si facturare',
    phoneLabel: 'Telefon mobil',
    phonePlaceholder: '07xx xxx xxx',
    ownerTypeLabel: 'Inregistrati marca pe',
    company: 'Societate',
    person: 'Persoana fizica',
    taxIdLabel: 'CUI / identificator fiscal',
    ownerNameLabel: 'Denumire titular',
    ownerNamePlaceholder: 'Compania SRL',
    addressLabel: 'Adresa de facturare',
    addressPlaceholder: 'Strada, numar, localitate, judet',
    stepFourTitle: 'Revizuire solicitare',
    stepFourCopy: 'Verificati detaliile marcii si acceptati termenii pentru a pune produsul in cos.',
    cardPayment: 'Plata cu cardul prin Stripe',
    paypalPayment: 'Plata prin PayPal',
    bankPayment: 'Plata prin transfer bancar',
    cardPaymentDescription: 'Visa / Mastercard / Amex / Google Pay prin Stripe Checkout',
    paypalPaymentDescription: 'PayPal Checkout cu redirectionare securizata',
    bankPaymentDescription: 'Veti primi detaliile pentru transfer dupa inregistrarea comenzii',
    paymentNote: 'Procesare securizata. Datele cardului nu sunt salvate local.',
    addToCartPaymentNote: 'Metoda de plata se alege la checkout, dupa ce produsul este in cos.',
    checkoutPaymentLabel: 'Metoda de plata',
    termsLabel: 'Sunt de acord cu termenii de utilizare si politica de confidentialitate.',
    back: 'Inapoi',
    next: 'Pasul urmator',
    submitting: 'Se trimite...',
    submit: 'Gata de inregistrare',
    addToCart: 'Adauga in cos',
    cartAdded: 'Produsul a fost adaugat in cos.',
    cartEyebrow: 'Cos',
    cartTitle: 'Cos si checkout',
    cartCopy: 'Revizuiti produsele configurate, alegeti metoda de plata si finalizati checkout-ul.',
    cartTotal: 'Total cos',
    checkout: 'Checkout',
    emptyCart: 'Cosul este gol. Configurati o marca si adaugati-o in cos.',
    remove: 'Sterge',
    checkoutSuccess: 'Comanda a fost trimisa.',
    checkoutLoginRequired: 'Autentifica-te in cont inainte de checkout.',
    checkoutBillingRequired: 'Completeaza datele de contact si facturare in cont inainte de plata.',
    checkoutReady: 'Contul are datele necesare pentru checkout.',
    checkoutNeedsAccount: 'Checkout-ul necesita cont si date de facturare.',
    successFallback: 'Solicitarea a fost inregistrata.',
    submitError: 'Nu am putut trimite solicitarea. Verificati datele si incercati din nou.',
    accountEyebrow: 'Cont client',
    accountTitle: 'Contul meu',
    accountCopy: 'Introduceti emailul folosit la comanda pentru a vedea produsele cumparate, statusul platii si istoricul solicitarilor.',
    accountEmailLabel: 'Email cont',
    passwordLabel: 'Parola',
    passwordPlaceholder: 'Minimum 8 caractere',
    login: 'Login',
    register: 'Creeaza cont',
    logout: 'Logout',
    signedInAs: 'Autentificat ca',
    authNote: 'Ai nevoie de cont pentru a vedea istoricul comenzilor si pentru a lega comenzile noi de profilul tau.',
    loadingAccount: 'Se incarca...',
    viewAccount: 'Vezi contul',
    loginSubmit: 'Intra in cont',
    registerSubmit: 'Creeaza cont',
    authError: 'Nu am putut autentifica acest cont.',
    accountError: 'Nu am putut incarca acest cont.',
    orderSingular: 'comanda',
    orderPlural: 'comenzi',
    total: 'Total',
    niceClassesShort: 'clase NISA',
    noPurchases: 'Nu exista comenzi pentru acest email.',
    footerCopy: 'Consultanta pentru inregistrare marca OSIM si UE, verificari preliminare si asistenta pe parcursul procedurii.',
    footerResources: 'Servicii',
    businessHours: 'Luni - Vineri, 09:00 - 19:00',
    odr: 'Solutionarea online a litigiilor',
    sal: 'Solutionarea alternativa a litigiilor',
    privacyPolicy: 'Politica de confidentialitate',
    termsOfUse: 'Termeni si conditii',
    rightsReserved: 'Toate drepturile rezervate.',
    steps: ['Marca', 'Clase NISA', 'Cos'],
    products: {
      'ro-word': {
        title: 'Marca verbala OSIM',
        note: 'doar litere si cifre, fara logo',
        tax: 'include TVA',
        items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.016 Lei', 'o clasa NISA inclusa', 'plata online securizata'],
      },
      'ro-monochrome': {
        title: 'Marca alb-negru',
        note: 'scriere speciala sau logo monocrom',
        tax: 'include TVA',
        items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.168 Lei', 'detaliere produse si servicii', 'o clasa NISA inclusa'],
      },
      'ro-color': {
        title: 'Marca color',
        note: 'logo, design sau scriere color',
        tax: 'include TVA',
        items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.930 Lei', 'upload fisier logo', 'o clasa NISA inclusa'],
      },
      'eu-word': {
        title: 'Marca Uniunea Europeana',
        note: 'protectie in statele membre UE',
        tax: 'include TVA',
        items: ['onorariu inclus: 240 EUR', 'taxe EUIPO incluse: 850 EUR', 'o clasa NISA inclusa', 'depunere asistata online'],
      },
      'eu-logo': {
        title: 'Logo UE',
        note: 'semn figurativ sau mixt',
        tax: 'include TVA',
        items: ['onorariu inclus: 240 EUR', 'taxe oficiale incluse: 380 EUR', 'detaliere clase NISA', 'procesare securizata'],
      },
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
    heroEyebrow: 'Intellectual property',
    heroTitle: 'Trademark registration Romania EU',
    heroLead: 'Assisted filing for OSIM and the European Union, with clear fees, official taxes included, and documentation prepared from the details you submit online.',
    heroPackages: 'View packages',
    heroAccount: 'My account',
    heroForm: 'Complete form',
    secureTitle: 'Secure connection',
    secureCopy: 'Online payment and contact details are handled in separate steps.',
    pricingTitle: 'Choose trademark type',
    emptyProducts: 'No products have been configured yet.',
    currencyLabel: 'Office',
    buy: 'Buy',
    startEyebrow: 'Not sure where to start?',
    startTitle: 'Start with a trademark check',
    startCopy: 'A preliminary analysis helps identify risks before filing. For complex orders, the team can clarify the right goods and services.',
    startCta: 'Request check',
    monitoringEyebrow: 'Trademark monitoring',
    monitoringTitle: 'Quick trademark search',
    monitoringCopy: 'Check similar names across public registers for Romania, the European Union and WIPO.',
    monitoringMarkLabel: 'Trademark name',
    monitoringMarkPlaceholder: 'Example: BRAND NAME',
    monitoringOfficeLabel: 'Offices',
    monitoringClassLabel: 'NICE classes',
    monitoringSubmit: 'Search trademark',
    monitoringLoading: 'Searching...',
    monitoringResults: 'Results',
    monitoringOpen: 'Open',
    monitoringClasses: 'Classes:',
    monitoringUntitled: 'Untitled trademark',
    monitoringUnknownOffice: 'Unknown office',
    monitoringUnknownStatus: 'Unknown status',
    monitoringNoResults: 'No results were found for this search.',
    monitoringError: 'We could not query the public registers. Please try again.',
    summaryTotal: 'Estimated total',
    summaryNote: 'includes VAT, legal fee and official taxes for the current selection',
    stepOneTitle: 'Word trademark registration',
    stepOneCopy: 'Please fill this in carefully. The OSIM documentation is prepared from these details.',
    productLabel: 'Product',
    markLabel: 'Trademark you want to register',
    markPlaceholder: 'Example: BRAND NAME',
    classesLabel: 'How many NICE classes do you want to protect?',
    oneClass: 'One NICE class (included)',
    multipleClasses: count => `${count} NICE classes (+${(count - 1) * 449} Lei)`,
    includedTitle: 'Price includes',
    includedCopy: 'preliminary consultation, NICE class details, filing, updates and the original certificate.',
    stepTwoTitle: 'NICE class selection',
    stepTwoCopy: 'Choose the classes you need. After filing, classes and goods cannot be added retroactively.',
    primaryClassLabel: 'Included NICE class',
    primaryClassPlaceholder: 'Select included NICE class',
    niceSource: 'Source: Nice Classification, 12th edition, 2024 version, OSIM',
    niceGoods: 'Goods',
    niceServices: 'Services',
    niceOfficialTitle: 'Class title from the PDF',
    niceGuidanceTitle: 'Details for the form',
    niceGuidanceCopy: 'Use the description below as guidance, then write the brand’s concrete goods or services in the next field.',
    extraClassesHint: 'You selected more than one class. Add the extra classes and their goods/services in the description.',
    goodsLabel: 'Describe the goods or services',
    goodsPlaceholder: 'Example: online clothing store, software production, marketing services',
    stepThreeTitle: 'Contact and billing details',
    phoneLabel: 'Mobile phone',
    phonePlaceholder: '+40...',
    ownerTypeLabel: 'Register the trademark for',
    company: 'Company',
    person: 'Individual',
    taxIdLabel: 'VAT / tax identifier',
    ownerNameLabel: 'Owner name',
    ownerNamePlaceholder: 'Company LLC',
    addressLabel: 'Billing address',
    addressPlaceholder: 'Street, number, city, county',
    stepFourTitle: 'Review request',
    stepFourCopy: 'Check the trademark details and accept the terms before adding the product to your cart.',
    cardPayment: 'Card payment via Stripe',
    paypalPayment: 'PayPal payment',
    bankPayment: 'Bank transfer',
    cardPaymentDescription: 'Visa / Mastercard / Amex / Google Pay through Stripe Checkout',
    paypalPaymentDescription: 'Secure redirect through PayPal Checkout',
    bankPaymentDescription: 'You will receive bank transfer details after the order is registered',
    paymentNote: 'Secure processing. Card details are not stored locally.',
    addToCartPaymentNote: 'The payment method is selected at checkout, after the product is in the cart.',
    checkoutPaymentLabel: 'Payment method',
    termsLabel: 'I agree to the terms of use and privacy policy.',
    back: 'Back',
    next: 'Next step',
    submitting: 'Submitting...',
    submit: 'Ready to register',
    addToCart: 'Add to cart',
    cartAdded: 'The product was added to your cart.',
    cartEyebrow: 'Cart',
    cartTitle: 'Cart and checkout',
    cartCopy: 'Review configured products, choose the payment method and complete checkout.',
    cartTotal: 'Cart total',
    checkout: 'Checkout',
    emptyCart: 'Your cart is empty. Configure a trademark and add it to the cart.',
    remove: 'Remove',
    checkoutSuccess: 'The order was submitted.',
    checkoutLoginRequired: 'Log in to your account before checkout.',
    checkoutBillingRequired: 'Complete contact and billing details in your account before payment.',
    checkoutReady: 'Your account has the details required for checkout.',
    checkoutNeedsAccount: 'Checkout requires an account and billing details.',
    successFallback: 'The request has been registered.',
    submitError: 'We could not submit the request. Please check the details and try again.',
    accountEyebrow: 'Client account',
    accountTitle: 'My account',
    accountCopy: 'Enter the email used for the order to see purchased products, payment status and request history.',
    accountEmailLabel: 'Account email',
    passwordLabel: 'Password',
    passwordPlaceholder: 'Minimum 8 characters',
    login: 'Login',
    register: 'Create account',
    logout: 'Logout',
    signedInAs: 'Signed in as',
    authNote: 'You need an account to view order history and attach new purchases to your profile.',
    loadingAccount: 'Loading...',
    viewAccount: 'View account',
    loginSubmit: 'Log in',
    registerSubmit: 'Create account',
    authError: 'We could not authenticate this account.',
    accountError: 'We could not load this account.',
    orderSingular: 'order',
    orderPlural: 'orders',
    total: 'Total',
    niceClassesShort: 'NICE classes',
    noPurchases: 'There are no orders for this email.',
    footerCopy: 'Consulting for OSIM and EU trademark registration, preliminary checks and support throughout the procedure.',
    footerResources: 'Services',
    businessHours: 'Monday - Friday, 09:00 - 19:00',
    odr: 'Online dispute resolution',
    sal: 'Alternative dispute resolution',
    privacyPolicy: 'Privacy policy',
    termsOfUse: 'Terms and conditions',
    rightsReserved: 'All rights reserved.',
    steps: ['Trademark', 'NICE classes', 'Cart'],
    products: {
      'ro-word': {
        title: 'Word trademark',
        note: 'letters and numbers only, without logo',
        tax: 'includes VAT',
        items: ['legal fee included: 1,210 Lei', 'OSIM taxes included: 1,016 Lei', 'one NICE class included', 'secure online payment'],
      },
      'ro-monochrome': {
        title: 'Black-and-white trademark',
        note: 'special lettering or monochrome logo',
        tax: 'includes VAT',
        items: ['legal fee included: 1,210 Lei', 'OSIM taxes included: 1,168 Lei', 'goods and services details', 'one NICE class included'],
      },
      'ro-color': {
        title: 'Color trademark',
        note: 'logo, design or colored lettering',
        tax: 'includes VAT',
        items: ['legal fee included: 1,210 Lei', 'OSIM taxes included: 1,930 Lei', 'logo file upload', 'one NICE class included'],
      },
      'eu-word': {
        title: 'European Union trademark',
        note: 'protection in EU member states',
        tax: 'includes VAT',
        items: ['legal fee included: 240 EUR', 'EUIPO taxes included: 850 EUR', 'one NICE class included', 'assisted online filing'],
      },
      'eu-logo': {
        title: 'EU logo',
        note: 'figurative or mixed sign',
        tax: 'includes VAT',
        items: ['legal fee included: 240 EUR', 'official taxes included: 380 EUR', 'NICE class details', 'secure processing'],
      },
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
const brandName = computed(() => siteTheme.value.brand_name || 'SANDU și Asociații IP Attorney')
const footerCopy = computed(() => siteTheme.value.footer_text || t.value.footerCopy)
const copyrightText = computed(() => `© 2026 ${brandName.value}. ${t.value.rightsReserved}`)
const locale = computed(() => selectedLanguage.value === 'ro' ? 'ro-RO' : 'en-US')
const steps = computed(() => t.value.steps)

const form = reactive({
  mark: '',
  classes: 1,
  primaryClass: '',
  goods: '',
  terms: false,
})
const monitoringForm = reactive({
  mark: '',
  offices: ['RO', 'EM'],
  classes: [],
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
const niceClasses = computed(() => niceClasses2024.map(niceClass => ({
  ...niceClass,
  label: selectedLanguage.value === 'ro'
    ? `Clasa ${niceClass.number}: ${niceClass.officialRo}`
    : `Class ${niceClass.number}: ${niceClass.summaryEn}`,
  value: `Clasa ${niceClass.number}: ${niceClass.officialRo}`,
  typeLabel: niceClass.type === 'goods' ? t.value.niceGoods : t.value.niceServices,
  detail: selectedLanguage.value === 'ro' ? niceClass.officialRo : niceClass.summaryEn,
})))
const selectedNiceClass = computed(() => niceClasses.value.find(niceClass => niceClass.value === form.primaryClass))
const visiblePlans = computed(() => plans.value.filter(plan => plan.currency === selectedCurrency.value))
const selectedProduct = computed(() => plans.value.find(plan => plan.code === selectedProductCode.value) || plans.value[0] || null)
const total = computed(() => selectedProduct.value ? selectedProduct.value.baseLei + (form.classes - 1) * 449 : 0)
const formattedTotal = computed(() => `${total.value.toLocaleString(locale.value)} Lei`)
const cartTotal = computed(() => cartItems.value.reduce((sum, item) => sum + item.total, 0))
const formattedCartTotal = computed(() => `${cartTotal.value.toLocaleString(locale.value)} Lei`)
const canAddToCart = computed(() => selectedProduct.value && form.mark && form.primaryClass && form.terms)
const accountCheckoutStatus = computed(() => {
  if (!authToken.value) return t.value.checkoutNeedsAccount
  return currentUser.value?.billing_complete ? t.value.checkoutReady : t.value.checkoutBillingRequired
})
const selectedPaymentDescription = computed(() => ({
  card: t.value.cardPaymentDescription,
  paypal: t.value.paypalPaymentDescription,
  transfer: t.value.bankPaymentDescription,
})[checkoutPayment.value])
const monitoringTotalLabel = computed(() => monitoringTotal.value.toLocaleString(locale.value))

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

function classLabel(count) {
  if (count === 1) return t.value.oneClass
  return t.value.multipleClasses(count)
}

function selectProduct(code) {
  selectedProductCode.value = code
}

function setLanguage(code) {
  selectedLanguage.value = code
}

function authHeaders() {
  return authToken.value ? { Authorization: `Bearer ${authToken.value}` } : {}
}

function clearSession() {
  authToken.value = ''
  currentUser.value = null
  window.localStorage.removeItem('account-token')
  window.localStorage.removeItem('account-user')
}

function persistCart() {
  window.localStorage.setItem('cart-items', JSON.stringify(cartItems.value))
}

function loadCart() {
  const storedCart = window.localStorage.getItem('cart-items')
  cartItems.value = storedCart ? JSON.parse(storedCart) : []
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
    terms: form.terms,
    total: total.value,
    formattedTotal: formattedTotal.value,
  }
}

function addToCart() {
  submitError.value = ''
  cartMessage.value = ''

  if (!canAddToCart.value) {
    submitError.value = t.value.submitError
    return
  }

  const cartItem = buildCartItem()
  if (!cartItem) return

  cartItems.value = [...cartItems.value, cartItem]
  persistCart()
  cartMessage.value = t.value.cartAdded
}

function removeFromCart(id) {
  cartItems.value = cartItems.value.filter(item => item.id !== id)
  persistCart()
}

async function hydrateSession() {
  const storedToken = window.localStorage.getItem('account-token')

  if (!storedToken) return

  authToken.value = storedToken

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
      headers: authHeaders(),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) throw new Error()

    window.localStorage.setItem('account-user', JSON.stringify(payload.user))
    currentUser.value = payload.user
  }
  catch {
    clearSession()
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
        payment: checkoutPayment.value,
        terms: item.terms,
      },
    }),
  })
  const payload = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(payload.message || t.value.submitError)
  }

  return payload
}

async function checkoutCart() {
  submitError.value = ''
  cartMessage.value = ''

  if (!authToken.value) {
    submitError.value = t.value.checkoutLoginRequired
    return
  }

  if (!currentUser.value?.billing_complete) {
    submitError.value = t.value.checkoutBillingRequired
    return
  }

  submitting.value = true

  try {
    const payloads = []

    for (const item of cartItems.value) {
      payloads.push(await submitCartItem(item))
    }

    cartItems.value = []
    persistCart()
    cartMessage.value = t.value.checkoutSuccess
    const payload = payloads.find(result => result.payment?.checkout_url)
    if (payload.payment?.checkout_url) {
      window.location.href = payload.payment.checkout_url
    }
  }
  catch (error) {
    submitError.value = error instanceof Error ? error.message : t.value.submitError
  }
  finally {
    submitting.value = false
  }
}

async function searchMonitoring() {
  monitoringError.value = ''
  monitoringSearched.value = false
  monitoringLoading.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/trademark_monitoring/search`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        monitoring: {
          mark: monitoringForm.mark,
          offices: monitoringForm.offices,
          classes: monitoringForm.classes,
          page_size: 8,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || t.value.monitoringError)
    }

    monitoringResults.value = payload.results || []
    monitoringTotal.value = payload.total || monitoringResults.value.length
    monitoringSearched.value = true
  }
  catch (error) {
    monitoringError.value = error instanceof Error ? error.message : t.value.monitoringError
  }
  finally {
    monitoringLoading.value = false
  }
}

onMounted(() => {
  const storedLanguage = window.localStorage.getItem('preferred-language')

  if (storedLanguage && translations[storedLanguage]) {
    selectedLanguage.value = storedLanguage
  }

  hydrateSession()
  loadCart()
  loadProducts()
  loadSiteTheme()
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

.monitoring-layout {
  display: grid;
  grid-template-columns: 330px minmax(0, 1fr);
  gap: 28px;
  align-items: start;
}

.monitoring-copy h2 {
  margin: 0;
  font-size: 42px;
  font-weight: 400;
}

.monitoring-panel {
  display: grid;
  gap: 18px;
  border: 1px solid var(--line);
  background: var(--paper);
  padding: 24px;
}

.monitoring-form {
  display: grid;
  gap: 16px;
}

.monitoring-form label {
  display: grid;
  gap: 8px;
  color: #2d2924;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.monitoring-form input,
.monitoring-form select {
  width: 100%;
  border: 1px solid #cfc7bc;
  background: #fff;
  color: var(--ink);
  padding: 13px 14px;
  font-weight: 400;
}

.monitoring-form select[multiple] {
  min-height: 124px;
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
  align-items: center;
  gap: 10px;
}

.payment-options input,
.checkbox input {
  width: auto;
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

.site-footer {
  background: var(--brand);
  color: #f8f3ea;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  padding: 42px 0 22px;
}

.footer-grid {
  display: grid;
  grid-template-columns: minmax(560px, 1.9fr) repeat(3, minmax(110px, 0.7fr));
  gap: clamp(24px, 3vw, 48px);
  align-items: start;
}

.footer-brand {
  display: grid;
  grid-template-columns: minmax(220px, 320px) minmax(0, 1fr);
  gap: clamp(18px, 2.4vw, 32px);
  align-items: start;
  min-width: 0;
}

.footer-brand__logo {
  display: block;
  width: clamp(220px, 24vw, 320px);
  aspect-ratio: 7 / 5;
  background: var(--footer-fallback-logo-image) center / contain no-repeat;
}

.footer-brand p {
  max-width: 360px;
  min-width: 0;
  margin: 0;
  color: #f8f3ea;
  font-size: 14px;
  line-height: 1.3;
}

.footer-column {
  display: grid;
  align-content: start;
  gap: 10px;
}

.footer-column h2 {
  margin: 0 0 8px;
  color: #f6dfad;
  font-size: 13px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.footer-column a,
.footer-column span {
  color: #f8f3ea;
  font-size: 16px;
  line-height: 1.35;
  text-decoration: none;
}

.footer-column a:hover {
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 4px;
}

.anpc-links a {
  color: #f6dfad;
}

.footer-bottom {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  margin-top: 34px;
  border-top: 1px solid rgba(248, 243, 234, 0.16);
  padding-top: 18px;
  color: #b8afa2;
  font-size: 13px;
}

.legal-links {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
}

.legal-links a {
  color: inherit;
  text-decoration: none;
}

.legal-links a:hover {
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 4px;
}

@media (max-width: 980px) {
  .main-header__inner,
  .top-strip__inner,
  .start-band__inner,
  .form-layout,
  .cart-layout,
  .account-layout,
  .monitoring-layout,
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

  .form-summary {
    position: static;
  }

  .footer-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .footer-brand {
    grid-column: 1 / -1;
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
  .form-section,
  .cart-section,
  .account-section,
  .monitoring-section {
    padding: 42px 0;
  }

  .form-summary,
  .registration-form,
  .cart-panel,
  .account-panel,
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

  .footer-grid,
  .footer-bottom {
    grid-template-columns: 1fr;
    flex-direction: column;
  }

  .footer-brand {
    grid-template-columns: 1fr;
  }

  .footer-brand__logo {
    width: clamp(220px, 76vw, 320px);
  }
}
</style>
