<template>
  <section
    v-if="visible"
    id="formular"
    class="form-section"
  >
    <div class="wrap form-layout">
      <div class="summary-column">
        <details
          v-if="classPrices.length"
          class="class-prices-card"
          @mouseenter="openClassPricesOnHover"
          @mouseleave="closeClassPricesOnLeave"
          @keydown.esc="$event.currentTarget.open = false"
        >
          <summary>{{ labels.classPricesView }}</summary>
          <div class="class-prices-popover">
            <table
              v-if="classPrices.length"
              class="customer-class-prices"
            >
              <caption>{{ labels.classPricesTitle }}</caption>
              <thead>
                <tr><th scope="col">{{ labels.classPricesCount }}</th><th scope="col">{{ labels.classPricesTotal }}</th></tr>
              </thead>
              <tbody>
                <tr
                  v-for="row in classPrices"
                  :key="row.count"
                  :class="{ 'is-selected': row.count === selectedNiceClasses.length }"
                >
                  <th scope="row">{{ labels.classPricesQuantity(row.count) }}</th>
                  <td>{{ row.price }}</td>
                </tr>
              </tbody>
            </table>
            <p v-if="classPrices.length" class="class-prices-note">{{ labels.classPricesNote }}</p>

          </div>
        </details>
        <aside
          class="form-summary"
          aria-labelledby="selection-summary-title"
        >
          <span
            v-if="selectedOffice"
            class="country-pill"
          >{{ selectedOffice }}</span>
          <h2 id="selection-summary-title">
            {{ labels.selectionSummary }}
          </h2>
          <p
            v-if="selectedProduct"
            class="muted"
          >
            {{ selectedProduct.note }}.
          </p>

          <dl class="selection-details">
            <div>
              <dt>{{ labels.summaryProduct }}</dt>
              <dd>{{ selectedProduct?.title || labels.emptyProducts }}</dd>
            </div>
            <div v-if="form.mark?.trim()">
              <dt>{{ labels.summaryTrademark }}</dt>
              <dd>{{ form.mark.trim() }}</dd>
            </div>
            <template v-if="!isVerificationProduct && selectedNiceClasses.length">
              <div>
                <dt>{{ labels.summaryClasses }}</dt>
                <dd>{{ selectedNiceClasses.length }} — {{ formattedClassPrice }}</dd>
              </div>
              <div>
                <dt>{{ labels.summaryPrimaryClass }}</dt>
                <dd class="selection-class-list">
                  <span
                    v-for="niceClass in selectedNiceClasses"
                    :key="niceClass.number"
                    class="selected-class-item"
                  >
                    <button
                      type="button"
                      class="selected-class-label"
                      :aria-label="niceClass.label"
                      :aria-describedby="`selected-class-description-${niceClass.number}`"
                    >
                      <span class="selected-class-number">{{ labels.niceClassNumber(niceClass.number) }}:</span>
                      <span class="selected-class-preview">{{ niceClass.detail }}</span>
                    </button>
                    <span
                      :id="`selected-class-description-${niceClass.number}`"
                      class="selected-class-tooltip"
                      role="tooltip"
                    >{{ niceClass.detail }}</span>
                  </span>
                </dd>
              </div>
            </template>
            <div v-if="!isRenewalProduct && form.goods?.trim()">
              <dt>{{ isVerificationProduct ? labels.verificationGoodsLabel : labels.goodsLabel }}</dt>
              <dd class="selection-description">
                {{ form.goods.trim() }}
              </dd>
            </div>
          </dl>
          <p
            v-if="isOsimRenewalProduct && form.ownerChangeRequested"
            class="selection-option"
          >
            {{ labels.ownerChangeOption }}
          </p>


          <div class="summary-box">
            <span>{{ labels.summaryTotal }}</span>
            <strong
              aria-live="polite"
              aria-atomic="true"
            >{{ formattedTotal }}</strong>
            <small>{{ labels.summaryNote }}</small>
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
      </div>

      <div class="registration-form">
        <div
          v-if="currentStep === 0"
          class="form-step"
        >
          <p class="muted">
            {{ labels.stepOneCopy }}
          </p>
          <label>
            {{ labels.productLabel }} *
            <input
              :value="selectedProduct ? `${selectedOffice} - ${selectedProduct.title} (${selectedProduct.price})` : labels.emptyProducts"
              type="text"
              readonly
              :class="{ 'field-error': isFieldInvalid('product') }"
            >
            <p
              v-if="isFieldInvalid('product')"
              class="field-hint field-hint--error"
            >
              {{ labels.requiredFieldHint }}
            </p>
          </label>
          <label>
            {{ markLabel }} *
            <input
              :value="form.mark"
              type="text"
              :placeholder="labels.markPlaceholder"
              required
              :class="{ 'field-error': isFieldInvalid('mark') }"
              @input="updateForm('mark', $event.target.value)"
            >
            <p
              v-if="isFieldInvalid('mark')"
              class="field-hint field-hint--error"
            >
              {{ labels.requiredFieldHint }}
            </p>
          </label>
          <fieldset
            v-if="!isVerificationProduct"
            class="nice-selection-field"
          >
            <legend>{{ isRenewalProduct ? labels.renewalClassesLabel : labels.classesLabel }} *</legend>
            <details
              ref="nicePicker"
              class="nice-multiselect"
              @keydown.esc="$event.currentTarget.open = false"
            >
              <summary
                :class="{ 'field-error': isFieldInvalid('niceClass') }"
                aria-describedby="nice-selection-help"
              >
                <template v-if="selectedNiceClasses.length">
                  {{ labels.niceSelectedCount(selectedNiceClasses.length) }} — {{ formattedClassPrice }}
                </template>
                <template v-else>
                  {{ labels.niceSelectPlaceholder }}
                </template>
              </summary>
              <div class="nice-multiselect-panel">
                <input
                  v-model="niceSearch"
                  type="search"
                  :placeholder="labels.niceSearchPlaceholder"
                  :aria-label="labels.niceSearchPlaceholder"
                >
                <div class="nice-multiselect-options">
                  <label
                    v-for="niceClass in filteredNiceClasses"
                    :key="niceClass.number"
                    class="nice-check-option"
                  >
                    <input
                      type="checkbox"
                      :checked="isNiceClassSelected(niceClass.number)"
                      :disabled="!isNiceClassSelected(niceClass.number) && selectedNiceClasses.length >= maxNiceClasses"
                      @change="toggleNiceClass(niceClass.number, $event.target.checked)"
                    >
                    <span><strong>{{ niceClass.label }}</strong><small>{{ niceClass.typeLabel }}</small></span>
                  </label>
                  <p
                    v-if="!filteredNiceClasses.length"
                    class="muted"
                  >
                    {{ labels.niceNoResults }}
                  </p>
                </div>
              </div>
            </details>
            <p
              id="nice-selection-help"
              class="field-hint"
            >
              {{ labels.niceSelectionHint }}
            </p>
            <p
              v-if="isFieldInvalid('niceClass')"
              class="field-hint field-hint--error"
            >
              {{ labels.requiredFieldHint }}
            </p>
          </fieldset>
          <label v-if="!isRenewalProduct">
            {{ isVerificationProduct ? labels.verificationGoodsLabel : labels.goodsLabel }}
            <textarea
              :value="form.goods"
              rows="5"
              :placeholder="labels.goodsPlaceholder"
              @input="updateForm('goods', $event.target.value)"
            />
          </label>
          <div class="included-box">
            <strong>{{ labels.includedTitle }}</strong>
            <span>{{ isRenewalProduct ? labels.renewalIncludedCopy : labels.includedCopy }}</span>
          </div>
          <label
            v-if="isOsimRenewalProduct"
            class="checkbox"
          >
            <input
              :checked="form.ownerChangeRequested"
              type="checkbox"
              @change="updateForm('ownerChangeRequested', $event.target.checked)"
            >
            <span>{{ labels.ownerChangeOption }}</span>
          </label>
        </div>

        <div
          v-else-if="currentStep === 1"
          class="form-step"
        >
          <h2>{{ labels.stepFourTitle }}</h2>
          <p class="muted">
            {{ labels.stepFourCopy }}
          </p>
          <div class="payment-card">
            <strong>{{ formattedTotal }}</strong>
            <dl class="request-review">
              <div>
                <dt>{{ labels.summaryProduct }}</dt>
                <dd>{{ selectedProduct?.title }}</dd>
              </div>
              <div v-if="selectedOffice">
                <dt>{{ labels.reviewOffice }}</dt>
                <dd>{{ selectedOffice }}</dd>
              </div>
              <div>
                <dt>{{ labels.summaryTrademark }}</dt>
                <dd>{{ form.mark }}</dd>
              </div>
              <template v-if="!isVerificationProduct">
                <div>
                  <dt>{{ labels.summaryClasses }}</dt>
                  <dd>{{ selectedNiceClasses.length }} — {{ formattedClassPrice }}</dd>
                </div>
                <div>
                  <dt>{{ labels.summaryPrimaryClass }}</dt>
                  <dd>
                    <ul class="review-class-list">
                      <li v-for="niceClass in selectedNiceClasses" :key="niceClass.number">
                        <strong>{{ labels.niceClassNumber(niceClass.number) }} · {{ niceClass.typeLabel }}</strong>
                        <p>{{ niceClass.detail }}</p>
                      </li>
                    </ul>
                  </dd>
                </div>
              </template>
              <div v-if="!isRenewalProduct">
                <dt>{{ isVerificationProduct ? labels.verificationGoodsLabel : labels.goodsLabel }}</dt>
                <dd class="review-description">{{ form.goods?.trim() || labels.reviewNotProvided }}</dd>
              </div>
              <div v-if="isOsimRenewalProduct">
                <dt>{{ labels.ownerChangeOption }}</dt>
                <dd>{{ form.ownerChangeRequested ? labels.reviewOptionIncluded : labels.reviewOptionNotIncluded }}</dd>
              </div>
            </dl>
            <small>{{ labels.addToCartPaymentNote }}</small>
          </div>
          <label class="checkbox">
            <input
              :checked="form.terms"
              type="checkbox"
              required
              :class="{ 'field-error': isFieldInvalid('terms') }"
              @change="updateForm('terms', $event.target.checked)"
            >
            <span>{{ labels.termsLabel }}</span>
          </label>
          <p
            v-if="isFieldInvalid('terms')"
            class="field-hint field-hint--error"
          >
            {{ labels.requiredFieldHint }}
          </p>
        </div>

        <div class="form-actions">
          <button
            type="button"
            class="ghost-btn"
            :disabled="currentStep === 0"
            @click="$emit('update:currentStep', currentStep - 1)"
          >
            {{ labels.back }}
          </button>
          <button
            v-if="currentStep < steps.length - 1"
            type="button"
            class="primary-btn"
            @click="goToNextStep"
          >
            {{ labels.next }}
          </button>
          <button
            v-else
            type="button"
            class="primary-btn"
            @click="addToCart"
          >
            {{ labels.addToCart }}
          </button>
        </div>

        <p
          v-if="cartMessage"
          class="success-message"
        >
          {{ cartMessage }}
        </p>

        <div
          v-if="cartMessage"
          class="post-add-actions"
        >
          <NuxtLink
            class="primary-btn"
            to="/checkout"
          >
            {{ labels.checkout }}
          </NuxtLink>
          <NuxtLink
            class="ghost-btn"
            to="/"
          >
            {{ labels.continueShopping }}
          </NuxtLink>
        </div>

        <p
          v-if="submitError"
          class="error-message"
        >
          {{ submitError }}
        </p>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { MAX_NICE_CLASSES, filterNiceClasses, normalizeNiceClassNumbers } from '../../utils/niceClassSelection'

