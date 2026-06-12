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
