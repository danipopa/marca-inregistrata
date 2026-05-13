<template>
  <div class="page-shell">
    <div class="top-strip">
      <div class="wrap top-strip__inner">
        <div class="contact-line">
          <span>021 313 5799</span>
          <span>office@dansandu.ro</span>
        </div>
        <nav aria-label="Servicii rapide" class="quick-links">
          <a href="#reinnoire">Reinnoire marca</a>
          <a href="#monitorizare">Monitorizare marca</a>
          <a href="#preturi">Inregistrare marca</a>
          <a href="#verificare">Verificare marca</a>
        </nav>
      </div>
    </div>

    <header class="main-header">
      <div class="wrap main-header__inner">
        <a class="brand" href="#" aria-label="Dan Sandu si asociatii">
          <span class="brand__mark">DS</span>
          <span>
            <strong>DAN SANDU</strong>
            <small>SI ASOCIATII</small>
          </span>
        </a>
        <nav aria-label="Navigatie principala" class="main-nav">
          <a href="#despre">Despre</a>
          <a href="#cariere">Cariere</a>
          <a href="#arii">Arii de practica</a>
          <a href="#blog">Blog</a>
          <a href="#contact">Contact</a>
          <a href="#english">English</a>
        </nav>
      </div>
    </header>

    <main>
      <section class="hero">
        <div class="wrap hero__grid">
          <div class="hero__copy">
            <p class="eyebrow">Proprietate intelectuala</p>
            <h1>Inregistrare marca Romania UE</h1>
            <p class="lead">
              Procedura asistata pentru OSIM si Uniunea Europeana, cu onorarii clare,
              taxe oficiale incluse si documentatie pregatita pe baza datelor completate online.
            </p>
            <div class="hero__actions">
              <a class="primary-btn" href="#preturi">Vezi pachetele</a>
              <a class="text-link" href="#formular">Completeaza formularul</a>
            </div>
          </div>

          <aside class="secure-panel" aria-label="Conexiune securizata">
            <div class="secure-panel__icon">SSL</div>
            <div>
              <strong>Conexiune securizata</strong>
              <span>Plata online si datele de contact sunt gestionate in pasi separati.</span>
            </div>
          </aside>
        </div>
      </section>

      <section id="preturi" class="pricing-section">
        <div class="wrap">
          <div class="section-head">
            <p class="eyebrow">RON / EUR</p>
            <h2>Alege tipul de marca</h2>
          </div>

          <div class="currency-tabs" role="tablist" aria-label="Moneda">
            <button
              v-for="currency in currencies"
              :key="currency"
              type="button"
              :class="{ active: selectedCurrency === currency }"
              @click="selectedCurrency = currency"
            >
              {{ currency }}
            </button>
          </div>

          <div class="price-grid">
            <article v-for="plan in visiblePlans" :key="plan.title" class="price-card">
              <div class="price-card__top">
                <span class="country-pill">{{ plan.region }}</span>
                <h3>{{ plan.title }}</h3>
                <p>{{ plan.note }}</p>
              </div>
              <div class="price">
                <span>{{ plan.price }}</span>
                <small>{{ plan.tax }}</small>
              </div>
              <ul>
                <li v-for="item in plan.items" :key="item">{{ item }}</li>
              </ul>
              <a href="#formular" class="register-btn">Inregistreaza</a>
              <p class="card-foot">Conexiune securizata</p>
            </article>
          </div>
        </div>
      </section>

      <section class="start-band" id="verificare">
        <div class="wrap start-band__inner">
          <div>
            <p class="eyebrow">Nu stiti de unde sa incepeti?</p>
            <h2>Incepeti cu o verificare de marca</h2>
          </div>
          <p>
            O analiza prealabila ajuta la identificarea riscurilor inainte de depunere.
            Pentru comenzi complexe, echipa poate clarifica produsele si serviciile potrivite.
          </p>
          <a class="outline-btn" href="#formular">Solicita verificare</a>
        </div>
      </section>

      <section id="formular" class="form-section">
        <div class="wrap form-layout">
          <aside class="form-summary">
            <span class="country-pill">RO</span>
            <h2>Marca verbala</h2>
            <p class="muted">Doar litere, cifre sau caractere, fara logo.</p>

            <div class="summary-box">
              <span>Cost total estimat</span>
              <strong>{{ formattedTotal }}</strong>
              <small>include TVA, onorariu si taxe oficiale pentru selectia curenta</small>
            </div>

            <ol class="steps">
              <li v-for="(step, index) in steps" :key="step" :class="{ active: currentStep === index }">
                <span>{{ index + 1 }}</span>
                {{ step }}
              </li>
            </ol>
          </aside>

          <form class="registration-form" @submit.prevent="submitForm">
            <div v-if="currentStep === 0" class="form-step">
              <h2>Inregistrare marca verbala</h2>
              <p class="muted">
                Completati atent. Documentatia pentru OSIM se pregateste pe baza acestor informatii.
              </p>
              <label>
                Marca pe care doriti sa o inregistrati *
                <input v-model="form.mark" type="text" placeholder="Ex: NUMELE BRANDULUI" required>
              </label>
              <label>
                Cate clase NISA doriti sa protejati? *
                <select v-model.number="form.classes">
                  <option v-for="count in 11" :key="count" :value="count">
                    {{ classLabel(count) }}
                  </option>
                </select>
              </label>
              <div class="included-box">
                <strong>Pretul include</strong>
                <span>consultanta prealabila, detaliere clase NISA, depunere, raportari si certificatul original.</span>
              </div>
            </div>

            <div v-else-if="currentStep === 1" class="form-step">
              <h2>Selectie clase NISA</h2>
              <p class="muted">
                Alegeti clasele dorite. Dupa depunere, clasele si produsele nu pot fi adaugate retroactiv.
              </p>
              <label>
                Clasa NISA inclusa *
                <select v-model="form.primaryClass" required>
                  <option value="" disabled>Selectati clasa NISA inclusa</option>
                  <option v-for="niceClass in niceClasses" :key="niceClass" :value="niceClass">
                    {{ niceClass }}
                  </option>
                </select>
              </label>
              <label>
                Descrieti produsele sau serviciile
                <textarea v-model="form.goods" rows="5" placeholder="Ex: magazin online de haine, productie software, servicii de marketing"></textarea>
              </label>
            </div>

            <div v-else-if="currentStep === 2" class="form-step">
              <h2>Date contact si facturare</h2>
              <div class="field-grid">
                <label>
                  Email *
                  <input v-model="form.email" type="email" placeholder="email@companie.ro" required>
                </label>
                <label>
                  Telefon mobil *
                  <input v-model="form.phone" type="tel" placeholder="07xx xxx xxx" required>
                </label>
              </div>
              <label>
                Inregistrati marca pe
                <select v-model="form.ownerType">
                  <option>Societate</option>
                  <option>Persoana fizica</option>
                </select>
              </label>
              <div class="field-grid">
                <label>
                  CUI / identificator fiscal
                  <input v-model="form.taxId" type="text" placeholder="RO12345678">
                </label>
                <label>
                  Denumire titular
                  <input v-model="form.ownerName" type="text" placeholder="Compania SRL">
                </label>
              </div>
              <label>
                Adresa de facturare
                <textarea v-model="form.address" rows="4" placeholder="Strada, numar, localitate, judet"></textarea>
              </label>
            </div>

            <div v-else class="form-step">
              <h2>Informatii plata</h2>
              <p class="muted">Alegeti metoda de plata. Comanda ramane in asteptare pana la confirmare.</p>
              <div class="payment-options">
                <label>
                  <input v-model="form.payment" type="radio" value="card">
                  Plata cu cardul prin Stripe
                </label>
                <label>
                  <input v-model="form.payment" type="radio" value="transfer">
                  Plata prin transfer bancar
                </label>
              </div>
              <div class="payment-card">
                <strong>{{ formattedTotal }}</strong>
                <span>Visa / Mastercard / Amex / Google Pay</span>
                <small>Procesare securizata. Datele cardului nu sunt salvate local.</small>
              </div>
              <label class="checkbox">
                <input v-model="form.terms" type="checkbox" required>
                Sunt de acord cu termenii de utilizare si politica de confidentialitate.
              </label>
            </div>

            <div class="form-actions">
              <button type="button" class="ghost-btn" :disabled="currentStep === 0" @click="currentStep--">
                Inapoi
              </button>
              <button v-if="currentStep < steps.length - 1" type="button" class="primary-btn" @click="currentStep++">
                Pasul urmator
              </button>
              <button v-else type="submit" class="primary-btn" :disabled="submitting">
                {{ submitting ? 'Se trimite...' : 'Gata de inregistrare' }}
              </button>
            </div>

            <p v-if="submitted" class="success-message">
              {{ successMessage }}
            </p>

            <p v-if="submitError" class="error-message">
              {{ submitError }}
            </p>
          </form>
        </div>
      </section>
    </main>

    <footer class="site-footer" id="contact">
      <div class="wrap footer-grid">
        <div class="footer-brand">
          <strong>DAN SANDU SI ASOCIATII</strong>
          <p>
            Consultanta pentru inregistrare marca OSIM si UE, verificari preliminare
            si asistenta pe parcursul procedurii.
          </p>
        </div>

        <nav aria-label="Despre noi" class="footer-column">
          <h2>Despre noi</h2>
          <a href="#despre">Echipa</a>
          <a href="#arii">Arii de practica</a>
          <a href="#preturi">Onorarii</a>
          <a href="#contact">Contact</a>
        </nav>

        <nav aria-label="Resurse" class="footer-column">
          <h2>Resurse</h2>
          <a href="#verificare">Verificare marca</a>
          <a href="#formular">Inregistrare marca</a>
          <a href="#monitorizare">Monitorizare marca</a>
          <a href="#reinnoire">Reinnoire marca</a>
        </nav>

        <div class="footer-column">
          <h2>Contact</h2>
          <a href="tel:0213135799">021 313 5799</a>
          <a href="mailto:office@dansandu.ro">office@dansandu.ro</a>
          <span>Luni - Vineri, 09:00 - 19:00</span>
        </div>

        <nav aria-label="Linkuri ANPC" class="footer-column anpc-links">
          <h2>ANPC</h2>
          <a href="https://anpc.ro/" target="_blank" rel="noopener noreferrer">ANPC</a>
          <a href="https://ec.europa.eu/consumers/odr" target="_blank" rel="noopener noreferrer">
            Solutionarea online a litigiilor
          </a>
          <a href="https://anpc.ro/ce-este-sal/" target="_blank" rel="noopener noreferrer">
            Solutionarea alternativa a litigiilor
          </a>
        </nav>
      </div>

      <div class="wrap footer-bottom">
        <span>© 2026 Dan Sandu si Asociatii. Toate drepturile rezervate.</span>
        <span>Politica de confidentialitate · Termeni de utilizare</span>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'

