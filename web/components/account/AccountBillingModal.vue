<template>
  <div
    v-if="open"
    class="modal-backdrop"
    @click.self="$emit('close')"
  >
    <section
      class="billing-modal"
      role="dialog"
      aria-modal="true"
      :aria-label="labels.billingTitle"
    >
      <div class="modal-head">
        <div>
          <p class="panel-kicker">
            {{ labels.billingKicker }}
          </p>
          <h2>{{ labels.billingTitle }}</h2>
        </div>
        <button
          type="button"
          class="modal-close"
          :aria-label="labels.close"
          @click="$emit('close')"
        >
          x
        </button>
      </div>

      <form
        class="billing-form"
        @submit.prevent="$emit('save')"
      >
        <p>{{ labels.billingCopy }}</p>

        <label>
          {{ labels.phone }}
          <input
            :value="form.phone"
            type="tel"
            :placeholder="labels.phonePlaceholder"
            required
            @input="updateField('phone', $event.target.value)"
          >
        </label>

        <label>
          {{ labels.ownerType }}
          <select
            :value="form.ownerType"
            @change="updateField('ownerType', $event.target.value)"
          >
            <option value="Societate">{{ labels.company }}</option>
            <option value="Persoana fizica">{{ labels.person }}</option>
          </select>
        </label>

        <div class="field-grid">
          <label>
            {{ fieldLabels.taxId }}
            <input
              :value="form.taxId"
              type="text"
              :placeholder="fieldLabels.taxIdPlaceholder"
              @input="updateField('taxId', $event.target.value)"
            >
          </label>
          <label>
            {{ fieldLabels.ownerName }}
            <input
              :value="form.ownerName"
              type="text"
              :placeholder="fieldLabels.ownerNamePlaceholder"
              required
              @input="updateField('ownerName', $event.target.value)"
            >
          </label>
        </div>

        <label>
          {{ fieldLabels.address }}
          <textarea
            :value="form.address"
            rows="4"
            :placeholder="fieldLabels.addressPlaceholder"
            required
            @input="updateField('address', $event.target.value)"
          />
        </label>

        <div class="modal-actions">
          <button
            class="primary-btn"
            type="submit"
            :disabled="saving"
          >
            {{ saving ? labels.saving : labels.saveBilling }}
          </button>
          <button
            type="button"
            class="ghost-btn"
            @click="$emit('close')"
          >
            {{ labels.cancel }}
          </button>
        </div>

        <p
          v-if="message"
          class="success-message"
        >
          {{ message }}
        </p>
      </form>
    </section>
  </div>
</template>

<script setup>
const emit = defineEmits(['close', 'save', 'update:form'])

const props = defineProps({
  fieldLabels: {
    type: Object,
    required: true,
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
  open: {
    type: Boolean,
    default: false,
  },
  saving: {
    type: Boolean,
    default: false,
  },
})

function updateField(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
