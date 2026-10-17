import { defineNuxtPlugin, useHead, useRoute, useRuntimeConfig } from '#imports'
import { unref } from 'vue'
import { INDEXABLE_PATHS, isSiteIndexable, siteOrigin } from '../utils/seo'

export default defineNuxtPlugin((nuxtApp) => {
  const route = useRoute()
  const config = useRuntimeConfig()
  const origin = siteOrigin(config.public.siteUrl)
  useHead(() => {
    const language = unref(nuxtApp.$i18n.locale) === 'en' ? 'en' : 'ro'
    const isEnglish = language === 'en'
    const indexable = isSiteIndexable(config.public.siteIndexable) && INDEXABLE_PATHS.includes(route.path)
    const title = isEnglish ? 'Trademark registration at OSIM, EUIPO and WIPO' : 'Înregistrare marcă la OSIM, EUIPO și WIPO'
    const description = isEnglish
      ? 'Trademark registration, verification, renewal and monitoring. Discover OSIM, EUIPO and WIPO services from SANDU și Asociații IP Attorney.'
      : 'Înregistrare, verificare, reînnoire și monitorizare mărci. Descoperiți serviciile OSIM, EUIPO și WIPO oferite de SANDU și Asociații IP Attorney.'
    const descriptions = {
      '/termeni-si-conditii': isEnglish ? 'Terms and conditions for trademark registration, verification, renewal and monitoring services.' : 'Termeni și condiții pentru serviciile de înregistrare, verificare, reînnoire și monitorizare a mărcilor.',
      '/politica-de-confidentialitate': isEnglish ? 'Information about personal data, cookies and privacy when using our trademark services.' : 'Informații despre datele personale, cookies și confidențialitate în utilizarea serviciilor noastre pentru mărci.',
    }
    const canonical = `${origin}${route.path}`
    const pageDescription = descriptions[route.path] || description
    return {
      htmlAttrs: { lang: language },
      link: [{ key: 'canonical', rel: 'canonical', href: canonical }],
      meta: [
        { name: 'description', content: pageDescription },
        { name: 'robots', content: indexable ? 'index, follow' : 'noindex, follow' },
        { property: 'og:type', content: 'website' },
        { property: 'og:site_name', content: 'SANDU și Asociații IP Attorney' },
        { property: 'og:title', content: descriptions[route.path] ? (isEnglish ? 'Trademark services — information' : 'Servicii mărci — informații') : title },
        { property: 'og:description', content: pageDescription },
        { property: 'og:url', content: canonical },
        { property: 'og:locale', content: isEnglish ? 'en_US' : 'ro_RO' },
        { name: 'twitter:card', content: 'summary' },
      ],
      script: route.path === '/'
        ? [{ key: 'organization-schema', type: 'application/ld+json', innerHTML: JSON.stringify({
            '@context': 'https://schema.org',
            '@graph': [
              { '@type': 'Organization', '@id': `${origin}/#organization`, 'name': 'SANDU și Asociații IP Attorney', 'url': origin },
              { '@type': 'WebSite', '@id': `${origin}/#website`, 'url': origin, 'name': 'Înregistrare marcă', 'inLanguage': 'ro', 'publisher': { '@id': `${origin}/#organization` } },
            ],
          }).replace(/</g, '\u003c') }]
        : [],
    }
  })
})
