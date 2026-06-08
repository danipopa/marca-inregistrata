<template>
  <div class="page-shell">
    <div class="top-strip">
      <div class="wrap top-strip__inner">
        <div class="contact-line">
          <a href="tel:0770898767">0770 898 767</a>
          <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
          <a href="mailto:office@sandusiasociatii.ro">office@sandusiasociatii.ro</a>
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
          <a href="#preturi">{{ t.quickRegistration }}</a>
          <a href="#reinnoire">{{ t.quickRenewal }}</a>
          <a href="#monitorizare">{{ t.quickMonitoring }}</a>
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
          <a
            v-if="cartItems.length"
            class="cart-nav-link"
            href="/checkout"
            :aria-label="`${t.cartNavLabel}: ${cartItems.length}`"
          >
            <span
              class="cart-nav-icon"
              aria-hidden="true"
            />
            <span class="cart-nav-count">{{ cartItems.length }}</span>
          </a>
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
                @click.prevent="openOrderForm()"
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
                @click.prevent="openOrderForm(plan.code)"
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
        id="reinnoire"
        class="renewal-section"
      >
        <div class="wrap renewal-layout">
          <div class="renewal-copy">
            <p class="eyebrow">
              {{ t.renewalEyebrow }}
            </p>
            <h2>{{ t.renewalTitle }}</h2>
            <p class="muted">
              {{ t.renewalCopy }}
            </p>
            <div class="renewal-benefits">
              <strong>{{ t.renewalAdvantagesTitle }}</strong>
              <ul>
                <li
                  v-for="benefit in t.renewalBenefits"
                  :key="benefit"
                >
                  {{ benefit }}
                </li>
              </ul>
            </div>
          </div>

          <div class="renewal-plans">
            <article
              v-for="plan in renewalPlans"
              :key="plan.code"
              class="price-card renewal-card"
              :class="{ selected: selectedProductCode === plan.code }"
            >
              <div class="price-card__top">
                <span class="country-pill">{{ plan.region }}</span>
                <h3>{{ plan.title }}</h3>
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
                @click.prevent="openOrderForm(plan.code)"
              >{{ t.buy }}</a>
            </article>
          </div>
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
            @click.prevent="openVerificationForm"
          >{{ t.startCta }}</a>
        </div>
      </section>

      <section
        id="monitorizare"
        class="monitoring-section"
      >
        <div class="wrap monitoring-shell">
          <div class="monitoring-header">
            <p class="eyebrow">
              {{ t.monitoringEyebrow }}
            </p>
            <h2>{{ t.monitoringTitle }}</h2>
          </div>

          <div class="monitoring-layout">
            <div class="monitoring-copy">
              <p class="muted">
                {{ t.monitoringCopy }}
              </p>
              <p>
                {{ t.monitoringLead }}
              </p>
              <div class="monitoring-benefits">
                <strong>{{ t.monitoringCoverageTitle }}</strong>
                <ul>
                  <li
                    v-for="item in t.monitoringCoverage"
                    :key="item"
                  >
                    {{ item }}
                  </li>
                </ul>
              </div>
              <p class="monitoring-benefit">
                {{ t.monitoringBenefit }}
              </p>
            </div>

            <div class="monitoring-panel">
              <form
                class="monitoring-form"
                @submit.prevent="addMonitoringToCart"
              >
                <div class="monitoring-price">
                  <span>{{ t.monitoringPriceLabel }}</span>
                  <strong>{{ monitoringPriceLabel }}</strong>
                  <small>{{ t.monitoringPriceNote }}</small>
                </div>
                <label>
                  {{ t.monitoringMarkLabel }}
                  <input
                    v-model="monitoringForm.mark"
                    type="text"
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

                <label>
                  {{ t.monitoringNotesLabel }}
                  <textarea
                    v-model="monitoringForm.notes"
                    rows="6"
                    :placeholder="t.monitoringNotesPlaceholder"
                  />
                </label>

                <label class="checkbox">
                  <input
                    v-model="monitoringForm.terms"
                    type="checkbox"
                    required
                  >
                  <span>{{ t.termsLabel }}</span>
                </label>

                <button
                  class="primary-btn"
                  type="submit"
                  :disabled="!canAddMonitoringToCart"
                >
                  {{ t.monitoringSubmit }}
                </button>
              </form>

              <p
                v-if="monitoringError"
                class="error-message"
              >
                {{ monitoringError }}
              </p>

              <p
                v-if="cartMessage"
                class="success-message"
              >
                {{ cartMessage }}
              </p>
            </div>
          </div>
        </div>
      </section>

      <section
        v-if="orderFormVisible"
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
                    v-for="plan in orderFormPlans"
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
              <label
                v-if="isOsimRenewalProduct"
                class="checkbox"
              >
                <input
                  v-model="form.ownerChangeRequested"
                  type="checkbox"
                >
                <span>{{ t.ownerChangeOption }}</span>
              </label>
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
                <div class="nisa-picker">
                  <button
                    type="button"
                    class="nisa-picker__trigger"
                    :class="{ empty: !selectedNiceClass }"
                    :aria-expanded="nisaPickerOpen"
                    @click="nisaPickerOpen = !nisaPickerOpen"
                  >
                    {{ selectedNiceClass?.label || t.primaryClassPlaceholder }}
                  </button>
                  <div
                    v-if="nisaPickerOpen"
                    class="nisa-picker__menu"
                    role="listbox"
                    :aria-label="t.primaryClassLabel"
                  >
                    <button
                      v-for="niceClass in niceClasses"
                      :key="niceClass.number"
                      type="button"
                      class="nisa-picker__option"
                      :class="{ selected: form.primaryClass === niceClass.value }"
                      :title="niceClass.detail"
                      role="option"
                      :aria-selected="form.primaryClass === niceClass.value"
                      @click="selectNiceClass(niceClass)"
                    >
                      <span>{{ niceClass.label }}</span>
                      <small>{{ niceClass.typeLabel }}</small>
                      <span class="nisa-picker__tooltip">{{ niceClass.detail }}</span>
                    </button>
                  </div>
                </div>
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
                <span>{{ t.termsLabel }}</span>
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
        id="contact"
        class="contact-section"
      >
        <div class="wrap contact-layout">
          <div class="contact-copy">
            <p class="eyebrow">
              {{ t.contactEyebrow }}
            </p>
            <h2>{{ t.contactTitle }}</h2>
            <p class="muted">
              {{ t.contactCopy }}
            </p>

            <div class="contact-details">
              <div>
                <span>{{ t.contactAddressLabel }}</span>
                <strong>Str. C. Libertății, Nr. 42, Sector 3, București</strong>
              </div>
              <div>
                <span>Email</span>
                <a href="mailto:office@sandusiasociatii.ro">office@sandusiasociatii.ro</a>
                <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
              </div>
              <div>
                <span>{{ t.contactPhoneLabel }}</span>
                <a href="tel:0770898767">0770 898 767</a>
              </div>
            </div>
          </div>

          <form
            class="contact-form"
            @submit.prevent="submitContactMessage"
          >
            <div class="field-grid">
              <label>
                {{ t.contactNameLabel }} *
                <input
                  v-model="contactForm.name"
                  type="text"
                  autocomplete="name"
                  required
                >
              </label>
              <label>
                Email *
                <input
                  v-model="contactForm.email"
                  type="email"
                  autocomplete="email"
                  required
                >
              </label>
            </div>

            <label>
              {{ t.contactPhoneLabel }}
              <input
                v-model="contactForm.phone"
                type="tel"
                autocomplete="tel"
                placeholder="0770 898 767"
              >
            </label>

            <label>
              {{ t.contactMessageLabel }} *
              <textarea
                v-model="contactForm.message"
                rows="6"
                :placeholder="t.contactMessagePlaceholder"
                required
              />
            </label>

            <button
              type="submit"
              class="primary-btn"
              :disabled="contactSubmitting"
            >
              {{ contactSubmitting ? t.submitting : t.contactSubmit }}
            </button>

            <p
              v-if="contactSuccess"
              class="success-message"
            >
              {{ contactSuccess }}
            </p>

            <p
              v-if="contactError"
              class="error-message"
            >
              {{ contactError }}
            </p>
          </form>
        </div>
      </section>
    </main>

    <footer class="site-footer">
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
          <a
            href="#formular"
            @click.prevent="openOrderForm()"
          >{{ t.quickRegistration }}</a>
          <a href="#reinnoire">{{ t.quickRenewal }}</a>
          <a href="#monitorizare">{{ t.quickMonitoring }}</a>
          <a href="#verificare">{{ t.quickCheck }}</a>
        </nav>

        <div class="footer-column">
          <h2>Contact</h2>
          <a href="tel:0770898767">0770 898 767</a>
          <a href="mailto:office@sandusiasociatii.ro">office@sandusiasociatii.ro</a>
          <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
          <span>Str. C. Libertății, Nr. 42, Sector 3, București</span>
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
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import { niceClasses2024 } from '~/data/niceClasses2024'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'
import footerLogoUrl from '../assets/images/logo_footbar-removebg-preview.png'
import blackWhiteTrademarkUrl from '../assets/images/MARCA_TA_ALB_NEGRU-removebg-preview.png'
import colorTrademarkUrl from '../assets/images/MARCA_TA_COLOR-removebg-preview.png'
import heroHomeUrl from '../assets/images/home_img.png'
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
const orderFormVisible = ref(false)
const submitError = ref('')
const cartMessage = ref('')
const cartItems = ref([])
const monitoringError = ref('')
const nisaPickerOpen = ref(false)
const contactSubmitting = ref(false)
const contactError = ref('')
const contactSuccess = ref('')
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
    renewalEyebrow: 'Reinnoire marca',
    renewalTitle: 'Prelungire protectie OSIM sau EUIPO',
    renewalCopy: 'Serviciul de reinnoire a unei marci reprezinta procedura legala prin care valabilitatea drepturilor de proprietate industriala asupra unui brand este prelungita cu o noua perioada de 10 ani la OSIM (nivel national) sau EUIPO (nivel european).',
    renewalAdvantagesTitle: 'Avantajele reinnoirii marcii',
    renewalBenefits: [
      'Pastrarea monopolului comercial si prevenirea copierii numelui sau a logo-ului.',
      'Protectia investitiilor de brand facute in marketing, publicitate si reputatie.',
      'Dreptul de a bloca legal denumiri similare sau identice in acelasi domeniu.',
      'Mentinerea valorii financiare a marcii ca activ care poate fi cesionat sau licentiat.',
      'Evitarea costurilor de rebranduire si a riscului unei inregistrari noi de la zero.',
    ],
    emptyProducts: 'Nu exista produse configurate inca.',
    currencyLabel: 'Oficiu',
    buy: 'Adauga in cos',
    startEyebrow: 'Nu stiti de unde sa incepeti?',
    startTitle: 'Incepeti cu o verificare de marca',
    startCopy: 'O analiza prealabila ajuta la identificarea riscurilor inainte de depunere. Pentru comenzi complexe, echipa poate clarifica produsele si serviciile potrivite.',
    startCta: 'Solicita verificare',
    monitoringEyebrow: 'Monitorizare marca',
    monitoringTitle: 'Monitorizare activa pentru marca dumneavoastra',
    monitoringCopy: 'Aceste servicii presupun identificarea marcilor admise la inregistrare la OSIM, EUIPO si WIPO si care sunt identice sau similare cu marca dvs. monitorizata, precum si propunerile privind solutiile de urmat in cazul in care va sunt incalcate drepturile de marca.',
    monitoringLead: 'Asigurati-va ca reputatia si identitatea afacerii dumneavoastra raman protejate. Prin serviciul nostru de monitorizare activa, supraveghem continuu noile cereri de inregistrare depuse la nivel national, european si international.',
    monitoringCoverageTitle: 'Ce acopera acest serviciu?',
    monitoringCoverage: [
      'Identificare timpurie: depistam rapid orice marca noua, identica sau similara, care ar putea crea confuzie in piata.',
      'Solutii strategice: venim cu propuneri clare si solutii juridice pentru apararea brandului.',
      'Raportare lunara: primiti in fiecare luna un raport detaliat pe email, cu statusul verificarilor si concluziile specialistilor.',
    ],
    monitoringBenefit: 'Beneficiul dumneavoastra: liniste deplina si control total asupra exclusivitatii brandului dumneavoastra, fara efort.',
    monitoringPriceLabel: 'Pret serviciu',
    monitoringPriceNote: 'TVA inclus / an / marca monitorizata',
    monitoringMarkLabel: 'Marca pe care doriti sa o monitorizam',
    monitoringMarkPlaceholder: 'Ex: NUMELE BRANDULUI',
    monitoringOfficeLabel: 'Oficii',
    monitoringClassLabel: 'Clase NISA',
    monitoringNotesLabel: 'Observatii pentru monitorizare',
    monitoringNotesPlaceholder: 'Ex: titular actual, clase importante, competitori urmariti',
    monitoringPrimaryClass: 'Monitorizare OSIM, EUIPO si WIPO',
    monitoringSubmit: 'Adauga monitorizarea in cos',
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
    renewalMultipleClasses: (count, amount, currency) => `${count} clase NISA (+${amount.toLocaleString('ro-RO')} ${currency})`,
    includedTitle: 'Pretul include',
    includedCopy: 'consultanta prealabila, detaliere clase NISA, depunere, raportari si certificatul original.',
    ownerChangeOption: 'modificare adresa/nume titular - cost suplimentar 477 Lei',
    ownerChangeCartLabel: 'Include modificare adresa/nume titular',
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
    missingMark: 'Completeaza denumirea marcii inainte de adaugarea in cos.',
    missingNiceClass: 'Selecteaza clasa NISA inclusa inainte de adaugarea in cos.',
    missingTerms: 'Accepta termenii pentru a adauga produsul in cos.',
    cartEyebrow: 'Cos',
    cartTitle: 'Cos si checkout',
    cartCopy: 'Revizuiti produsele configurate, alegeti metoda de plata si finalizati checkout-ul.',
    cartTotal: 'Total cos',
    mixedCurrencyCartTotal: 'Totaluri separate',
    cartNavLabel: 'Cos',
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
    contactEyebrow: 'Contact',
    contactTitle: 'Scrieti-ne pentru detalii',
    contactCopy: 'Pentru intrebari despre verificari, inregistrari OSIM/EUIPO sau comenzi existente, trimiteti un mesaj si revenim cu un raspuns.',
    contactAddressLabel: 'Adresa',
    contactPhoneLabel: 'Telefon / WhatsApp',
    contactNameLabel: 'Nume',
    contactMessageLabel: 'Mesaj',
    contactMessagePlaceholder: 'Spuneti-ne pe scurt ce marca doriti sa verificati sau sa inregistrati.',
    contactSubmit: 'Trimite mesajul',
    contactSuccess: 'Mesajul a fost trimis. Va multumim.',
    contactError: 'Nu am putut trimite mesajul. Verificati datele si incercati din nou.',
    footerCopy: 'Consultanta pentru inregistrare marca OSIM si UE, verificari preliminare si asistenta pe parcursul procedurii.',
    footerResources: 'Servicii',
    businessHours: 'Luni - Vineri, 09:00 - 18:00',
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
      'renew-ro-word': {
        title: 'Reinnoire marca verbala OSIM',
        note: 'prelungire protectie pentru 10 ani',
        tax: '991 Lei taxe + 700 Lei onorariu',
        items: ['include taxa introducere mandatar', 'include taxa eliberare certificat reinnoire', 'o clasa NISA inclusa'],
      },
      'renew-ro-monochrome': {
        title: 'Reinnoire marca alb-negru OSIM',
        note: 'prelungire protectie pentru 10 ani',
        tax: '1.143 Lei taxe + 700 Lei onorariu',
        items: ['include taxa introducere mandatar', 'include taxa eliberare certificat reinnoire', 'o clasa NISA inclusa'],
      },
      'renew-ro-color': {
        title: 'Reinnoire marca color OSIM',
        note: 'prelungire protectie pentru 10 ani',
        tax: '1.549 Lei taxe + 700 Lei onorariu',
        items: ['include taxa introducere mandatar', 'include taxa eliberare certificat reinnoire', 'o clasa NISA inclusa'],
      },
      'renew-eu-word': {
        title: 'Reinnoire marca verbala EUIPO',
        note: 'prelungire protectie la nivel european',
        tax: '850 EUR taxe + 150 EUR onorariu',
        items: ['o clasa NISA inclusa', 'valabilitate reinnoita pentru 10 ani'],
      },
      'renew-eu-monochrome': {
        title: 'Reinnoire marca alb-negru EUIPO',
        note: 'prelungire protectie la nivel european',
        tax: '850 EUR taxe + 150 EUR onorariu',
        items: ['o clasa NISA inclusa', 'valabilitate reinnoita pentru 10 ani'],
      },
      'renew-eu-color': {
        title: 'Reinnoire marca color EUIPO',
        note: 'prelungire protectie la nivel european',
        tax: '850 EUR taxe + 150 EUR onorariu',
        items: ['o clasa NISA inclusa', 'valabilitate reinnoita pentru 10 ani'],
      },
      'monitoring-brand': {
        title: 'Monitorizare marca',
        note: 'serviciu anual pentru o marca monitorizata',
        tax: 'TVA inclus',
        items: ['identificare marci identice sau similare', 'monitorizare OSIM, EUIPO si WIPO', 'raportare lunara pe email', 'propuneri de solutii juridice'],
      },
      'verification-brand': {
        title: 'Verificare marca',
        note: 'analiza preliminara disponibilitate marca',
        tax: 'pret editabil din admin',
        items: ['verificare denumire propusa', 'analiza clase NISA indicate', 'recomandare inainte de depunere'],
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
    renewalEyebrow: 'Trademark renewal',
    renewalTitle: 'Renew protection with OSIM or EUIPO',
    renewalCopy: 'Trademark renewal extends industrial property rights over a brand for a new 10-year period with OSIM nationally or EUIPO at European Union level.',
    renewalAdvantagesTitle: 'Renewal advantages',
    renewalBenefits: [
      'Keeps commercial exclusivity and reduces copycat risk.',
      'Protects brand investments made in marketing, advertising and reputation.',
      'Keeps the right to block similar or identical names in the same field.',
      'Maintains the financial value of the trademark as an asset.',
      'Avoids rebranding costs and the risk of filing a new brand from scratch.',
    ],
    emptyProducts: 'No products have been configured yet.',
    currencyLabel: 'Office',
    buy: 'Buy',
    startEyebrow: 'Not sure where to start?',
    startTitle: 'Start with a trademark check',
    startCopy: 'A preliminary analysis helps identify risks before filing. For complex orders, the team can clarify the right goods and services.',
    startCta: 'Request check',
    monitoringEyebrow: 'Trademark monitoring',
    monitoringTitle: 'Active monitoring for your trademark',
    monitoringCopy: 'This service identifies accepted OSIM, EUIPO and WIPO trademarks that are identical or similar to your monitored trademark and includes proposed next steps if your trademark rights are infringed.',
    monitoringLead: 'Make sure your business reputation and identity stay protected. Through active monitoring, we continuously watch new national, European and international trademark applications.',
    monitoringCoverageTitle: 'What this service covers',
    monitoringCoverage: [
      'Early identification: we quickly detect new identical or similar trademarks that could create market confusion.',
      'Strategic solutions: we provide clear legal proposals to defend your brand.',
      'Monthly reporting: you receive a detailed email report every month with verification status and specialist conclusions.',
    ],
    monitoringBenefit: 'Your benefit: peace of mind and full control over brand exclusivity, without extra effort.',
    monitoringPriceLabel: 'Service price',
    monitoringPriceNote: 'VAT included / year / monitored trademark',
    monitoringMarkLabel: 'Trademark you want monitored',
    monitoringMarkPlaceholder: 'Example: BRAND NAME',
    monitoringOfficeLabel: 'Offices',
    monitoringClassLabel: 'NICE classes',
    monitoringNotesLabel: 'Monitoring notes',
    monitoringNotesPlaceholder: 'Example: current owner, important classes, competitors to watch',
    monitoringPrimaryClass: 'OSIM, EUIPO and WIPO monitoring',
    monitoringSubmit: 'Add monitoring to cart',
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
    renewalMultipleClasses: (count, amount, currency) => `${count} NICE classes (+${amount.toLocaleString('en-US')} ${currency})`,
    includedTitle: 'Price includes',
    includedCopy: 'preliminary consultation, NICE class details, filing, updates and the original certificate.',
    ownerChangeOption: 'owner address/name change - additional cost 477 Lei',
    ownerChangeCartLabel: 'Includes owner address/name change',
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
    missingMark: 'Complete the trademark name before adding it to the cart.',
    missingNiceClass: 'Select the included NICE class before adding it to the cart.',
    missingTerms: 'Accept the terms before adding the product to the cart.',
    cartEyebrow: 'Cart',
    cartTitle: 'Cart and checkout',
    cartCopy: 'Review configured products, choose the payment method and complete checkout.',
    cartTotal: 'Cart total',
    mixedCurrencyCartTotal: 'Separate totals',
    cartNavLabel: 'Cart',
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
    contactEyebrow: 'Contact',
    contactTitle: 'Write to us for details',
    contactCopy: 'For questions about checks, OSIM/EUIPO filings or existing orders, send a message and we will get back to you.',
    contactAddressLabel: 'Address',
    contactPhoneLabel: 'Phone / WhatsApp',
    contactNameLabel: 'Name',
    contactMessageLabel: 'Message',
    contactMessagePlaceholder: 'Tell us briefly which trademark you want to check or register.',
    contactSubmit: 'Send message',
    contactSuccess: 'Your message was sent. Thank you.',
    contactError: 'We could not send the message. Please check the details and try again.',
    footerCopy: 'Consulting for OSIM and EU trademark registration, preliminary checks and support throughout the procedure.',
    footerResources: 'Services',
    businessHours: 'Monday - Friday, 09:00 - 18:00',
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
      'monitoring-brand': {
        title: 'Trademark monitoring',
        note: 'annual service for one monitored trademark',
        tax: 'VAT included',
        items: ['identical or similar trademark identification', 'OSIM, EUIPO and WIPO monitoring', 'monthly email reporting', 'legal solution proposals'],
      },
      'verification-brand': {
        title: 'Trademark check',
        note: 'preliminary trademark availability check',
        tax: 'price editable from admin',
        items: ['proposed name check', 'review of selected NICE classes', 'recommendation before filing'],
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
  ownerChangeRequested: false,
  terms: false,
})
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
const selectedNiceClass = computed(() => niceClasses.value.find(niceClass => niceClass.value === form.primaryClass))
const orderFormPlans = computed(() => plans.value.filter(plan => !isMonitoringCode(plan.code)))
const registrationPlans = computed(() => plans.value.filter(plan => !isRenewalCode(plan.code) && !isMonitoringCode(plan.code) && !isVerificationCode(plan.code)))
const renewalPlans = computed(() => plans.value.filter(plan => isRenewalCode(plan.code)))
const visiblePlans = computed(() => registrationPlans.value.filter(plan => plan.currency === selectedCurrency.value))
const selectedProduct = computed(() => plans.value.find(plan => plan.code === selectedProductCode.value) || plans.value[0] || null)
const monitoringProduct = computed(() => plans.value.find(plan => plan.code === 'monitoring-brand') || t.value.products['monitoring-brand'])
const selectedProductCurrency = computed(() => selectedProduct.value?.currency || 'RON')
const isOsimRenewalProduct = computed(() => selectedProduct.value && isOsimRenewalCode(selectedProduct.value.code))
const total = computed(() => selectedProduct.value ? selectedProduct.value.baseLei + extraClassTotal(form.classes, selectedProduct.value.code) + ownerChangeTotal.value : 0)
const ownerChangeTotal = computed(() => isOsimRenewalProduct.value && form.ownerChangeRequested ? 477 : 0)
const formattedTotal = computed(() => formatMoney(total.value, selectedProductCurrency.value))
const monitoringTotal = computed(() => Number(monitoringProduct.value?.baseLei || monitoringProduct.value?.base_lei || 726))
const monitoringPriceLabel = computed(() => formatMoney(monitoringTotal.value, 'RON'))
const canAddToCart = computed(() => selectedProduct.value && form.mark && form.primaryClass && form.terms)
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

