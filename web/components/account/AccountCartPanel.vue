<template>
  <section class="orders-panel">
    <div class="panel-head">
      <div>
        <p class="panel-kicker">
          {{ labels.cartKicker }}
        </p>
        <h2>{{ labels.cartTitle }}</h2>
      </div>
    </div>

    <p>{{ labels.cartCopy }}</p>

    <div
      v-if="items.length"
      class="account-cart-list"
    >
      <article
        v-for="item in items"
        :key="item.id"
        class="account-cart-item"
      >
        <div>
          <strong>{{ item.productTitle }}</strong>
          <span>{{ item.mark }} · {{ item.classes }} {{ labels.niceClasses }}</span>
          <small v-if="item.ownerChangeRequested">{{ labels.ownerChangeCartLabel }}</small>
          <small>{{ item.primaryClass }}</small>
        </div>
        <div class="account-cart-item__meta">
          <strong>{{ item.formattedTotal }}</strong>
          <button
            type="button"
            class="remove-order-btn"
            @click="$emit('removeItem', item.id)"
          >
            {{ labels.removeFromCart }}
          </button>
        </div>
      </article>
    </div>

    <p
      v-else
      class="muted empty-orders"
    >
      {{ labels.emptyCart }}
    </p>

    <div
      v-if="items.length"
      class="account-checkout-box"
    >
      <div class="checkout-summary">
        <span>{{ labels.cartTotal }}</span>
        <strong>{{ formattedTotal }}</strong>
        <small>{{ selectedPaymentDescription }}</small>
        <small>{{ checkoutStatus }}</small>
      </div>

      <div class="checkout-payment">
        <span>{{ labels.checkoutPaymentLabel }}</span>
        <div class="payment-options">
          <label>
            <input
              :checked="payment === 'card'"
              type="radio"
              value="card"
              @change="$emit('update:payment', 'card')"
            >
            {{ labels.cardPayment }}
          </label>
          <label>
            <input
              :checked="payment === 'paypal'"
              type="radio"
              value="paypal"
              @change="$emit('update:payment', 'paypal')"
            >
            {{ labels.paypalPayment }}
          </label>
          <label>
            <input
              :checked="payment === 'transfer'"
              type="radio"
              value="transfer"
              @change="$emit('update:payment', 'transfer')"
            >
            {{ labels.bankPayment }}
          </label>
        </div>
      </div>

      <button
        type="button"
        class="primary-btn"
        :disabled="!items.length || submitting"
        @click="$emit('checkout')"
      >
        {{ submitting ? labels.submitting : labels.checkout }}
      </button>
    </div>

    <p
      v-if="message"
      class="success-message"
    >
      {{ message }}
    </p>

    <p
      v-if="error"
      class="error-message"
    >
      {{ error }}
    </p>
  </section>
</template>

<script setup>
defineEmits(['checkout', 'removeItem', 'update:payment'])

defineProps({
  checkoutStatus: {
    type: String,
    required: true,
  },
  error: {
    type: String,
    default: '',
  },
  formattedTotal: {
    type: String,
    required: true,
  },
  items: {
    type: Array,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  message: {
    type: String,
    default: '',
  },
  payment: {
    type: String,
    required: true,
  },
  selectedPaymentDescription: {
    type: String,
    required: true,
  },
  submitting: {
    type: Boolean,
    default: false,
  },
})
</script>
