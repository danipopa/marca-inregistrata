<template>
  <div>
    <p class="eyebrow">
      {{ labels.eyebrow }}
    </p>
    <h1>{{ labels.title }}</h1>
    <p>{{ labels.copy }}</p>
  </div>
</template>

<script setup>
defineProps({
  labels: {
    type: Object,
    required: true,
  },
})
</script>

<style scoped>
.eyebrow {
  margin: 0 0 10px;
  color: var(--gold-dark, #00add9);
  font-weight: 700;
  text-transform: uppercase;
}

h1 {
  margin: 0 0 14px;
  font-size: 44px;
  font-weight: 400;
}
</style>
