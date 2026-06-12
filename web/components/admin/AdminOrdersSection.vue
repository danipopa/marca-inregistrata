<template>
  <div class="admin-section">
    <div class="section-title">
      <h2>Orders</h2>
      <button
        class="ghost-btn"
        type="button"
        :disabled="loading"
        @click="$emit('refresh')"
      >
        Refresh
      </button>
    </div>

    <div class="stats-grid">
      <article>
        <span>Orders</span>
        <strong>{{ dashboard.stats.orders_count }}</strong>
      </article>
      <article>
        <span>Pending</span>
        <strong>{{ dashboard.stats.pending_orders_count }}</strong>
      </article>
      <article>
        <span>Users</span>
        <strong>{{ dashboard.stats.users_count }}</strong>
      </article>
      <article>
        <span>Revenue</span>
        <strong>{{ dashboard.stats.revenue_lei.toLocaleString('ro-RO') }} Lei</strong>
      </article>
    </div>

    <div class="orders-table">
      <div class="orders-row orders-row--head">
        <span>Date</span>
        <span>Order</span>
        <span>Customer</span>
        <span>Status</span>
        <span>Total</span>
        <span>Admin comments</span>
      </div>
      <div
        v-for="order in dashboard.orders"
        :key="order.id"
        class="orders-row"
      >
        <span>
          <strong>{{ orderDate(order.created_at) }}</strong>
          <small>{{ orderTime(order.created_at) }}</small>
        </span>
        <span>
          <strong>#{{ order.id }} {{ order.mark }}</strong>
          <small>{{ order.product_name }} · {{ order.classes }} classes</small>
          <small>{{ orderTypeLabel(order.order_type) }}</small>
          <small v-if="order.owner_change_requested">Owner address/name change requested</small>
        </span>
        <span>
          <strong>{{ order.email }}</strong>
          <small>{{ order.phone }}</small>
          <small v-if="order.ip_address">IP: {{ order.ip_address }}</small>
        </span>
        <span class="order-payment">
          <label class="status-select">
            <span>Status</span>
            <select
              :value="order.status"
              :disabled="savingOrderId === order.id"
              @change="updateOrderStatus(order, $event.target.value)"
            >
              <option value="pending_payment">Pending payment</option>
              <option value="paid">Paid</option>
              <option value="processing">Processing</option>
              <option value="completed">Completed</option>
            </select>
          </label>
          <small>{{ paymentLabel(order.payment_method) }}</small>
        </span>
        <span>{{ order.total.formatted }}</span>
        <span class="order-comments">
          <button
            class="ghost-btn"
            type="button"
            @click="$emit('downloadOrderInvoice', order)"
          >
            {{ order.payment_method === 'transfer' ? 'Download proforma' : 'Download invoice' }}
          </button>
          <textarea
            :value="order.admin_comments"
            rows="3"
            placeholder="Add internal note"
            @input="$emit('updateOrderField', order, 'admin_comments', $event.target.value)"
          />
          <button
            class="ghost-btn"
            type="button"
            :disabled="savingOrderId === order.id"
            @click="$emit('saveOrderComments', order)"
          >
            {{ savingOrderId === order.id ? 'Saving...' : 'Save' }}
          </button>
          <div class="order-log">
            <strong>Change log</strong>
            <ul v-if="order.events?.length">
              <li
                v-for="event in order.events"
                :key="event.id"
              >
                <span>{{ eventLabel(event) }}</span>
                <small>{{ event.admin_email || 'system' }} · {{ eventDate(event.created_at) }}</small>
              </li>
            </ul>
            <small v-else>No changes logged yet.</small>
          </div>
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits([
  'downloadOrderInvoice',
  'refresh',
  'saveOrderComments',
  'saveOrderStatus',
  'updateOrderField',
])

defineProps({
  dashboard: {
    type: Object,
    required: true,
  },
  eventDate: {
    type: Function,
    required: true,
  },
  eventLabel: {
    type: Function,
    required: true,
  },
  loading: {
    type: Boolean,
    default: false,
  },
  orderDate: {
    type: Function,
    required: true,
  },
  orderTime: {
    type: Function,
    required: true,
  },
  orderTypeLabel: {
    type: Function,
    required: true,
  },
  paymentLabel: {
    type: Function,
    required: true,
  },
  savingOrderId: {
    type: [Number, String],
    default: null,
  },
})

function updateOrderStatus(order, status) {
  emit('updateOrderField', order, 'status', status)
  emit('saveOrderStatus', order)
}
</script>
