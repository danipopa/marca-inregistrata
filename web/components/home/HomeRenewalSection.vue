<template>
  <section
    id="reinnoire"
    class="renewal-section"
  >
    <div class="wrap renewal-layout">
      <div class="renewal-copy">
        <p class="eyebrow">
          {{ labels.renewalEyebrow }}
        </p>
        <h2>{{ labels.renewalTitle }}</h2>
        <p class="muted">
          {{ labels.renewalCopy }}
        </p>
        <div class="renewal-benefits">
          <strong>{{ labels.renewalAdvantagesTitle }}</strong>
          <ul>
            <li
              v-for="benefit in labels.renewalBenefits"
              :key="benefit"
            >
              {{ benefit }}
            </li>
          </ul>
        </div>
      </div>

      <div class="renewal-plans">
        <article
          v-for="plan in plans"
          :key="plan.code"
          class="price-card renewal-card"
          :class="{ selected: selectedProductCode === plan.code }"
        >
          <div class="price-card__top">
            <span class="country-pill">{{ plan.region }}</span>
            <h3>{{ plan.title }}</h3>
            <p v-if="plan.note">
              {{ plan.note }}
            </p>
          </div>
          <div class="price">
            <span>{{ plan.price }}</span>
            <small>{{ plan.tax }}</small>
          </div>
          <ul>
            <li
              v-for="item in plan.items"
              :key="item"
            >
              {{ item }}
            </li>
          </ul>
          <a
            href="#formular"
            class="register-btn"
            @click.prevent="$emit('openOrderForm', plan.code)"
          >{{ labels.buy }}</a>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
defineEmits(['openOrderForm'])

defineProps({
  labels: {
    type: Object,
    required: true,
  },
  plans: {
    type: Array,
    required: true,
  },
  selectedProductCode: {
    type: String,
    required: true,
  },
})
</script>
