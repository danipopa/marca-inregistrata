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

        <AccountBillingFields
          :form="form"
          :labels="labels"
          :field-labels="fieldLabels"
          @update:form="$emit('update:form', $event)"
        />

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
defineEmits(['close', 'save', 'update:form'])

defineProps({
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
</script>
