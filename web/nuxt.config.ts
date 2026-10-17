export default defineNuxtConfig({
  modules: ['@nuxtjs/i18n'],
  devtools: { enabled: true },
  app: {
    head: {
      title: 'Inregistrare marci la OSIM, EUIPO, WIPO',
      link: [
        { rel: 'icon', href: '/favicon.ico' },
      ],
    },
  },
  runtimeConfig: {
    public: {
      analyticsProvider: process.env.NUXT_PUBLIC_ANALYTICS_PROVIDER || 'auto',
      googleAnalyticsId: process.env.NUXT_PUBLIC_GOOGLE_ANALYTICS_ID || '',
      googleAnalyticsDebug: process.env.NUXT_PUBLIC_GOOGLE_ANALYTICS_DEBUG || 'false',
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL || 'https://inregistrare-marca.com',
      siteIndexable: process.env.NUXT_PUBLIC_SITE_INDEXABLE || 'false',
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3001',
      googleClientId: process.env.NUXT_PUBLIC_GOOGLE_CLIENT_ID ?? '',
    },
  },
  compatibilityDate: 'latest',
  i18n: {
    defaultLocale: 'ro',
    strategy: 'no_prefix',
    detectBrowserLanguage: false,
    locales: [
      { code: 'ro', name: 'Romana' },
      { code: 'en', name: 'English' },
    ],
    vueI18n: 'i18n.config.ts',
  },
})