const emit = defineEmits([
  'addToCart',
  'update:currentStep',
  'update:form',
])

const props = defineProps({
  classPrices: {
    type: Array,
    default: () => [],
  },
  cartMessage: {
    type: String,
    default: '',
  },
  currentStep: {
    type: Number,
    required: true,
  },
  form: {
    type: Object,
    required: true,
  },
  formattedClassPrice: {
    type: String,
    required: true,
  },
  formattedTotal: {
    type: String,
    required: true,
  },
  isOsimRenewalProduct: {
    type: Boolean,
    default: false,
  },
  labels: {
    type: Object,
    required: true,
  },
  niceClasses: {
    type: Array,
    required: true,
  },
  selectedProduct: {
    type: Object,
    default: null,
  },
  selectedProductCode: {
    type: String,
    required: true,
  },
  steps: {
    type: Array,
    required: true,
  },
  submitError: {
    type: String,
    default: '',
  },
  visible: {
    type: Boolean,
    default: false,
  },
})

function openClassPricesOnHover(event) {
  if (window.matchMedia('(hover: hover)').matches) event.currentTarget.open = true
}

function closeClassPricesOnLeave(event) {
  if (!event.currentTarget.contains(document.activeElement)) event.currentTarget.open = false
}

const selectedOffice = computed(() => {
  if (/^(renew-)?eu-/.test(props.selectedProductCode)) return 'EUIPO'
  if (/^(renew-)?ro-/.test(props.selectedProductCode)) return 'OSIM'
  return props.selectedProduct?.region || ''
})

