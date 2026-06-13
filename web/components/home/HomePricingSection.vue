<template>
  <section
    id="preturi"
    class="pricing-section"
  >
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow">
          OSIM / EUIPO
        </p>
        <h2>{{ labels.pricingTitle }}</h2>
      </div>

      <div
        class="currency-tabs"
        role="tablist"
        :aria-label="labels.currencyLabel"
      >
        <button
          v-for="currency in currencies"
          :key="currency.code"
          type="button"
          :class="{ active: selectedCurrency === currency.code }"
          @click="$emit('update:selectedCurrency', currency.code)"
        >
          {{ currency.label }}
        </button>
      </div>

      <div class="price-grid">
        <article
          v-for="plan in plans"
          :key="plan.code"
          class="price-card"
          :class="{ selected: selectedProductCode === plan.code }"
        >
          <div class="price-card__top">
            <span class="country-pill">{{ plan.region }}</span>
            <h3>{{ plan.title }}</h3>
            <img
              v-if="plan.image"
              class="price-card__image"
              :src="plan.image"
              :alt="plan.title"
            >
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
            href="/order"
            class="register-btn"
            @click.prevent="$emit('openOrderForm', plan.code)"
          >{{ labels.continueWizard }}</a>
          <p class="card-foot">
            {{ labels.secureTitle }}
          </p>
        </article>
      </div>

      <p
        v-if="!plans.length"
        class="empty-products"
      >
        {{ labels.emptyProducts }}
      </p>
    </div>
  </section>
</template>

<script setup>
defineEmits(['openOrderForm', 'update:selectedCurrency'])

defineProps({
  currencies: {
    type: Array,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  plans: {
    type: Array,
    required: true,
  },
  selectedCurrency: {
    type: String,
    required: true,
  },
  selectedProductCode: {
    type: String,
    required: true,
  },
})
</script>
