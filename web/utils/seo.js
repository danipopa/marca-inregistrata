export const INDEXABLE_PATHS = ['/', '/termeni-si-conditii', '/politica-de-confidentialitate']
export function isSiteIndexable(value) {
  return value === true || value === 'true'
}
export function siteOrigin(value) {
  try {
    const url = new URL(value)
    if (['https:', 'http:'].includes(url.protocol)) return url.origin
  }
  catch { /* Use the production canonical origin if misconfigured. */ }
  return 'https://inregistrare-marca.com'
}
