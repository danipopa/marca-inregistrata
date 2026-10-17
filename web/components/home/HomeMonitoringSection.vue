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

            <label>
              {{ labels.monitoringRegistrationNumberLabel }}
              <input
                :value="form.registrationNumber"
                type="text"
                :placeholder="labels.monitoringRegistrationNumberPlaceholder"
                maxlength="255"
                required
                @input="updateForm('registrationNumber', $event.target.value)"
              >
            </label>

            <fieldset class="monitoring-offices">
              <legend>{{ labels.monitoringRegistrationOfficeLabel }}</legend>
              <div class="monitoring-office-options">
                <label
                  v-for="office in ['OSIM', 'EUIPO', 'WIPO']"
                  :key="office"
                  class="monitoring-office-option"
                >
                  <input
                    type="radio"
                    name="monitoring-registration-office"
                    :value="office"
                    :checked="form.registrationOffice === office"
                    required
                    @change="updateForm('registrationOffice', office)"
                  >
                  <span>{{ office }}</span>
                </label>
              </div>
            </fieldset>

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
  priceLabel: {
    type: String,
    required: true,
  },
})

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
