<template>
  <section
    class="checkout-billing"
    :aria-label="labels.billingTitle"
  >
    <h2>{{ labels.billingTitle }}</h2>
    <p
      v-if="loading"
      role="status"
    >
      {{ checkoutLabels.loadingBilling }}
    </p>
    <template v-else-if="loadError">
      <p role="alert">
        {{ loadError }}
      </p>
      <button
        type="button"
        class="primary-btn"
        @click="loadProfile"
      >
        {{ checkoutLabels.retryBilling }}
      </button>
    </template>
    <form
      v-else-if="editing"
      ref="formElement"
      @submit.prevent="save"
    >
      <p>{{ checkoutLabels.billingCopy }}</p>
      <fieldset :disabled="saving || disabled">
        <AccountBillingFields
          :form="form"
          :labels="labels"
          :field-labels="fieldLabels"
          @update:form="form = $event"
        />
        <button
          type="submit"
          class="primary-btn"
        >
          {{ saving ? labels.saving : labels.saveBilling }}
        </button>
      </fieldset>
      <p
        v-if="error"
        role="alert"
      >
        {{ error }}
      </p>
    </form>
    <div v-else>
      <p>{{ profile.owner_name }}<br>{{ profile.address }}<br>{{ profile.phone }}</p>
      <p v-if="profile.tax_id">
        {{ fieldLabels.taxId }}: {{ profile.tax_id }}
      </p>
      <button
        type="button"
        class="ghost-btn"
        :disabled="disabled"
        @click="editing = true"
      >
        {{ labels.editBilling }}
      </button>
    </div>
    <p
      v-if="message"
      role="status"
    >
      {{ message }}
    </p>
  </section>
</template>

<script setup>
import { computed, nextTick, onMounted, ref } from 'vue'

const props = defineProps({
  checkoutLabels: { type: Object, required: true },
  disabled: { type: Boolean, default: false },
})
const { t: labels } = usePreferredLanguage('account')
const config = useRuntimeConfig()
const { authHeaders, authToken, persistSession } = useAuthSession()
const loading = ref(true)
const saving = ref(false)
const editing = ref(false)
const error = ref('')
const loadError = ref('')
const message = ref('')
const profile = ref({})
const form = ref({ phone: '', ownerType: 'Societate', taxId: '', ownerName: '', address: '' })
const formElement = ref(null)
const fieldLabels = computed(() => {
  const prefix = form.value.ownerType === 'Persoana fizica' ? 'person' : 'company'
  return Object.fromEntries(['taxId', 'ownerName', 'address'].flatMap(field => [
    [field, labels.value[`${prefix}${field[0].toUpperCase()}${field.slice(1)}`]],
    [`${field}Placeholder`, labels.value[`${prefix}${field[0].toUpperCase()}${field.slice(1)}Placeholder`]],
  ]))
})

async function loadProfile() {
  loading.value = true
  loadError.value = ''
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account`, { headers: authHeaders() })
    const payload = await response.json()
    if (!response.ok) throw new Error(payload.message || props.checkoutLabels.billingError)
    profile.value = payload.account.billing_profile
    form.value = {
      phone: profile.value.phone || '', ownerType: profile.value.owner_type || 'Societate',
      taxId: profile.value.tax_id || '', ownerName: profile.value.owner_name || '', address: profile.value.address || '',
    }
    editing.value = !profile.value.complete
  }
  catch (cause) {
    loadError.value = cause.message || props.checkoutLabels.billingError
  }
  finally {
    loading.value = false
  }
}

async function save() {
  if (loading.value || loadError.value || saving.value) return false
  if (!editing.value) return true
  message.value = ''
  error.value = ''
  await nextTick()
  if (!formElement.value?.reportValidity()) return false
  saving.value = true
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/account`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', ...authHeaders() },
      body: JSON.stringify({ account: {
        phone: form.value.phone.trim(), owner_type: form.value.ownerType,
        tax_id: form.value.taxId.trim(), owner_name: form.value.ownerName.trim(), address: form.value.address.trim(),
      } }),
    })
    const payload = await response.json()
    if (!response.ok) throw new Error(payload.message || props.checkoutLabels.billingError)
    persistSession(authToken.value, payload.user)
    profile.value = payload.account.billing_profile
    if (!profile.value.complete) throw new Error(props.checkoutLabels.checkoutBillingRequired)
    editing.value = false
    message.value = labels.value.billingSaved
    return true
  }
  catch (cause) {
    error.value = cause.message || props.checkoutLabels.billingError
    return false
  }
  finally {
    saving.value = false
  }
}

defineExpose({ save })
onMounted(loadProfile)
</script>

<style scoped>
.checkout-billing { border: 1px solid var(--line, #ded8cf); border-radius: 16px; padding: 24px; background: #fff; }
h2 { margin-top: 0; font-size: 1.25rem; }
p { line-height: 1.6; overflow-wrap: anywhere; }
fieldset { border: 0; padding: 0; margin: 0; min-width: 0; }
button { margin-top: 16px; padding: 12px 18px; border: 1px solid var(--brand, #013ebe); border-radius: 8px; font: inherit; cursor: pointer; }
.primary-btn { background: var(--brand, #013ebe); color: #fff; }
.ghost-btn { background: #fff; color: var(--brand, #013ebe); }
button:disabled { opacity: .6; cursor: wait; }
[role="alert"] { color: #b42318; }
</style>
