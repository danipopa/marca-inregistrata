import { useNuxtApp } from '#imports'

export function useAnalytics() {
  const nuxtApp = useNuxtApp()
  function trackEvent(name, input) {
    if (!import.meta.client) return false
    try {
      return nuxtApp.$analytics?.event(name, input) || false
    }
    catch { return false }
  }
  function trackPurchase(result) {
    if (!import.meta.client) return false
    try {
      return nuxtApp.$analytics?.purchase(result) || false
    }
    catch { return false }
  }
  return { trackEvent, trackPurchase }
}
