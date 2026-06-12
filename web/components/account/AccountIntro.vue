<template>
  <section class="wrap account-intro">
    <div>
      <p class="eyebrow">
        {{ labels.eyebrow }}
      </p>
      <h1>{{ labels.title }}</h1>
      <p>
        {{ labels.copy }}
      </p>
    </div>
  </section>
</template>

<script setup>
defineProps({
  labels: {
    type: Object,
    required: true,
  },
})
</script>
