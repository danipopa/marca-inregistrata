<template>
  <LegalDocumentPage
    content-key="terms_content"
    :fallback-content="t.termsFallback"
    :labels="t"
    :languages="languages"
    :selected-language="selectedLanguage"
    @update:selected-language="setLanguage"
  />
</template>

<script setup>
const {
  languages,
  selectedLanguage,
  setLanguage,
  t,
} = usePreferredLanguage('legal')

useHead(() => ({
  title: t.value.termsTitle,
}))
</script>
