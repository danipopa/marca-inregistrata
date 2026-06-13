<template>
  <div class="auth-shell">
    <p
      v-if="hydrating"
      class="muted"
    >
      {{ labels.loading }}
    </p>

    <form
      v-else
      class="account-form"
      @submit.prevent="$emit('submit')"
    >
      <div class="auth-mode">
        <button
          type="button"
          :class="{ active: mode === 'login' }"
          :disabled="mfaChallenge !== null"
          @click="$emit('update:mode', 'login')"
        >
          {{ labels.login }}
        </button>
        <button
          type="button"
          :class="{ active: mode === 'register' }"
          :disabled="mfaChallenge !== null"
          @click="$emit('update:mode', 'register')"
        >
          {{ labels.register }}
        </button>
      </div>

      <div
        v-if="mfaChallenge"
        class="mfa-panel"
      >
        <strong>{{ mfaChallenge.mfa_setup_required ? labels.mfaSetupTitle : labels.mfaVerifyTitle }}</strong>
        <p>{{ mfaChallenge.mfa_setup_required ? labels.mfaSetupCopy : labels.mfaVerifyCopy }}</p>

        <div
          v-if="mfaChallenge.mfa?.secret"
          class="mfa-secret"
        >
          <img
            v-if="qrCodeUrl"
            :src="qrCodeUrl"
            :alt="labels.mfaQrAlt"
          >
          <span>{{ labels.mfaSetupKey }}</span>
          <code>{{ mfaChallenge.mfa.secret }}</code>
        </div>

        <label>
          {{ labels.mfaCode }}
          <input
            :value="form.otpCode"
            type="text"
            inputmode="numeric"
            pattern="[0-9]{6}"
            maxlength="6"
            :placeholder="labels.mfaCodePlaceholder"
            required
            @input="$emit('update:form', { ...form, otpCode: $event.target.value })"
          >
        </label>
      </div>

      <label v-if="!mfaChallenge">
        {{ labels.email }}
        <input
          :value="form.email"
          type="email"
          placeholder="email@companie.ro"
          required
          @input="$emit('update:form', { ...form, email: $event.target.value })"
        >
      </label>

      <label v-if="!mfaChallenge">
        {{ labels.password }}
        <input
          :value="form.password"
          type="password"
          :placeholder="labels.passwordPlaceholder"
          required
          @input="$emit('update:form', { ...form, password: $event.target.value })"
        >
      </label>

      <button
        class="primary-btn"
        type="submit"
        :disabled="authenticating"
      >
        {{ authenticating ? labels.loading : (mfaChallenge ? labels.mfaVerifyButton : submitLabel) }}
      </button>

      <button
        v-if="!mfaChallenge && mode === 'login'"
        class="ghost-btn reset-password-btn"
        type="button"
        @click="$emit('reset-password')"
      >
        {{ labels.resetPassword }}
      </button>

      <p class="muted">
        {{ mfaChallenge ? labels.mfaNote : labels.authNote }}
      </p>
    </form>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import QRCode from 'qrcode'

defineEmits(['reset-password', 'submit', 'update:form', 'update:mode'])

const props = defineProps({
  authenticating: {
    type: Boolean,
    default: false,
  },
  form: {
    type: Object,
    required: true,
  },
  hydrating: {
    type: Boolean,
    default: false,
  },
  labels: {
    type: Object,
    required: true,
  },
  mfaChallenge: {
    type: Object,
    default: null,
  },
  mode: {
    type: String,
    required: true,
  },
  submitLabel: {
    type: String,
    required: true,
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
