<template>
  <div class="legal-page">
    <header class="legal-header">
      <div class="wrap legal-header__inner">
        <NuxtLink
          class="brand"
          to="/"
          :aria-label="brandName"
        >
          <img
            class="brand__logo"
            :src="transparentPixel"
            :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
            :alt="brandName"
          >
        </NuxtLink>
        <NuxtLink
          class="back-link"
          to="/"
        >
          Inapoi la site
        </NuxtLink>
      </div>
    </header>

    <main class="wrap legal-layout">
      <article class="legal-document">
        <template
          v-for="(block, index) in blocks"
          :key="`${block.type}-${index}`"
        >
          <h1 v-if="block.type === 'h1'">
            {{ block.text }}
          </h1>
          <h2 v-else-if="block.type === 'h2'">
            {{ block.text }}
          </h2>
          <h3 v-else-if="block.type === 'h3'">
            {{ block.text }}
          </h3>
          <ol v-else-if="block.type === 'ol'">
            <li
              v-for="item in block.items"
              :key="item"
            >
              {{ item }}
            </li>
          </ol>
          <ul v-else-if="block.type === 'ul'">
            <li
              v-for="item in block.items"
              :key="item"
            >
              {{ item }}
            </li>
          </ul>
          <p v-else>
            {{ block.text }}
          </p>
        </template>
      </article>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { legalBlocks } from '../utils/legalContent'
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'

const config = useRuntimeConfig()
const transparentPixel = 'data:image/gif;base64,R0lGODlhAQABAAAAACw='
const content = ref('# Termeni si conditii\n\nTextul termenilor si conditiilor se incarca.')
const brandName = ref('SANDU și Asociații IP Attorney')
const blocks = computed(() => legalBlocks(content.value))

onMounted(async () => {
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/site_theme`)
    const payload = await response.json().catch(() => ({}))

    if (response.ok && payload.theme?.terms_content) {
      content.value = payload.theme.terms_content
    }
    if (response.ok && payload.theme?.brand_name) {
      brandName.value = payload.theme.brand_name
    }
  }
  catch {
    // Keep the local fallback.
  }
})
</script>

<style scoped>
.legal-page {
  min-height: 100vh;
  background: var(--paper, #fff);
  color: var(--ink, #1f1d1a);
  font-family: var(--font-family, 'Montserrat', sans-serif);
}

.wrap {
  width: min(1040px, calc(100% - 32px));
  margin: 0 auto;
}

.legal-header {
  border-bottom: 1px solid var(--line, #ded8cf);
  background: #fff;
}

.legal-header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 18px 0;
}

.brand__logo {
  display: block;
  width: clamp(180px, 22vw, 257px);
  height: clamp(58px, 7vw, 83px);
  aspect-ratio: 257 / 83;
  background: var(--logo-image, var(--fallback-logo-image)) center / contain no-repeat;
}

.back-link {
  color: var(--brand, #013ebe);
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
}

.legal-layout {
  padding: clamp(38px, 7vw, 78px) 0;
}

.legal-document {
  max-width: 860px;
}

.legal-document h1 {
  margin: 0 0 28px;
  color: var(--brand, #013ebe);
  font-size: clamp(34px, 6vw, 58px);
  line-height: 1.05;
}

.legal-document h2 {
  margin: 34px 0 12px;
  color: var(--ink, #1f1d1a);
  font-size: 24px;
}

.legal-document h3 {
  margin: 24px 0 10px;
  font-size: 18px;
}

.legal-document p,
.legal-document li {
  color: var(--muted, #68635c);
  font-size: 16px;
  line-height: 1.75;
}

.legal-document ol,
.legal-document ul {
  padding-left: 22px;
}
</style>
