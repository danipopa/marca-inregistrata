<template>
  <div class="password-reset-page">
    <SiteTopStrip :labels="homeLabels" />
    <SiteHeader
      :labels="homeLabels"
      :languages="languages"
      :selected-language="selectedLanguage"
      :show-account="true"
      :show-cart="false"
      :show-check="false"
      @update:selected-language="setLanguage"
    />

    <main class="password-reset-main">
      <section class="wrap password-reset-shell">
        <div class="password-reset-copy">
          <span>{{ accountLabels.resetPasswordEyebrow }}</span>
          <h1>
            {{ isResetMode ? accountLabels.resetPasswordTokenTitle : accountLabels.resetPasswordTitle }}
          </h1>
          <p>
            {{ isResetMode ? accountLabels.resetPasswordTokenCopy : accountLabels.resetPasswordCopy }}
          </p>
        </div>

        <form
          class="password-reset-form"
          @submit.prevent="submitReset"
        >
          <p
            v-if="message"
            class="success-message"
          >
            {{ message }}
          </p>
          <p
            v-if="error"
            class="error-message"
          >
            {{ error }}
          </p>

          <template v-if="!isResetMode">
            <label>
              {{ accountLabels.resetPasswordEmailLabel }}
              <input
                v-model="form.email"
                type="email"
                :placeholder="accountLabels.resetPasswordEmailPlaceholder"
                required
              >
            </label>
          </template>

          <template v-else>
            <label>
              {{ accountLabels.resetPasswordNewPasswordLabel }}
              <input
                v-model="form.password"
                type="password"
                :placeholder="accountLabels.resetPasswordNewPasswordPlaceholder"
                required
              >
            </label>
            <label>
              {{ accountLabels.resetPasswordConfirmPasswordLabel }}
              <input
                v-model="form.passwordConfirmation"
                type="password"
                :placeholder="accountLabels.resetPasswordConfirmPasswordPlaceholder"
                required
              >
            </label>
          </template>

          <div class="form-actions">
            <button
              class="primary-btn"
              type="submit"
              :disabled="submitting"
            >
              {{ submitting ? accountLabels.loading : (isResetMode ? accountLabels.resetPasswordSubmitNew : accountLabels.resetPasswordSubmit) }}
            </button>
            <NuxtLink
              class="ghost-btn"
              to="/account"
            >
              {{ accountLabels.backToLogin }}
            </NuxtLink>
          </div>
        </form>
      </section>
    </main>

    <SiteFooter
      :brand-name="brandName"
      :copyright-text="copyrightText"
      :footer-copy="homeLabels.footerCopy"
      :labels="homeLabels"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'

const config = useRuntimeConfig()
const route = useRoute()
const submitting = ref(false)
const message = ref('')
const error = ref('')
const form = reactive({
  email: '',
  token: '',
  password: '',
  passwordConfirmation: '',
})

const {
  languages,
  selectedLanguage,
  setLanguage,
  t,
} = usePreferredLanguage()

const homeLabels = computed(() => t.value.home)
const accountLabels = computed(() => t.value.account)
const brandName = 'SANDU și Asociații IP Attorney'
const copyrightText = computed(() => `© ${new Date().getFullYear()} ${brandName}`)
const isResetMode = computed(() => Boolean(route.query.token?.toString()))

useHead(() => ({
  title: accountLabels.value.resetPasswordMetaTitle,
}))

function syncFromRoute() {
  form.email = route.query.email?.toString() || form.email
  form.token = route.query.token?.toString() || ''
}

watch(
  () => [route.query.email, route.query.token],
  syncFromRoute,
  { immediate: true },
)

onMounted(syncFromRoute)

function apiError(payload, fallback) {
  if (payload?.message) return payload.message
  if (payload?.errors) {
    return Object.entries(payload.errors)
      .map(([field, messages]) => `${field} ${Array.isArray(messages) ? messages.join(', ') : messages}`)
      .join('; ') || fallback
  }

  return fallback
}

async function submitReset() {
  submitting.value = true
  message.value = ''
  error.value = ''

  try {
    if (!isResetMode.value) {
      const response = await fetch(`${config.public.apiBaseUrl}/api/v1/password_reset`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          password_reset: {
            email: form.email,
          },
        }),
      })
      const payload = await response.json().catch(() => ({}))

      if (!response.ok) {
        throw new Error(apiError(payload, accountLabels.value.resetPasswordRequestError))
      }

      message.value = payload.message || accountLabels.value.resetPasswordRequestSuccess
      return
    }

    if (form.password !== form.passwordConfirmation) {
      error.value = accountLabels.value.resetPasswordMismatch
      return
    }

    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/password_reset`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        password_reset: {
          token: form.token,
          password: form.password,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(apiError(payload, accountLabels.value.resetPasswordInvalid))
    }

    message.value = payload.message || accountLabels.value.resetPasswordSuccess
    form.password = ''
    form.passwordConfirmation = ''
  }
  catch (submitError) {
    error.value = submitError instanceof Error ? submitError.message : accountLabels.value.resetPasswordInvalid
  }
  finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.password-reset-main {
  background: linear-gradient(180deg, #fbf7f0 0%, #fff 100%);
  padding: 48px 0 72px;
}

.wrap {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
}

.password-reset-shell {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(360px, 460px);
  gap: 28px;
  align-items: start;
}

.password-reset-copy {
  padding-top: 8px;
}

.password-reset-copy span {
  display: inline-block;
  margin-bottom: 12px;
  color: var(--muted, #68635c);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.password-reset-copy h1 {
  margin: 0 0 16px;
  color: var(--ink, #1f1d1a);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: clamp(34px, 5vw, 58px);
  font-weight: 400;
  line-height: 1;
}

.password-reset-copy p {
  max-width: 50ch;
  margin: 0;
  color: var(--muted, #68635c);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 18px;
  line-height: 1.45;
}

.password-reset-form {
  display: grid;
  gap: 16px;
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  padding: 24px;
}

.password-reset-form label {
  display: grid;
  gap: 8px;
  color: var(--ink, #1f1d1a);
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 14px;
  font-weight: 700;
}

.password-reset-form input {
  width: 100%;
  min-height: 48px;
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  color: var(--ink, #1f1d1a);
  padding: 0 14px;
  font: inherit;
}

.form-actions {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
  margin-top: 6px;
}

.primary-btn,
.ghost-btn {
  min-height: 44px;
  border-radius: 0;
  border: 1px solid transparent;
  padding: 0 18px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.primary-btn {
  background: var(--brand, #00add9);
  color: #fff;
}

.ghost-btn {
  border-color: var(--line, #ded8cf);
  background: #fff;
  color: var(--ink, #1f1d1a);
}

.primary-btn:disabled {
  opacity: 0.72;
  cursor: progress;
}

.error-message,
.success-message {
  margin: 0;
  padding: 14px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.error-message {
  border: 1px solid #d7b7a9;
  background: #fff1eb;
  color: #8f3d22;
}

.success-message {
  border: 1px solid #c8d9bf;
  background: #f2f8ef;
  color: #3b6d2b;
}

@media (max-width: 900px) {
  .password-reset-shell {
    grid-template-columns: 1fr;
  }
}
</style>
