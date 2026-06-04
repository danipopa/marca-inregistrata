export default defineNuxtConfig({
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
})
