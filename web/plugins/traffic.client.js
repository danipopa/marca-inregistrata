import { defineNuxtPlugin, useRoute, useRuntimeConfig } from '#imports'
import { analyticsProvider } from '../utils/analytics'
import { ANALYTICS_CONSENT_VERSION, CONSENT_STORAGE_KEY, TRAFFIC_PATHS } from '../utils/traffic'

export default defineNuxtPlugin((nuxtApp) => {
  const route = useRoute()
  const config = useRuntimeConfig()
  if (analyticsProvider(config.public) !== 'first-party') return
  let previousPage = null

  function track() {
    try {
      const consent = JSON.parse(localStorage.getItem(CONSENT_STORAGE_KEY) || '{}')
      if (consent.accepted !== true || consent.version !== ANALYTICS_CONSENT_VERSION
        || navigator.doNotTrack === '1' || navigator.globalPrivacyControl === true) return
      if (!TRAFFIC_PATHS.includes(route.path)) return
      const page = route.fullPath.split('#')[0]
      if (previousPage === page) return
      previousPage = page
      const now = Date.now()
      let session = JSON.parse(sessionStorage.getItem('traffic-session') || '{}')
      if (!session.id || now - session.lastSeen > 30 * 60 * 1000) {
        session = { id: crypto.randomUUID?.() || `session-${now}-${Math.random().toString(36).slice(2)}` }
      }
      session.lastSeen = now
      sessionStorage.setItem('traffic-session', JSON.stringify(session))
      // Only the referring hostname leaves the browser; queries and fragments may contain secrets.
      let referrer = ''
      try {
        const url = new URL(document.referrer)
        if (url.hostname !== location.hostname) referrer = url.origin
      }
      catch { /* Direct visits have no referrer. */ }
      void fetch(`${config.public.apiBaseUrl}/api/v1/traffic_page_views`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'omit',
        keepalive: true,
        body: JSON.stringify({ page_view: {
          consent_id: consent.consent_id, session_id: session.id, path: route.path, referrer,
        } }),
      }).catch(() => {})
    }
    catch { /* Blocked storage or tracking must not break the site. */ }
  }

  nuxtApp.hook('app:mounted', track)
  nuxtApp.hook('page:finish', track)
  window.addEventListener('cookie-consent-updated', () => {
    previousPage = null
    try {
      sessionStorage.removeItem('traffic-session')
    }
    catch { /* Storage can be unavailable in restricted browsers. */ }
    track()
  })
})
