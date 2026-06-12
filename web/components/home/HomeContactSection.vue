<template>
  <section
    id="contact"
    class="contact-section"
  >
    <div class="wrap contact-layout">
      <div class="contact-copy">
        <p class="eyebrow">
          {{ labels.contactEyebrow }}
        </p>
        <h2>{{ labels.contactTitle }}</h2>
        <p class="muted">
          {{ labels.contactCopy }}
        </p>

        <div class="contact-details">
          <div>
            <span>{{ labels.contactAddressLabel }}</span>
            <strong>Str. C. Libertății, Nr. 42, Sector 3, București</strong>
          </div>
          <div>
            <span>Email</span>
            <a href="mailto:office@sandusiasociatii.ro">office@sandusiasociatii.ro</a>
            <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
          </div>
          <div>
            <span>{{ labels.contactPhoneLabel }}</span>
            <a href="tel:0770898767">0770 898 767</a>
          </div>
        </div>
      </div>

      <form
        class="contact-form"
        @submit.prevent="$emit('submit')"
      >
        <div class="field-grid">
          <label>
            {{ labels.contactNameLabel }} *
            <input
              :value="form.name"
              type="text"
              autocomplete="name"
              required
              @input="updateForm('name', $event.target.value)"
            >
          </label>
          <label>
            Email *
            <input
              :value="form.email"
              type="email"
              autocomplete="email"
              required
              @input="updateForm('email', $event.target.value)"
            >
          </label>
        </div>

        <label>
          {{ labels.contactPhoneLabel }}
          <input
            :value="form.phone"
            type="tel"
            autocomplete="tel"
            placeholder="0770 898 767"
            @input="updateForm('phone', $event.target.value)"
          >
        </label>

        <label>
          {{ labels.contactMessageLabel }} *
          <textarea
            :value="form.message"
            rows="6"
            :placeholder="labels.contactMessagePlaceholder"
            required
            @input="updateForm('message', $event.target.value)"
          />
        </label>

        <button
          type="submit"
          class="primary-btn"
          :disabled="submitting"
        >
          {{ submitting ? labels.submitting : labels.contactSubmit }}
        </button>

        <p
          v-if="success"
          class="success-message"
        >
          {{ success }}
        </p>

        <p
          v-if="error"
          class="error-message"
        >
          {{ error }}
        </p>
      </form>
    </div>
  </section>
</template>

<script setup>
const emit = defineEmits(['submit', 'update:form'])

const props = defineProps({
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
  submitting: {
    type: Boolean,
    default: false,
  },
  success: {
    type: String,
    default: '',
  },
})

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
