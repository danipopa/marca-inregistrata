<template>
  <aside class="task-sidebar">
    <button
      class="sidebar-toggle"
      type="button"
      :aria-expanded="!collapsed"
      :aria-label="collapsed ? 'Show menu' : 'Hide menu'"
      @click="$emit('update:collapsed', !collapsed)"
    >
      <span
        class="hamburger-icon"
        aria-hidden="true"
      />
      <span v-if="!collapsed">Hide menu</span>
    </button>

    <button
      v-for="task in tasks"
      v-show="!collapsed"
      :key="task.id"
      class="task-button"
      :class="{ active: activeTask === task.id }"
      type="button"
      @click="$emit('update:activeTask', task.id)"
    >
      <span>{{ task.label }}</span>
    </button>

    <div
      v-show="!collapsed"
      class="signed-in-card"
    >
      <span>Signed in as</span>
      <strong>{{ user?.email }}</strong>
      <button
        class="ghost-btn"
        type="button"
        @click="$emit('logout')"
      >
        Logout
      </button>
    </div>
  </aside>
</template>

<script setup>
defineEmits(['logout', 'update:activeTask', 'update:collapsed'])

defineProps({
  activeTask: {
    type: String,
    required: true,
  },
  collapsed: {
    type: Boolean,
    default: false,
  },
  tasks: {
    type: Array,
    required: true,
  },
  user: {
    type: Object,
    default: null,
  },
})
</script>
