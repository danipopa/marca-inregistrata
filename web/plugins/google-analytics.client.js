import { defineNuxtPlugin, useRoute, useRuntimeConfig } from '#imports'
import { analyticsConsent, analyticsProvider, createGoogleAnalytics } from '../utils/analytics'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig().public
  const route = useRoute()
  const active = analyticsProvider(config) === 'google'
  const tracker = createGoogleAnalytics({ measurementId: active ? config.googleAnalyticsId : '', debug: [true, 'true'].includes(config.googleAnalyticsDebug), browser: window })
  const pageView = () => tracker.pageView(route.path)
  nuxtApp.$router.beforeEach(() => {
    tracker.suspend()
  })
  nuxtApp.$router.afterEach(() => {
    tracker.syncConsent()
  })
  nuxtApp.hook('app:mounted', pageView)
  nuxtApp.hook('page:finish', pageView)
  function applyConsent() {
    tracker.syncConsent()
    // A loaded third-party script cannot be unloaded. Reload after withdrawal to discard it.
    if (tracker.initialized && !analyticsConsent(window)) {
      window.location.reload()
      return
    }
    pageView()
  }
  window.addEventListener('storage', (event) => {
    if (event.key === 'cookie-consent-proof' || event.key === null) applyConsent()
  })
  window.addEventListener('cookie-consent-updated', applyConsent)
  return { provide: { analytics: tracker } }
})