function isOsimRenewalCode(code) {
  return code?.startsWith('renew-ro-')
}

function isOsimCode(code) {
  return code?.startsWith('ro-') || code?.startsWith('renew-ro-')
}

function isEuipoCode(code) {
  return code?.startsWith('eu-') || code?.startsWith('renew-eu-')
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
  if (isVerificationCode(productCode)) return 0
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
  selectProduct(code)
  orderFormVisible.value = true
  currentStep.value = 0
  nextTick(() => {
    document.getElementById('formular')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  })
}

function openVerificationForm() {
  const verificationCode = plans.value.find(plan => isVerificationCode(plan.code))?.code || 'verification-brand'
  openOrderForm(verificationCode)
}

function setLanguage(code) {
  selectedLanguage.value = code
  form.primaryClass = ''
  nisaPickerOpen.value = false
}

function selectNiceClass(niceClass) {
  form.primaryClass = niceClass.value
  nisaPickerOpen.value = false
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
    ownerChangeRequested: isOsimRenewalProduct.value && form.ownerChangeRequested,
    terms: form.terms,
    total: total.value,
    currency: selectedProductCurrency.value,
    formattedTotal: formattedTotal.value,
  }
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

  cartItems.value = [...cartItems.value, {
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
  }]
  persistCart()
  cartMessage.value = t.value.cartAdded
}

