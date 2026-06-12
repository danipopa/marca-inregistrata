import { computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import en from '../i18n/locales/en'
import ro from '../i18n/locales/ro'

const languages = [
  { code: 'ro', label: 'RO' },
  { code: 'en', label: 'EN' },
]
const messages = { en, ro }

function namespaceMessages(locale, namespace) {
  if (!namespace) return messages[locale] || messages.ro
  return namespace.split('.').reduce((value, key) => value?.[key], messages[locale]) || {}
}

export function usePreferredLanguage(namespace = '') {
  const { locale, setLocale } = useI18n()

  onMounted(() => {
    const storedLanguage = window.localStorage.getItem('preferred-language')
    if (storedLanguage && messages[storedLanguage] && storedLanguage !== locale.value) {
      setLocale(storedLanguage)
    }
  })

  watch(locale, (language) => {
    if (typeof window === 'undefined') return
    window.localStorage.setItem('preferred-language', language)
  })

  const selectedLanguage = computed(() => locale.value)
  const t = computed(() => namespaceMessages(locale.value, namespace))
  const browserLocale = computed(() => locale.value === 'ro' ? 'ro-RO' : 'en-US')

  function setLanguage(code) {
    if (messages[code]) setLocale(code)
  }

  return {
    languages,
    locale: browserLocale,
    selectedLanguage,
    setLanguage,
    t,
  }
}
