<template>
  <NuxtLink
    v-if="count"
    class="cart-nav-link"
    to="/checkout"
    :aria-label="`${label}: ${count}`"
  >
    <span
      class="cart-nav-icon"
      aria-hidden="true"
    />
    <span class="cart-nav-count">{{ count }}</span>
  </NuxtLink>
</template>

<script setup>
defineProps({
  count: {
    type: Number,
    default: 0,
  },
  label: {
    type: String,
    required: true,
  },
})
</script>

<style scoped>
.cart-nav-link {
  position: relative;
  display: inline-grid;
  place-items: center;
  width: 38px;
  height: 32px;
  border: 1px solid var(--gold, #00add9);
  background: #f4fbfd;
  color: #126175;
  text-decoration: none;
}

.cart-nav-icon {
  position: relative;
  width: 18px;
  height: 13px;
  border: 2px solid currentColor;
  border-top: 0;
}

.cart-nav-icon::before {
  content: "";
  position: absolute;
  left: -3px;
  top: -5px;
  width: 8px;
  height: 2px;
  background: currentColor;
  transform: rotate(-18deg);
  transform-origin: right center;
}

.cart-nav-icon::after {
  content: "";
  position: absolute;
  left: 2px;
  right: 2px;
  bottom: -6px;
  height: 4px;
  border-right: 2px solid currentColor;
  border-left: 2px solid currentColor;
}

.cart-nav-count {
  position: absolute;
  top: -8px;
  right: -8px;
  display: grid;
  place-items: center;
  min-width: 20px;
  height: 20px;
  border: 2px solid #fff;
  background: #2b2926;
  color: #fff;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-size: 11px;
  font-weight: 700;
  line-height: 1;
  padding: 0 5px;
}
</style>
