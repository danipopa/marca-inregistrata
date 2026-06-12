<template>
  <div class="checkout-panel">
    <div
      v-if="items.length"
      class="cart-list"
    >
      <article
        v-for="item in items"
        :key="item.id"
        class="cart-item"
      >
        <div>
          <strong>{{ item.productTitle }}</strong>
          <span>{{ item.mark }} · {{ item.classes }} {{ labels.niceClasses }}</span>
          <small v-if="item.ownerChangeRequested">{{ labels.ownerChangeCartLabel }}</small>
          <small>{{ item.primaryClass }}</small>
        </div>
        <div class="cart-item__meta">
          <strong>{{ item.formattedTotal }}</strong>
          <button
            type="button"
            class="text-danger"
            @click="$emit('removeItem', item.id)"
          >
            {{ labels.removeFromCart }}
          </button>
        </div>
      </article>
    </div>

    <p
      v-else
      class="muted empty-cart"
    >
      {{ labels.emptyCart }}
    </p>

    <div
      v-if="items.length"
      class="checkout-box"
    >
      <div class="checkout-summary">
        <span>{{ labels.cartTotal }}</span>
        <strong>{{ formattedTotal }}</strong>
        <small>{{ selectedPaymentDescription }}</small>
        <small>{{ accountCheckoutStatus }}</small>
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
        :disabled="submitting"
        @click="$emit('checkout')"
      >
        {{ submitting ? labels.submitting : labels.checkout }}
      </button>
    </div>

    <div
      v-if="!authenticated && items.length"
      class="checkout-account-box"
    >
      <strong>{{ labels.loginRequiredTitle }}</strong>
      <p>{{ labels.loginRequiredCopy }}</p>
      <NuxtLink
        class="primary-btn"
        to="/account"
      >
        {{ labels.goToAccount }}
      </NuxtLink>
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
  </div>
</template>

<script setup>
defineEmits(['checkout', 'removeItem', 'update:payment'])

defineProps({
  accountCheckoutStatus: {
    type: String,
    required: true,
  },
  authenticated: {
    type: Boolean,
    default: false,
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

<style scoped>
.checkout-panel {
  display: grid;
  gap: 16px;
  border: 1px solid var(--line, #ded8cf);
  background: var(--paper, #fff);
  padding: 24px;
}

.cart-list {
  display: grid;
  gap: 12px;
}

.cart-item,
.checkout-box,
.checkout-account-box {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  border: 1px solid var(--line, #ded8cf);
  background: #fff;
  padding: 16px;
}

.cart-item span,
.cart-item small,
.checkout-box span,
.checkout-box small {
  display: block;
  color: var(--muted, #68635c);
  line-height: 1.5;
}

.cart-item__meta {
  min-width: 130px;
  text-align: right;
}

.checkout-box {
  align-items: center;
  flex-wrap: wrap;
}

.checkout-summary strong {
  display: block;
  margin-top: 4px;
  font-size: 30px;
}

.checkout-payment {
  display: grid;
  gap: 10px;
  min-width: min(100%, 320px);
}

.payment-options {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.payment-options label {
  border: 1px solid var(--line, #ded8cf);
  padding: 10px;
}

.primary-btn,
.text-danger {
  border: 0;
  cursor: pointer;
}

.primary-btn {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  min-height: 44px;
  background: var(--gold, #00add9);
  color: #fff;
  padding: 0 18px;
  text-decoration: none;
}

.primary-btn:disabled {
  cursor: not-allowed;
  opacity: 0.55;
}

.text-danger {
  background: transparent;
  color: #9b2d1f;
  padding: 0;
}

.checkout-account-box {
  display: grid;
}

.success-message,
.error-message {
  margin: 0;
  padding: 12px 14px;
}

.success-message {
  background: #e8f7ee;
  color: #166534;
}

.error-message {
  background: #fff1f0;
  color: #9b2d1f;
}

.muted {
  color: var(--muted, #68635c);
}

@media (max-width: 900px) {
  .payment-options {
    grid-template-columns: 1fr;
  }

  .cart-item,
  .checkout-box {
    align-items: stretch;
    flex-direction: column;
  }

  .cart-item__meta {
    text-align: left;
  }
}
</style>