const currencies = ['RON', 'EUR']
const selectedCurrency = ref('RON')
const currentStep = ref(0)
const submitted = ref(false)
const submitting = ref(false)
const submitError = ref('')
const successMessage = ref('')
const config = useRuntimeConfig()

const steps = ['Marca', 'Clase NISA', 'Facturare', 'Plata']

const form = reactive({
  mark: '',
  classes: 1,
  primaryClass: '',
  goods: '',
  email: '',
  phone: '',
  ownerType: 'Societate',
  taxId: '',
  ownerName: '',
  address: '',
  payment: 'card',
  terms: false,
})

const plans = [
  {
    currency: 'RON',
    region: 'RO',
    title: 'Marca verbala',
    note: 'doar litere si cifre, fara logo',
    price: '2.226 Lei',
    tax: 'include TVA',
    items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.016 Lei', 'o clasa NISA inclusa', 'plata online securizata'],
  },
  {
    currency: 'RON',
    region: 'RO',
    title: 'Marca alb-negru',
    note: 'scriere speciala sau logo monocrom',
    price: '2.378 Lei',
    tax: 'include TVA',
    items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.168 Lei', 'detaliere produse si servicii', 'o clasa NISA inclusa'],
  },
  {
    currency: 'RON',
    region: 'RO',
    title: 'Marca color',
    note: 'logo, design sau scriere color',
    price: '3.140 Lei',
    tax: 'include TVA',
    items: ['onorariu inclus: 1.210 Lei', 'taxe OSIM incluse: 1.930 Lei', 'upload fisier logo', 'o clasa NISA inclusa'],
  },
  {
    currency: 'EUR',
    region: 'UE',
    title: 'Marca Uniunea Europeana',
    note: 'protectie in statele membre UE',
    price: '1.090 EUR',
    tax: 'include TVA',
    items: ['onorariu inclus: 240 EUR', 'taxe EUIPO incluse: 850 EUR', 'o clasa NISA inclusa', 'depunere asistata online'],
  },
  {
    currency: 'EUR',
    region: 'UE',
    title: 'Logo UE',
    note: 'semn figurativ sau mixt',
    price: '620 EUR',
    tax: 'include TVA',
    items: ['onorariu inclus: 240 EUR', 'taxe oficiale incluse: 380 EUR', 'detaliere clase NISA', 'procesare securizata'],
  },
]