function addToCart() {
  submitError.value = ''
  cartMessage.value = ''

  if (!canAddToCart.value) {
    if (!form.mark) submitError.value = t.value.missingMark
    else if (!form.primaryClass) submitError.value = t.value.missingNiceClass
    else if (!form.terms) submitError.value = t.value.missingTerms
    else submitError.value = t.value.submitError
    return
  }

  const cartItem = buildCartItem()
  if (!cartItem) return

  cartItems.value = [...cartItems.value, cartItem]
  persistCart()
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
  const storedLanguage = window.localStorage.getItem('preferred-language')

  if (storedLanguage && translations[storedLanguage]) {
    selectedLanguage.value = storedLanguage
  }

  loadCart()
  loadProducts()
  loadSiteTheme()
})

watch(selectedLanguage, (language) => {
  window.localStorage.setItem('preferred-language', language)
})

watch(selectedProductCode, (code) => {
  if (!isOsimRenewalCode(code)) form.ownerChangeRequested = false
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

.site-footer {
  background: var(--brand);
  color: #f8f3ea;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  padding: 42px 0 22px;
}

.footer-grid {
  display: grid;
  grid-template-columns: minmax(220px, 320px) minmax(220px, 320px) repeat(3, minmax(110px, 0.7fr));
  gap: clamp(24px, 3vw, 48px);
  align-items: start;
}

.footer-brand {
  display: contents;
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
  color: #fff;
  font-size: 13px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.footer-column a,
.footer-column span {
  color: #fff;
  font-size: 16px;
  line-height: 1.35;
  text-decoration: none;
}

.footer-column a:hover {
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 4px;
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

  .footer-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .footer-brand {
    display: grid;
    grid-template-columns: minmax(220px, 320px) minmax(0, 1fr);
    gap: clamp(18px, 2.4vw, 32px);
    align-items: start;
    grid-column: 1 / -1;
    min-width: 0;
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
