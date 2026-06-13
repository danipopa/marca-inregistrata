<template>
  <header class="main-header">
    <div class="wrap main-header__inner">
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
      </NuxtLink>

      <nav
        :aria-label="labels.quickServicesLabel"
        class="main-nav"
      >
        <NuxtLink to="/#preturi">
          {{ labels.quickRegistration }}
        </NuxtLink>
        <NuxtLink to="/#reinnoire">
          {{ labels.quickRenewal }}
        </NuxtLink>
        <NuxtLink to="/#monitorizare">
          {{ labels.quickMonitoring }}
        </NuxtLink>
        <NuxtLink
          v-if="showCheck"
          to="/#verificare"
        >
          {{ labels.quickCheck }}
        </NuxtLink>
        <NuxtLink
          v-if="showAccount"
          to="/account"
        >
          {{ labels.navAccount }}
        </NuxtLink>
        <LanguageSwitcher
          :label="labels.languageLabel"
          :languages="languages"
          :model-value="selectedLanguage"
          @update:model-value="$emit('update:selectedLanguage', $event)"
        />
        <CartNavLink
          v-if="showCart"
          :count="cartCount"
          :label="labels.cartNavLabel"
        />
      </nav>
    </div>
  </header>
</template>

<script setup>
import logoUrl from '../assets/images/LOGO_SANDU-removebg-preview.png'

defineProps({
  brandName: {
    type: String,
    default: 'SANDU si Asociatii IP Attorney',
  },
  cartCount: {
    type: Number,
    default: 0,
  },
  labels: {
    type: Object,
    required: true,
  },
  languages: {
    type: Array,
    required: true,
  },
  selectedLanguage: {
    type: String,
    required: true,
  },
  showAccount: {
    type: Boolean,
    default: false,
  },
  showCart: {
    type: Boolean,
    default: true,
  },
  showCheck: {
    type: Boolean,
    default: true,
  },
})

defineEmits(['update:selectedLanguage'])
</script>

<style scoped>
.main-header {
  background: #fff;
  border-bottom: 1px solid var(--line, #ded8cf);
}

.wrap {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
}

.main-header__inner {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: center;
  min-height: 78px;
}

.brand {
  display: inline-flex;
  align-items: center;
  text-decoration: none;
}

.brand__logo {
  display: block;
  width: 196px;
  height: 64px;
  background-image: var(--fallback-logo-image);
  background-position: left center;
  background-repeat: no-repeat;
  background-size: contain;
}

.main-nav {
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
  justify-content: flex-end;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 13px;
  font-weight: 700;
}

.main-nav a {
  color: inherit;
  text-decoration: none;
}

@media (max-width: 760px) {
  .main-header__inner {
    align-items: flex-start;
    flex-direction: column;
    padding: 14px 0;
  }

  .brand__logo {
    width: 176px;
    height: 58px;
  }

  .main-nav {
    justify-content: flex-start;
  }
}
</style>
