import en from '~/i18n/locales/en'
import ro from '~/i18n/locales/ro'

export default defineI18nConfig(() => ({
  legacy: false,
  locale: 'ro',
  fallbackLocale: 'ro',
  messages: {
    en,
    ro,
  },
}))
