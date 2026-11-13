<template>
  <div class="billing-fields">
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
  </div>
</template>

<script setup>
const props = defineProps({
  form: { type: Object, required: true },
  labels: { type: Object, required: true },
  fieldLabels: { type: Object, required: true },
})
const emit = defineEmits(['update:form'])
function updateField(field, value) {
  emit('update:form', { ...props.form, [field]: value })
}
</script>

<style scoped>
.billing-fields, label { display: grid; gap: 10px; }
.billing-fields { gap: 18px; }
.field-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
input, select, textarea { box-sizing: border-box; width: 100%; padding: 12px; border: 1px solid var(--line, #ded8cf); border-radius: 8px; background: #fff; color: inherit; font: inherit; }
@media (max-width: 600px) { .field-grid { grid-template-columns: 1fr; } }
</style>
