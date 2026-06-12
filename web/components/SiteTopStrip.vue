<template>
  <div class="top-strip">
    <div class="wrap top-strip__inner">
      <div class="contact-line">
        <a href="tel:0770898767">0770 898 767</a>
        <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
        <a
          v-if="showOfficeEmail"
          href="mailto:office@sandusiasociatii.ro"
        >office@sandusiasociatii.ro</a>
      </div>
      <nav
        :aria-label="labels.mainNavigationLabel"
        class="quick-links"
      >
        <NuxtLink to="/#despre">
          {{ labels.navAbout }}
        </NuxtLink>
        <NuxtLink to="/account">
          {{ labels.navAccount }}
        </NuxtLink>
        <NuxtLink to="/#contact">
          {{ labels.navContact }}
        </NuxtLink>
      </nav>
    </div>
  </div>
</template>

<script setup>
defineProps({
  labels: {
    type: Object,
    required: true,
  },
  showOfficeEmail: {
    type: Boolean,
    default: false,
  },
})
</script>

<style scoped>
.top-strip {
  background: var(--brand, #013ebe);
  color: #f8f3ea;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 12px;
  letter-spacing: 0.02em;
}

.wrap {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
}

.top-strip__inner {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: center;
  min-height: 42px;
}

.contact-line,
.quick-links {
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
}

a {
  color: inherit;
  text-decoration: none;
}

@media (max-width: 760px) {
  .top-strip__inner {
    align-items: flex-start;
    flex-direction: column;
    padding: 14px 0;
  }
}
</style>
