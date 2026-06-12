<template>
  <LegalDocumentPage
    content-key="privacy_policy_content"
    :fallback-content="t.privacyFallback"
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
  title: t.value.privacyTitle,
}))
</script>
