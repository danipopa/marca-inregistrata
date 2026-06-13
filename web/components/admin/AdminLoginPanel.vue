<template>
  <div
    v-if="hydrating"
    class="admin-login"
  >
    <p class="muted">
      Verifying session...
    </p>
  </div>

  <form
    v-else
    class="admin-login"
    @submit.prevent="$emit('submit')"
  >
    <div
      v-if="mfaChallenge"
      class="mfa-panel"
    >
      <strong>{{ mfaChallenge.mfa_setup_required ? 'Set up authenticator' : 'Authenticator code required' }}</strong>
      <p>
        {{ mfaChallenge.mfa_setup_required
          ? 'Add this setup key to your authenticator app, then enter the 6-digit code.'
          : 'Enter the 6-digit code from your authenticator app.' }}
      </p>
      <div
        v-if="mfaChallenge.mfa?.secret"
        class="mfa-secret"
      >
        <img
          v-if="qrCodeUrl"
          :src="qrCodeUrl"
          alt="Authenticator QR code"
        >
        <span>Setup key</span>
        <code>{{ mfaChallenge.mfa.secret }}</code>
      </div>
      <label>
        Authenticator code
        <input
          :value="form.otpCode"
          type="text"
          inputmode="numeric"
          pattern="[0-9]{6}"
          maxlength="6"
          placeholder="123456"
          required
          @input="updateField('otpCode', $event.target.value)"
        >
      </label>
    </div>

    <label v-if="!mfaChallenge">
      Email
      <input
        :value="form.email"
        type="email"
        placeholder="admin@example.com"
        required
        @input="updateField('email', $event.target.value)"
      >
    </label>
    <label v-if="!mfaChallenge">
      Password
      <input
        :value="form.password"
        type="password"
        placeholder="Minimum 8 characters"
        required
        @input="updateField('password', $event.target.value)"
      >
    </label>
    <button
      class="primary-btn"
      type="submit"
      :disabled="loading"
    >
      {{ loading ? 'Signing in...' : (mfaChallenge ? 'Verify code' : 'Sign in') }}
    </button>

    <button
      v-if="!mfaChallenge"
      class="ghost-btn reset-password-btn"
      type="button"
      @click="$emit('reset-password')"
    >
      Forgot password?
    </button>
  </form>
</template>

<script setup>
import { ref, watch } from 'vue'
import QRCode from 'qrcode'

const emit = defineEmits(['reset-password', 'submit', 'update:form'])

const props = defineProps({
  form: {
    type: Object,
    required: true,
  },
  hydrating: {
    type: Boolean,
    default: false,
  },
  loading: {
    type: Boolean,
    default: false,
  },
  mfaChallenge: {
    type: Object,
    default: null,
  },
})

const qrCodeUrl = ref('')

watch(
  () => props.mfaChallenge?.mfa?.provisioning_uri,
  async (provisioningUri) => {
    qrCodeUrl.value = ''
    if (!provisioningUri) return

    qrCodeUrl.value = await QRCode.toDataURL(provisioningUri, {
      margin: 1,
      width: 192,
    })
  },
  { immediate: true },
)

function updateField(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>

<style scoped>
.reset-password-btn {
  border-color: var(--line, #ded8cf);
  background: #fff;
  color: var(--ink, #1f1d1a);
  cursor: pointer;
  font-weight: 700;
}
</style>
