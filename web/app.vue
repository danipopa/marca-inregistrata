<template>
  <NuxtPage />
  <aside
    v-if="showCookieBanner"
    class="cookie-banner"
    aria-label="Politica cookies"
  >
    <div class="cookie-copy">
      <p>
        Acest site foloseste cookies pentru functionare, cos, autentificare si imbunatatirea experientei. Afla mai multe despre politica noastra de cookies.
      </p>
      <details>
        <summary>Detalii</summary>
        <p>
          Dovada acordului este salvata cu versiunea politicii, data acceptarii, identificatorul consimtamantului, adresa IP si user agent. Nu vindem date personale.
        </p>
      </details>
      <p
        v-if="cookieError"
        class="cookie-error"
      >
        {{ cookieError }}
      </p>
    </div>
    <div class="cookie-actions">
      <button
        class="cookie-reject-btn"
        type="button"
        :disabled="savingCookieConsent"
        @click="saveCookiePolicy(false)"
      >
        {{ savingCookieConsent ? 'Se salveaza...' : 'Nu, doar cookies esentiale' }}
      </button>
      <button
        class="cookie-accept-btn"
        type="button"
        :disabled="savingCookieConsent"
        @click="saveCookiePolicy(true)"
      >
        {{ savingCookieConsent ? 'Se salveaza...' : 'Accept toate cookies' }}
      </button>
    </div>
  </aside>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const COOKIE_POLICY_VERSION = '2026-05-28'
const COOKIE_CONSENT_KEY = 'cookie-consent-proof'

const config = useRuntimeConfig()
const showCookieBanner = ref(false)
const savingCookieConsent = ref(false)
const cookieError = ref('')

function createConsentId() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID()

  return `consent-${Date.now()}-${Math.random().toString(36).slice(2)}`
}

function storedConsent() {
  try {
    return JSON.parse(window.localStorage.getItem(COOKIE_CONSENT_KEY) || '{}')
  }
  catch {
    return {}
  }
}

async function saveCookiePolicy(accepted) {
  cookieError.value = ''
  savingCookieConsent.value = true

  const existingConsent = storedConsent()
  const consentId = existingConsent.consent_id || createConsentId()

  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/cookie_consents`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        cookie_consent: {
          consent_id: consentId,
          version: COOKIE_POLICY_VERSION,
          accepted,
        },
      }),
    })
    const payload = await response.json().catch(() => ({}))

    if (!response.ok) {
      throw new Error(payload.message || 'Nu am putut salva acordul pentru cookies.')
    }

    window.localStorage.setItem(COOKIE_CONSENT_KEY, JSON.stringify({
      consent_id: payload.consent?.consent_id || consentId,
      version: COOKIE_POLICY_VERSION,
      accepted,
      accepted_at: payload.consent?.accepted_at || new Date().toISOString(),
    }))
    showCookieBanner.value = false
  }
  catch (error) {
    cookieError.value = error instanceof Error ? error.message : 'Nu am putut salva acordul pentru cookies.'
  }
  finally {
    savingCookieConsent.value = false
  }
}

onMounted(() => {
  const consent = storedConsent()
  showCookieBanner.value = !(typeof consent.accepted === 'boolean' && consent.version === COOKIE_POLICY_VERSION)
})
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&display=swap');

.cookie-banner {
  position: fixed;
  right: 26px;
  bottom: 18px;
  left: 26px;
  z-index: 50;
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 24px;
  align-items: center;
  width: auto;
  border: 1px solid rgba(1, 62, 190, 0.12);
  background: #fff;
  color: #1f1d1a;
  padding: 14px 18px;
  box-shadow: 0 8px 28px rgba(31, 29, 26, 0.2);
  font-family: 'Montserrat', sans-serif;
}

.cookie-copy {
  min-width: 0;
}

.cookie-banner p {
  margin: 0;
  color: #4d4942;
  font-size: 14px;
  line-height: 1.55;
}

.cookie-banner details {
  margin-top: 6px;
  font-size: 13px;
}

.cookie-banner summary {
  color: #013ebe;
  cursor: pointer;
  font-weight: 700;
}

.cookie-error {
  margin-top: 10px !important;
  color: #8f3d22 !important;
  font-weight: 700;
}

.cookie-actions {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: flex-end;
}

.cookie-actions button {
  min-height: 44px;
  border: 1px solid #00add9;
  background: #fff;
  color: #013ebe;
  cursor: pointer;
  padding: 0 22px;
  font: inherit;
  font-size: 14px;
  font-weight: 700;
  white-space: nowrap;
}

.cookie-actions .cookie-accept-btn {
  background: #00add9;
  color: #fff;
}

.cookie-actions button:disabled {
  cursor: wait;
  opacity: 0.7;
}

@media (max-width: 720px) {
  .cookie-banner {
    grid-template-columns: 1fr;
    right: 14px;
    bottom: 14px;
    left: 14px;
    gap: 14px;
  }

  .cookie-actions {
    display: grid;
    grid-template-columns: 1fr;
  }

  .cookie-actions button {
    width: 100%;
    white-space: normal;
  }
}
</style>
