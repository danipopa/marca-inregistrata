<template>
  <div
    class="language-switcher"
    :aria-label="label"
  >
    <button
      v-for="option in languages"
      :key="option.code"
      type="button"
      :class="{ active: modelValue === option.code }"
      @click="$emit('update:modelValue', option.code)"
    >
      {{ option.label }}
    </button>
  </div>
</template>

<script setup>
defineProps({
  label: {
    type: String,
    required: true,
  },
  languages: {
    type: Array,
    required: true,
  },
  modelValue: {
    type: String,
    required: true,
  },
})

defineEmits(['update:modelValue'])
</script>

<style scoped>
.language-switcher {
  display: inline-flex;
  border: 1px solid #ded8cf;
}

.language-switcher button {
  min-height: 34px;
  border: 0;
  background: #fff;
  color: #1f1d1a;
  cursor: pointer;
  padding: 0 10px;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  font-weight: 700;
}

.language-switcher button + button {
  border-left: 1px solid #ded8cf;
}

.language-switcher button.active {
  background: var(--gold, #00add9);
  color: #fff;
}
</style>
