<template>
  <header class="admin-header">
    <div class="wrap admin-header__inner">
      <NuxtLink
        class="brand"
        to="/"
        :aria-label="brandName"
      >
        <span
          class="brand__logo"
          :style="{ '--fallback-logo-image': `url(${logoUrl})` }"
          role="img"
          :aria-label="brandName"
        />
        <small>ADMIN</small>
      </NuxtLink>

      <nav class="admin-nav">
        <NuxtLink to="/">
          Site
        </NuxtLink>
        <NuxtLink to="/account">
          Account
        </NuxtLink>
      </nav>
    </div>
  </header>
</template>

<script setup>
import logoUrl from '../../assets/images/LOGO_SANDU-removebg-preview.png'

defineProps({
  brandName: {
    type: String,
    required: true,
  },
})
</script>
