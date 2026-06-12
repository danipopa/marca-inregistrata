<template>
  <section class="orders-panel">
    <div class="panel-head">
      <div>
        <p class="panel-kicker">
          {{ labels.ordersKicker }}
        </p>
        <h2>{{ labels.ordersTitle }}</h2>
      </div>
    </div>

    <p>{{ labels.ordersCopy }}</p>

    <div
      v-if="account?.purchases?.length"
      class="purchase-list"
    >
      <article
        v-for="purchase in account.purchases"
        :key="purchase.id"
        class="purchase-item"
      >
        <div class="purchase-item__main">
          <strong>{{ purchase.product_name || productTitle(purchase.product_code) }}</strong>
          <span>{{ purchase.mark }} · {{ purchase.classes }} {{ labels.niceClasses }}</span>
          <small v-if="purchase.owner_change_requested">{{ labels.ownerChangeCartLabel }}</small>
        </div>
        <div class="purchase-item__meta">
          <strong>{{ purchase.total.formatted }}</strong>
          <span>{{ statusLabel(purchase.status) }}</span>
        </div>
        <div class="purchase-item__actions">
          <button
            type="button"
            class="remove-order-btn"
            @click="$emit('downloadInvoice', purchase)"
          >
            {{ invoiceLabel(purchase) }}
          </button>
          <button
            v-if="purchase.removable"
            type="button"
            class="remove-order-btn"
            :disabled="removingPurchaseId === purchase.id"
            @click="$emit('removePurchase', purchase)"
          >
            {{ removingPurchaseId === purchase.id ? labels.removingPurchase : labels.removePurchase }}
          </button>
        </div>
      </article>
    </div>

    <p
      v-else-if="account"
      class="muted empty-orders"
    >
      {{ labels.noPurchases }}
    </p>
  </section>
</template>

<script setup>
defineEmits(['downloadInvoice', 'removePurchase'])

defineProps({
  account: {
    type: Object,
    default: null,
  },
  invoiceLabel: {
    type: Function,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  productTitle: {
    type: Function,
    required: true,
  },
  removingPurchaseId: {
    type: [Number, String],
    default: null,
  },
  statusLabel: {
    type: Function,
    required: true,
  },
})
</script>
