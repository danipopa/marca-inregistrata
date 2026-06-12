<template>
  <section
    v-if="visible"
    id="formular"
    class="form-section"
  >
    <div class="wrap form-layout">
      <aside class="form-summary">
        <span class="country-pill">RO</span>
        <h2>{{ selectedProduct?.title || labels.emptyProducts }}</h2>
        <p
          v-if="selectedProduct"
          class="muted"
        >
          {{ selectedProduct.note }}.
        </p>

        <div class="summary-box">
          <span>{{ labels.summaryTotal }}</span>
          <strong>{{ formattedTotal }}</strong>
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
            <select
              :value="selectedProductCode"
              required
              @change="$emit('update:selectedProductCode', $event.target.value)"
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
            {{ labels.markLabel }} *
            <input
              :value="form.mark"
              type="text"
              :placeholder="labels.markPlaceholder"
              required
              @input="updateForm('mark', $event.target.value)"
            >
          </label>
          <label>
            {{ labels.classesLabel }} *
            <select
              :value="form.classes"
              @change="updateForm('classes', Number($event.target.value))"
            >
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
            <strong>{{ labels.includedTitle }}</strong>
            <span>{{ labels.includedCopy }}</span>
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
          <h2>{{ labels.stepTwoTitle }}</h2>
          <p class="muted">
            {{ labels.stepTwoCopy }}
          </p>
          <label>
            {{ labels.primaryClassLabel }} *
            <div class="nisa-picker">
              <button
                type="button"
                class="nisa-picker__trigger"
                :class="{ empty: !selectedNiceClass }"
                :aria-expanded="nisaPickerOpen"
                @click="$emit('update:nisaPickerOpen', !nisaPickerOpen)"
              >
                {{ selectedNiceClass?.label || labels.primaryClassPlaceholder }}
              </button>
              <div
                v-if="nisaPickerOpen"
                class="nisa-picker__menu"
                role="listbox"
                :aria-label="labels.primaryClassLabel"
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
                  @click="$emit('selectNiceClass', niceClass)"
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
              <small>{{ labels.niceSource }}</small>
            </div>
            <strong>{{ labels.niceOfficialTitle }}</strong>
            <p>{{ selectedNiceClass.detail }}</p>
            <div class="included-box">
              <strong>{{ labels.niceGuidanceTitle }}</strong>
              <span>{{ labels.niceGuidanceCopy }}</span>
              <span v-if="form.classes > 1">{{ labels.extraClassesHint }}</span>
            </div>
          </div>
          <label>
            {{ labels.goodsLabel }}
            <textarea
              :value="form.goods"
              rows="5"
              :placeholder="labels.goodsPlaceholder"
              @input="updateForm('goods', $event.target.value)"
            />
          </label>
        </div>

        <div
          v-else-if="currentStep === 2"
          class="form-step"
        >
          <h2>{{ labels.stepFourTitle }}</h2>
          <p class="muted">
            {{ labels.stepFourCopy }}
          </p>
          <div class="payment-card">
            <strong>{{ formattedTotal }}</strong>
            <span v-if="selectedProduct">{{ selectedProduct.title }}</span>
            <span>{{ form.mark }}</span>
            <small>{{ labels.addToCartPaymentNote }}</small>
          </div>
          <label class="checkbox">
            <input
              :checked="form.terms"
              type="checkbox"
              required
              @change="updateForm('terms', $event.target.checked)"
            >
            <span>{{ labels.termsLabel }}</span>
          </label>
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
            @click="$emit('update:currentStep', currentStep + 1)"
          >
            {{ labels.next }}
          </button>
          <button
            v-else
            type="button"
            class="primary-btn"
            @click="$emit('addToCart')"
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
const emit = defineEmits([
  'addToCart',
  'selectNiceClass',
  'update:currentStep',
  'update:form',
  'update:nisaPickerOpen',
  'update:selectedProductCode',
])

const props = defineProps({
  cartMessage: {
    type: String,
    default: '',
  },
  classLabel: {
    type: Function,
    required: true,
  },
  currentStep: {
    type: Number,
    required: true,
  },
  form: {
    type: Object,
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
  nisaPickerOpen: {
    type: Boolean,
    default: false,
  },
  plans: {
    type: Array,
    required: true,
  },
  selectedNiceClass: {
    type: Object,
    default: null,
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

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
