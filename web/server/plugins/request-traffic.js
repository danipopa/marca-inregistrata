import { defineNitroPlugin, useRuntimeConfig } from 'nitropack/runtime'
import { getRequestURL, getResponseStatus, getResponseHeader, setHeader } from 'h3'

export default defineNitroPlugin((nitroApp) => {
  nitroApp.hooks.hook('request', (event) => {
    event.context.trafficStarted = performance.now()
    // Nuxt payload endpoints are also excluded from indexing.
    const path = getRequestURL(event).pathname
    if (!['/', '/termeni-si-conditii', '/politica-de-confidentialitate', '/robots.txt', '/sitemap.xml'].includes(path)
      || ![true, 'true'].includes(useRuntimeConfig(event).public.siteIndexable)) {
      setHeader(event, 'X-Robots-Tag', 'noindex, follow')
    }
  })
  nitroApp.hooks.hook('afterResponse', (event) => {
    const path = getRequestURL(event).pathname
    const allowed = ['/', '/order', '/checkout', '/account', '/admin', '/password-reset', '/termeni-si-conditii', '/politica-de-confidentialitate', '/robots.txt', '/sitemap.xml']
    console.info(JSON.stringify({
      event: 'web_request', method: event.method,
      path: allowed.includes(path) ? path : path.startsWith('/_nuxt/') ? '/_nuxt/*' : '(other)',
      status: getResponseStatus(event),
      duration_ms: Math.round(performance.now() - event.context.trafficStarted),
      content_length: getResponseHeader(event, 'content-length') || null,
    }))
  })
})