const isRenewalProduct = computed(() => props.selectedProductCode.startsWith('renew-'))
const isVerificationProduct = computed(() => props.selectedProductCode.startsWith('verification-'))
const markLabel = computed(() => {
  if (isVerificationProduct.value) return props.labels.verificationMarkLabel
  if (isRenewalProduct.value) return props.labels.renewalMarkLabel
  return props.labels.markLabel
})

const maxNiceClasses = MAX_NICE_CLASSES
const niceSearch = ref('')
const nicePicker = ref(null)
function closeNicePicker(event) {
  if (nicePicker.value && !nicePicker.value.contains(event.target)) nicePicker.value.open = false
}
onMounted(() => document.addEventListener('pointerdown', closeNicePicker))
onBeforeUnmount(() => document.removeEventListener('pointerdown', closeNicePicker))
const selectedNiceClasses = computed(() => props.niceClasses.filter(item => isNiceClassSelected(item.number)))
const filteredNiceClasses = computed(() => filterNiceClasses(props.niceClasses, niceSearch.value))

function isNiceClassSelected(number) {
  return (props.form.niceClassNumbers || []).includes(number)
}

function toggleNiceClass(number, checked) {
  const selected = normalizeNiceClassNumbers(props.form.niceClassNumbers)
  if (checked && !selected.includes(number) && selected.length >= MAX_NICE_CLASSES) return
  updateForm('niceClassNumbers', checked ? normalizeNiceClassNumbers([...selected, number]) : selected.filter(value => value !== number))
}

