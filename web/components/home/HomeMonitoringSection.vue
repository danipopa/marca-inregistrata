<template>
  <section
    id="monitorizare"
    class="monitoring-section"
  >
    <div class="wrap monitoring-shell">
      <div class="monitoring-header">
        <p class="eyebrow">
          {{ labels.monitoringEyebrow }}
        </p>
        <h2>{{ labels.monitoringTitle }}</h2>
      </div>

      <div class="monitoring-layout">
        <div class="monitoring-copy">
          <p class="muted">
            {{ labels.monitoringCopy }}
          </p>
          <p>
            {{ labels.monitoringLead }}
          </p>
          <div class="monitoring-benefits">
            <strong>{{ labels.monitoringCoverageTitle }}</strong>
            <ul>
              <li
                v-for="item in labels.monitoringCoverage"
                :key="item"
              >
                {{ item }}
              </li>
            </ul>
          </div>
          <p class="monitoring-benefit">
            {{ labels.monitoringBenefit }}
          </p>
        </div>

        <div class="monitoring-panel">
          <form
            class="monitoring-form"
            @submit.prevent="$emit('addMonitoringToCart')"
          >
            <div class="monitoring-price">
              <span>{{ labels.monitoringPriceLabel }}</span>
              <strong>{{ priceLabel }}</strong>
              <small>{{ labels.monitoringPriceNote }}</small>
            </div>
            <label>
              {{ labels.monitoringMarkLabel }}
              <input
                :value="form.mark"
                type="text"
                :placeholder="labels.monitoringMarkPlaceholder"
                required
                minlength="2"
                @input="updateForm('mark', $event.target.value)"
              >
            </label>

            <div class="field-grid">
              <label>
                {{ labels.monitoringOfficeLabel }}
                <select
                  :value="form.offices"
                  multiple
                  @change="updateForm('offices', selectedValues($event))"
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
                {{ labels.monitoringClassLabel }}
                <select
                  :value="form.classes"
                  multiple
                  @change="updateForm('classes', selectedValues($event))"
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
              {{ labels.monitoringNotesLabel }}
              <textarea
                :value="form.notes"
                rows="6"
                :placeholder="labels.monitoringNotesPlaceholder"
                @input="updateForm('notes', $event.target.value)"
              />
            </label>

            <label class="checkbox">
              <input
                :checked="form.terms"
                type="checkbox"
                required
                @change="updateForm('terms', $event.target.checked)"
              >
              <span>{{ labels.termsLabel }}</span>
            </label>

            <button
              class="primary-btn"
              type="submit"
              :disabled="!canSubmit"
            >
              {{ labels.monitoringSubmit }}
            </button>
          </form>

          <p
            v-if="error"
            class="error-message"
          >
            {{ error }}
          </p>

          <p
            v-if="message"
            class="success-message"
          >
            {{ message }}
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const emit = defineEmits(['addMonitoringToCart', 'update:form'])

const props = defineProps({
  canSubmit: {
    type: Boolean,
    default: false,
  },
  error: {
    type: String,
    default: '',
  },
  form: {
    type: Object,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  message: {
    type: String,
    default: '',
  },
  niceClasses: {
    type: Array,
    required: true,
  },
  priceLabel: {
    type: String,
    required: true,
  },
  selectedLanguage: {
    type: String,
    required: true,
  },
})

function selectedValues(event) {
  return Array.from(event.target.selectedOptions).map(option => option.value)
}

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
