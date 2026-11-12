<template>
  <details class="class-price-editor">
    <summary>Prețuri după numărul de clase ({{ product.currency || 'RON' }})</summary>
    <p>Introduceți prețul total pentru fiecare număr de clase, fără opțiuni suplimentare. Câmpurile goale folosesc prețul calculat automat.</p>
    <table>
      <thead><tr><th>Număr de clase</th><th>Preț total ({{ product.currency || 'RON' }})</th><th>Calcul</th></tr></thead>
      <tbody>
        <tr>
          <th scope="row">
            1
          </th><td>{{ basePrice }}</td><td>Preț de bază</td>
        </tr>
        <tr
          v-for="count in 10"
          :key="count + 1"
        >
          <th scope="row">
            {{ count + 1 }}
          </th>
          <td>
            <input
              type="number"
              min="0"
              step="1"
              :value="modelValue[count + 1] ?? ''"
              :placeholder="String(defaultClassTotal(product, count + 1, basePrice))"
              :aria-label="`Preț total pentru ${count + 1} clase (${product.currency || 'RON'})`"
              @input="$emit('update:modelValue', { ...modelValue, [count + 1]: $event.target.value })"
            >
          </td>
          <td>{{ String(modelValue[count + 1] ?? '').trim() ? 'Personalizat' : 'Automat' }}</td>
        </tr>
      </tbody>
    </table>
  </details>
</template>

<script setup>
import { defaultClassTotal } from '../../utils/productPricing'

defineProps({
  modelValue: { type: Object, default: () => ({}) },
  product: { type: Object, required: true },
  basePrice: { type: Number, required: true },
})
defineEmits(['update:modelValue'])
</script>

<style scoped>
.class-price-editor { grid-column: 1 / -1; min-width: 0; margin: 12px 0; padding: 12px; border: 1px solid #ded8cf; border-radius: 8px; }
.class-price-editor summary { cursor: pointer; font-weight: 700; }
.class-price-editor p { font-size: 12px; line-height: 1.5; }
.class-price-editor table { width: 100%; border-collapse: collapse; font-size: 12px; text-align: left; }
.class-price-editor th, .class-price-editor td { padding: 8px 4px; border-bottom: 1px solid #eee; }
.class-price-editor input { box-sizing: border-box; width: 100%; min-width: 65px; max-width: 160px; padding: 8px; border: 1px solid #cfc7bc; border-radius: 4px; font: inherit; }
</style>