const attemptedSteps = ref(new Set())

const currentStepInvalid = computed(() => {
  if (props.currentStep === 0) {
    return !props.selectedProductCode || !props.form.mark?.trim() || (!isVerificationProduct.value && !selectedNiceClasses.value.length)
  }

  return false
})

function hasAttemptedCurrentStep() {
  return attemptedSteps.value.has(props.currentStep)
}

function isFieldInvalid(field) {
  if (!hasAttemptedCurrentStep()) return false

  if (props.currentStep === 0) {
    return (field === 'product' && !props.selectedProductCode)
      || (field === 'mark' && !props.form.mark?.trim())
      || (field === 'niceClass' && !isVerificationProduct.value && !selectedNiceClasses.value.length)
  }

  if (props.currentStep === 1) {
    return field === 'terms' && !props.form.terms
  }

  return false
}

function markCurrentStepAttempted() {
  attemptedSteps.value = new Set([...attemptedSteps.value, props.currentStep])
}

function goToNextStep() {
  markCurrentStepAttempted()
  if (currentStepInvalid.value) return

  emit('update:currentStep', props.currentStep + 1)
}

function addToCart() {
  markCurrentStepAttempted()
  if (currentStepInvalid.value) return

  emit('addToCart')
}

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>

<style scoped>
.request-review { width: 100%; min-width: 0; margin: 8px 0; }
.request-review > div { padding: 14px 0; border-bottom: 1px solid var(--line, #ded8cf); }
.request-review dt { margin-bottom: 6px; font-size: 13px; color: var(--muted, #68635c); }
.request-review dd { margin: 0; overflow-wrap: anywhere; }
.review-class-list { display: grid; gap: 16px; margin: 0; padding: 0; list-style: none; }
.review-class-list strong { font-size: 14px; }
.review-class-list p { margin: 6px 0 0; font-size: 13px; line-height: 1.6; }
.review-description { white-space: pre-wrap; }

.customer-class-prices {
  width: 100%;
  margin-top: 24px;
  border-collapse: collapse;
  font-size: 14px;
}
.customer-class-prices caption {
  margin-bottom: 12px;
  text-align: left;
  font-weight: 700;
}
.customer-class-prices th,
.customer-class-prices td {
  padding: 7px 10px;
  border-bottom: 1px solid rgba(31, 29, 26, 0.12);
  text-align: left;
}
.customer-class-prices tbody th { font-weight: 400; }
.customer-class-prices th:last-child,
.customer-class-prices td:last-child { text-align: right; white-space: nowrap; }
.customer-class-prices .is-selected { background: #e2f5fa; color: #1f1d1a; }
.customer-class-prices .is-selected th,
.customer-class-prices .is-selected td { font-weight: 700; }
.class-prices-note { font-size: 12px; line-height: 1.5; color: var(--muted, #68635c); }

.nice-selection-field { min-width: 0; margin: 0; padding: 0; border: 0; }
.nice-selection-field legend { margin-bottom: 8px; font-weight: 700; }
.nice-multiselect { position: relative; }
.nice-multiselect > summary { cursor: pointer; padding: 14px; border: 1px solid #cfc7bc; background: #fff; border-radius: 6px; }
.nice-multiselect-panel { position: absolute; z-index: 30; inset: 100% 0 auto; padding: 12px; border: 1px solid #cfc7bc; border-radius: 6px; background: #fff; box-shadow: 0 12px 30px rgb(0 0 0 / 12%); }
.nice-multiselect-panel > input { box-sizing: border-box; width: 100%; margin-bottom: 10px; padding: 12px; border: 1px solid #cfc7bc; border-radius: 4px; font: inherit; }
.nice-multiselect-options { max-height: 320px; overflow-y: auto; overscroll-behavior: contain; }
.registration-form .nice-check-option { display: flex; align-items: start; gap: 12px; padding: 10px 6px; cursor: pointer; border-bottom: 1px solid #eee; }
.registration-form .nice-check-option > input { width: 18px; height: 18px; flex-shrink: 0; margin: 3px 0 0; padding: 0; accent-color: #00add9; }
.nice-check-option > span { min-width: 0; }
.nice-check-option strong { display: block; font-size: 13px; font-weight: 500; line-height: 1.5; overflow-wrap: anywhere; }
.nice-check-option small { display: block; margin-top: 4px; color: var(--muted, #68635c); }
.nice-check-option:has(input:checked) { background: #f0fbfe; }
.nice-check-option:has(input:disabled) { opacity: 0.5; cursor: not-allowed; }
.nice-class-review { padding: 14px; border: 1px solid var(--line, #ded8cf); border-radius: 6px; }
.nice-class-review summary { cursor: pointer; font-weight: 600; }
.nice-class-review > small { display: block; margin-top: 10px; color: var(--muted, #68635c); }
.nice-class-review > p { line-height: 1.6; }
.selection-class-list { display: grid; grid-template-columns: minmax(0, 1fr); gap: 8px; }
.selected-class-item { position: relative; display: block; min-width: 0; }
.selected-class-label { display: flex; align-items: center; gap: 6px; box-sizing: border-box; min-width: 0; width: 100%; padding: 8px 10px; border: 0; border-radius: 6px; background: #eefaff; color: inherit; font: inherit; font-size: 12px; text-align: left; cursor: help; }
.selected-class-number { flex-shrink: 0; font-weight: 700; white-space: nowrap; }
.selected-class-preview { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 400; }
.selected-class-label:hover { background: #d9f3fc; }
.selected-class-label:focus-visible { outline: 2px solid #00add9; outline-offset: 2px; }
.selected-class-tooltip { display: none; position: absolute; z-index: 40; top: 100%; left: 0; box-sizing: border-box; width: min(420px, calc(100vw - 80px)); max-height: 260px; overflow-y: auto; padding: 14px; border: 1px solid #b7e7f3; border-radius: 8px; background: #fff; box-shadow: 0 8px 24px rgb(0 0 0 / 14%); color: var(--ink, #1f1d1a); font-size: 13px; font-weight: 400; line-height: 1.6; overflow-wrap: anywhere; }
.selected-class-item:hover > .selected-class-tooltip,
.selected-class-item:focus-within > .selected-class-tooltip { display: block; }

.form-layout {
  display: grid;
  grid-template-columns: minmax(260px, 340px) minmax(0, 1fr);
  align-items: start;
  gap: 28px;
  width: min(1120px, calc(100% - 32px));
  margin-inline: auto;
}

.summary-column { position: sticky; top: 110px; min-width: 0; }
.class-prices-card {
  position: relative;
  margin-bottom: 16px;
  border: 1px solid var(--line, #ded8cf);
  border-radius: 12px;
  background: #fff;
  font-family: var(--font-family, 'Montserrat', sans-serif);
}
.class-prices-card > summary { padding: 16px 20px; cursor: pointer; font-size: 14px; font-weight: 700; }
.class-prices-card > summary:focus-visible { outline: 2px solid #00add9; outline-offset: 3px; border-radius: 12px; }
.class-prices-popover {
  position: absolute;
  z-index: 45;
  top: 100%;
  left: 0;
  box-sizing: border-box;
  width: 100%;
  max-height: min(520px, 70vh);
  overflow-y: auto;
  padding: 16px;
  border: 1px solid var(--line, #ded8cf);
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 12px 32px rgb(31 29 26 / 16%);
}
.class-prices-popover .customer-class-prices { margin-top: 0; }

.form-summary {
  min-width: 0;
  padding: 24px;
  border: 1px solid var(--line, #ded8cf);
  border-top: 4px solid #00add9;
  border-radius: 14px;
  background: #fff;
  box-shadow: 0 12px 32px rgb(31 29 26 / 6%);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.form-summary h2 {
  margin: 16px 0;
  font-size: 24px;
  line-height: 1.25;
  text-transform: none;
}

.form-summary .country-pill {
  display: inline-flex;
  align-items: center;
  padding: 6px 10px;
  border-radius: 20px;
  background: #eefaff;
  color: var(--brand, #013ebe);
  font-size: 12px;
  font-weight: 700;
}

.form-summary .steps {
  display: grid;
  gap: 12px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.form-summary .steps li {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--muted, #68635c);
  font-size: 13px;
}

.form-summary .steps li > span {
  display: grid;
  flex-shrink: 0;
  place-items: center;
  width: 30px;
  height: 30px;
  border: 1px solid var(--line, #ded8cf);
  border-radius: 50%;
}

.form-summary .steps li.active {
  color: var(--ink, #1f1d1a);
  font-weight: 700;
}

.form-summary .steps li.active > span {
  border-color: #00add9;
  background: #00add9;
}

.selection-details {
  display: grid;
  gap: 16px;
  margin: 24px 0;
}

.selection-details > div {
  display: grid;
  gap: 5px;
}

.selection-details dt {
  color: var(--muted, #68635c);
  font-size: 12px;
  font-weight: 500;
}

.selection-details dd {
  margin: 0;
  color: var(--ink, #1f1d1a);
  font-size: 14px;
  font-weight: 600;
  line-height: 1.5;
  overflow-wrap: anywhere;
}

.selection-description {
  display: -webkit-box;
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
}

.selection-option {
  padding: 12px;
  border-radius: 8px;
  background: #eefaff;
  font-size: 13px;
  line-height: 1.5;
}

.summary-box {
  display: grid;
  gap: 8px;
  margin: 24px 0;
  padding: 18px;
  border: 1px solid #b7e7f3;
  border-radius: 10px;
  background: #f0fbfe;
}

.summary-box > span,
.summary-box small {
  color: var(--muted, #68635c);
  font-size: 12px;
  line-height: 1.5;
}

.summary-box strong {
  color: var(--ink, #1f1d1a);
  font-size: 30px;
  font-weight: 600;
  overflow-wrap: anywhere;
}

.registration-form { min-width: 0; }

@media (max-width: 900px) {
  .form-layout { grid-template-columns: minmax(0, 1fr); }
  .summary-column { position: static; }
  .class-prices-popover { position: static; max-height: 60vh; box-shadow: none; border: 0; }
}

.primary-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  filter: grayscale(0.15);
}

.field-error {
  border-color: #c44d4d !important;
  box-shadow: inset 0 0 0 1px #c44d4d;
}

.field-hint {
  margin: 8px 0 0;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  line-height: 1.35;
}

.field-hint--error {
  color: #a23b3b;
}

.post-add-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 16px;
}
</style>
