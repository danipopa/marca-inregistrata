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

      <div
        class="currency-tabs"
        role="tablist"
        :aria-label="labels.currencyLabel"
      >
        <button
          v-for="currency in currencies"
          :key="currency.code"
          type="button"
          role="tab"
          :aria-selected="selectedCurrency === currency.code"
          :class="{ active: selectedCurrency === currency.code }"
          @click="$emit('update:selectedCurrency', currency.code)"
        >
          {{ currency.label }}
        </button>
      </div>

      <div class="price-grid renewal-plans">
        <article
          v-for="plan in plans"
          :key="plan.code"
          class="price-card renewal-card"
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
  selectedProductCode: {
    type: String,
    required: true,
  },
  selectedCurrency: {
    type: String,
    required: true,
  },
})
</script>

<style scoped>
.renewal-section,
.renewal-section :deep(*) {
  font-family: 'Montserrat', sans-serif;
}
</style>