const niceClasses = [
  'Clasa 9: software, calculatoare, telefoane mobile',
  'Clasa 25: imbracaminte, incaltaminte, palarii',
  'Clasa 30: cafea, ceai, cacao, patiserie',
  'Clasa 35: comert, retail, publicitate, marketing',
  'Clasa 41: educatie, divertisment, activitati sportive',
  'Clasa 42: servicii IT, programare, proiectare',
  'Clasa 43: restaurante, baruri, hoteluri',
  'Clasa 45: servicii juridice si protectie',
]

const visiblePlans = computed(() => plans.filter((plan) => plan.currency === selectedCurrency.value))
const total = computed(() => 2226 + (form.classes - 1) * 449)
const formattedTotal = computed(() => `${total.value.toLocaleString('ro-RO')} Lei`)

function classLabel(count) {
  if (count === 1) return 'O clasa NISA (inclusa)'
  return `${count} clase NISA (+${(count - 1) * 449} Lei)`
}

async function submitForm() {
  submitted.value = false
  submitError.value = ''
  successMessage.value = ''
  submitting.value = true

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/trademark_requests`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        trademark_request: {
          mark: form.mark,
          classes: form.classes,
          primary_class: form.primaryClass,
          goods: form.goods,
          email: form.email,
          phone: form.phone,
          owner_type: form.ownerType,
          tax_id: form.taxId,
          owner_name: form.ownerName,
          address: form.address,
          payment: form.payment,
          terms: form.terms,
        },
      }),
    })

    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Nu am putut trimite solicitarea. Verificati datele si incercati din nou.')
    }

    submitted.value = true
    successMessage.value = payload.message || 'Solicitarea a fost inregistrata.'
  } catch (error) {
    submitError.value = error instanceof Error ? error.message : 'Nu am putut trimite solicitarea.'
  } finally {
    submitting.value = false
  }
}
</script>

<style>
:root {
  color-scheme: light;
  --ink: #1f1d1a;
  --muted: #68635c;
  --line: #ded8cf;
  --paper: #fbfaf7;
  --cream: #f2eee6;
  --gold: #b79254;
  --gold-dark: #8a6837;
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
  font-family: Georgia, 'Times New Roman', serif;
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
  background: #2b2926;
  color: #f8f3ea;
  font-family: Arial, sans-serif;
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
  text-transform: uppercase;
}

.main-header {
  background: rgba(251, 250, 247, 0.96);
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

.brand small {
  color: var(--muted);
  font-family: Arial, sans-serif;
  font-size: 10px;
  margin-top: 2px;
}

.main-nav {
  color: #38332d;
  font-family: Arial, sans-serif;
  font-size: 12px;
  justify-content: flex-end;
}

.hero {
  background:
    linear-gradient(90deg, rgba(43, 41, 38, 0.9), rgba(43, 41, 38, 0.66)),
    linear-gradient(135deg, #3a342d, #9a855d);
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
  font-family: Arial, sans-serif;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
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
  font-family: Arial, sans-serif;
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
.register-btn,
.ghost-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  border: 0;
  border-radius: 2px;
  cursor: pointer;
  font-family: Arial, sans-serif;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-decoration: none;
  text-transform: uppercase;
}

.primary-btn,
.register-btn {
  background: var(--gold);
  color: #191713;
  padding: 0 22px;
}

.text-link {
  color: #fff;
  font-family: Arial, sans-serif;
  text-underline-offset: 4px;
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
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
  font-size: 14px;
  line-height: 1.5;
}

.pricing-section,
.form-section {
  padding: 64px 0;
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
  font-family: Arial, sans-serif;
  font-size: 12px;
  font-weight: 700;
}

.price-card h3 {
  margin: 16px 0 6px;
  font-size: 25px;
  font-weight: 400;
  text-transform: uppercase;
}

.price-card p,
.muted {
  color: var(--muted);
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
}

.price-card ul {
  display: grid;
  gap: 10px;
  margin: 0 0 22px;
  padding: 0;
  list-style: none;
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
}

.summary-box span,
.summary-box small {
  color: var(--muted);
}

.summary-box strong {
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 30px;
  font-weight: 400;
}

.steps {
  display: grid;
  gap: 12px;
  margin: 0;
  padding: 0;
  list-style: none;
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
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
  font-family: Arial, sans-serif;
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
  font-family: Georgia, 'Times New Roman', serif;
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
  font-family: Arial, sans-serif;
  font-weight: 700;
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

.site-footer {
  background: #2b2926;
  color: #f8f3ea;
  font-family: Arial, sans-serif;
  padding: 42px 0 22px;
}

.footer-grid {
  display: grid;
  grid-template-columns: 1.4fr repeat(4, minmax(0, 1fr));
  gap: 28px;
}

.footer-brand strong {
  display: block;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 22px;
  font-weight: 400;
  letter-spacing: 0.08em;
}

.footer-brand p {
  max-width: 320px;
  margin: 14px 0 0;
  color: #cfc6b7;
  line-height: 1.7;
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
  color: #e8dfd1;
  font-size: 14px;
  line-height: 1.45;
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

@media (max-width: 980px) {
  .main-header__inner,
  .top-strip__inner,
  .start-band__inner,
  .form-layout,
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
  .form-layout {
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
  .form-section {
    padding: 42px 0;
  }

  .form-summary,
  .registration-form,
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

  .footer-grid,
  .footer-bottom {
    grid-template-columns: 1fr;
    flex-direction: column;
  }
}
</style>
