export default defineNuxtConfig({
  devtools: { enabled: true },
  compatibilityDate: 'latest',
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3001',
    },
  },
})
