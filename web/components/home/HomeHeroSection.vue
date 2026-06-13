<template>
  <section
    class="hero"
    :style="{ '--fallback-hero-image': `url(${heroImageUrl})` }"
  >
    <div class="wrap hero__grid">
      <div class="hero__copy">
        <p class="eyebrow">
          {{ labels.heroEyebrow }}
        </p>
        <h1>{{ labels.heroTitle }}</h1>
        <p class="lead">
          {{ labels.heroLead }}
        </p>
        <div class="hero__actions">
          <a
            class="primary-btn"
            href="#preturi"
          >{{ labels.heroPackages }}</a>
          <a
            class="outline-light-btn"
            href="/account"
          >{{ labels.heroAccount }}</a>
          <a
            class="text-link"
            href="/order"
            @click.prevent="$emit('openOrderForm')"
          >{{ labels.heroForm }}</a>
        </div>
      </div>

      <aside
        class="secure-panel"
        :aria-label="labels.secureTitle"
      >
        <div class="secure-panel__icon">
          SSL
        </div>
        <div>
          <strong>{{ labels.secureTitle }}</strong>
          <span>{{ labels.secureCopy }}</span>
        </div>
      </aside>
    </div>
  </section>
</template>

<script setup>
defineEmits(['openOrderForm'])

defineProps({
  heroImageUrl: {
    type: String,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
})
</script>
