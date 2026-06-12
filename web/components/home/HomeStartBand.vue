<template>
  <section
    id="verificare"
    class="start-band"
  >
    <div class="wrap start-band__inner">
      <div>
        <p class="eyebrow">
          {{ labels.startEyebrow }}
        </p>
        <h2>{{ labels.startTitle }}</h2>
      </div>
      <p>
        {{ labels.startCopy }}
      </p>
      <a
        class="outline-btn"
        href="#formular"
        @click.prevent="$emit('openVerificationForm')"
      >{{ labels.startCta }}</a>
    </div>
  </section>
</template>

<script setup>
defineEmits(['openVerificationForm'])

defineProps({
  labels: {
    type: Object,
    required: true,
  },
})
</script>
