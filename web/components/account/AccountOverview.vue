<template>
  <div class="account-overview">
    <div
      v-if="account"
      class="account-metrics"
    >
      <div>
        <span>{{ labels.orders }}</span>
        <strong>{{ account.purchases_count }}</strong>
      </div>
      <div>
        <span>{{ labels.total }}</span>
        <strong>{{ account.total_spent.toLocaleString(locale) }} Lei</strong>
      </div>
    </div>

    <div class="account-menu">
      <button
        type="button"
        class="account-menu__button"
        :aria-expanded="menuOpen"
        @click="$emit('update:menuOpen', !menuOpen)"
      >
        <span
          class="account-avatar"
          aria-hidden="true"
        >
          {{ initials }}
        </span>
        <span class="account-menu__label">
          <span>{{ labels.accountButton }}</span>
          <strong>{{ displayName }}</strong>
          <small>{{ labels.accountSettingsHint }}</small>
        </span>
      </button>
      <div
        v-if="menuOpen"
        class="account-menu__panel"
      >
        <div class="account-menu__user">
          <strong>{{ displayName }}</strong>
          <span>{{ user?.email }}</span>
          <button
            type="button"
            class="account-menu__edit"
            @click="$emit('editBilling')"
          >
            {{ labels.editAccount }}
          </button>
          <button
            type="button"
            class="account-menu__edit"
            @click="$emit('resetMfa')"
          >
            {{ labels.resetMfa }}
          </button>
        </div>
        <div class="account-menu__status">
          <span>{{ user?.billing_complete ? labels.billingCompleteTitle : labels.billingIncompleteTitle }}</span>
          <small>{{ user?.billing_complete ? labels.billingCompleteCopy : labels.billingIncompleteCopy }}</small>
        </div>
        <button
          type="button"
          @click="$emit('logout')"
        >
          {{ labels.logout }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineEmits(['editBilling', 'logout', 'resetMfa', 'update:menuOpen'])

defineProps({
  account: {
    type: Object,
    default: null,
  },
  displayName: {
    type: String,
    required: true,
  },
  initials: {
    type: String,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  locale: {
    type: String,
    required: true,
  },
  menuOpen: {
    type: Boolean,
    default: false,
  },
  user: {
    type: Object,
    default: null,
  },
})
</script>
