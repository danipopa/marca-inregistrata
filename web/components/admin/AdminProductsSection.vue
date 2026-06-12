<template>
  <div class="admin-section">
    <div class="section-title">
      <h2>Products</h2>
      <button
        class="ghost-btn"
        type="button"
        @click="$emit('showNewProductForm')"
      >
        Add product
      </button>
    </div>

    <form
      v-if="showForm"
      class="product-form"
      @submit.prevent="$emit('saveProduct')"
    >
      <div class="field-grid">
        <label>
          Code
          <input
            :value="form.code"
            required
            @input="updateForm('code', $event.target.value)"
          >
        </label>
        <label>
          Position
          <input
            :value="form.position"
            type="number"
            min="0"
            required
            @input="updateForm('position', Number($event.target.value))"
          >
        </label>
        <label>
          Currency
          <select
            :value="form.currency"
            @change="updateForm('currency', $event.target.value)"
          >
            <option value="RON">RON</option>
            <option value="EUR">EUR</option>
          </select>
        </label>
        <label>
          Office
          <input
            :value="form.region"
            required
            @input="updateForm('region', $event.target.value)"
          >
        </label>
        <label>
          Price label
          <input
            :value="form.price_label"
            required
            @input="updateForm('price_label', $event.target.value)"
          >
        </label>
        <label>
          Base price Lei
          <input
            :value="form.base_price_lei"
            type="number"
            min="0"
            required
            @input="updateForm('base_price_lei', Number($event.target.value))"
          >
        </label>
        <label style="position:relative;">
          Image
          <div style="position:relative;">
            <select
              :value="form.image_key"
              :title="selectedImageDescription"
              @change="updateForm('image_key', $event.target.value)"
            >
              <option value="">None</option>
              <option value="verbal">Marca verbala OSIM</option>
              <option value="black_white">Marca alb-negru</option>
              <option value="color">Marca color</option>
              <option
                v-for="image in uploadedImages"
                :key="image.key"
                :value="image.key"
              >
                {{ image.name }}
              </option>
            </select>
          </div>
        </label>
        <label>
          Upload image
          <input
            :value="uploadImageName"
            type="text"
            placeholder="Display name"
            @input="$emit('update:uploadImageName', $event.target.value)"
          >
          <input
            type="file"
            accept="image/*"
            @change="$emit('selectUploadImage', $event)"
          >
          <button
            class="ghost-btn"
            type="button"
            :disabled="imageUploading || !uploadImageFile"
            @click="$emit('uploadProductImage')"
          >
            {{ imageUploading ? 'Uploading...' : 'Upload image' }}
          </button>
        </label>
        <label class="checkbox-field">
          <input
            :checked="form.active"
            type="checkbox"
            @change="updateForm('active', $event.target.checked)"
          >
          Active
        </label>
      </div>

      <div class="field-grid">
        <label>
          Title RO
          <input
            :value="form.title_ro"
            required
            @input="updateForm('title_ro', $event.target.value)"
          >
        </label>
        <label>
          Title EN
          <input
            :value="form.title_en"
            required
            @input="updateForm('title_en', $event.target.value)"
          >
        </label>
        <label>
          Note RO
          <input
            :value="form.note_ro"
            @input="updateForm('note_ro', $event.target.value)"
          >
        </label>
        <label>
          Note EN
          <input
            :value="form.note_en"
            @input="updateForm('note_en', $event.target.value)"
          >
        </label>
        <label>
          Tax RO
          <input
            :value="form.tax_ro"
            @input="updateForm('tax_ro', $event.target.value)"
          >
        </label>
        <label>
          Tax EN
          <input
            :value="form.tax_en"
            @input="updateForm('tax_en', $event.target.value)"
          >
        </label>
        <label>
          Attributes RO
          <textarea
            :value="form.items_ro"
            rows="4"
            @input="updateForm('items_ro', $event.target.value)"
          />
        </label>
        <label>
          Attributes EN
          <textarea
            :value="form.items_en"
            rows="4"
            @input="updateForm('items_en', $event.target.value)"
          />
        </label>
      </div>

      <div class="form-actions">
        <button
          class="primary-btn"
          type="submit"
          :disabled="saving"
        >
          {{ editingProductId ? 'Save changes' : 'Create product' }}
        </button>
        <button
          class="ghost-btn"
          type="button"
          @click="$emit('hideProductForm')"
        >
          Cancel
        </button>
      </div>
    </form>

    <p
      v-if="error"
      class="error-message"
    >
      {{ error }}
    </p>

    <div class="admin-product-categories">
      <section
        v-for="category in categories"
        :key="category.id"
        class="admin-product-category"
      >
        <div class="product-category-heading">
          <h3>{{ category.label }}</h3>
          <span>{{ category.products.length }} produse</span>
        </div>

        <div class="admin-product-grid">
          <article
            v-for="product in category.products"
            :key="product.id"
            class="admin-product-card"
          >
            <div class="admin-product-card__top">
              <div class="admin-product-card__meta">
                <span class="country-pill">{{ product.region }}</span>
                <span :class="['status-pill', product.active ? 'active' : 'hidden']">
                  {{ product.active ? 'Active' : 'Hidden' }}
                </span>
              </div>
              <h3>{{ product.translations.ro.title }}</h3>
              <img
                v-if="productImage(product)"
                class="admin-product-card__image"
                :src="productImage(product)"
                :alt="product.translations.ro.title"
              >
              <p v-if="product.translations.ro.note">
                {{ product.translations.ro.note }}
              </p>
            </div>

            <div class="admin-product-price">
              <span>{{ product.price }}</span>
              <small>{{ product.translations.ro.tax }}</small>
            </div>

            <form
              class="inline-price-form"
              @submit.prevent="$emit('saveProductPrice', product)"
            >
              <label>
                Display price
                <input
                  :value="product.priceDraft.price_label"
                  required
                  @input="$emit('updateProductPriceDraft', product, 'price_label', $event.target.value)"
                >
              </label>
              <label>
                Checkout amount
                <input
                  :value="product.priceDraft.base_price_lei"
                  type="number"
                  min="0"
                  required
                  @input="$emit('updateProductPriceDraft', product, 'base_price_lei', Number($event.target.value))"
                >
              </label>
              <button
                class="ghost-btn"
                type="submit"
                :disabled="savingPriceId === product.id"
              >
                {{ savingPriceId === product.id ? 'Saving...' : 'Save price' }}
              </button>
            </form>

            <ul>
              <li
                v-for="item in product.translations.ro.items"
                :key="item"
              >
                {{ item }}
              </li>
            </ul>

            <div class="admin-product-code">
              <span>{{ product.code }}</span>
              <span>{{ product.currency }}</span>
            </div>

            <div class="product-actions">
              <button
                class="ghost-btn"
                type="button"
                @click="$emit('editProduct', product)"
              >
                Edit
              </button>
              <button
                class="ghost-btn danger-btn"
                type="button"
                @click="$emit('deleteProduct', product)"
              >
                Delete
              </button>
            </div>
          </article>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits([
  'deleteProduct',
  'editProduct',
  'hideProductForm',
  'saveProduct',
  'saveProductPrice',
  'selectUploadImage',
  'showNewProductForm',
  'update:form',
  'update:uploadImageName',
  'updateProductPriceDraft',
  'uploadProductImage',
])

const props = defineProps({
  categories: {
    type: Array,
    required: true,
  },
  editingProductId: {
    type: [Number, String],
    default: null,
  },
  error: {
    type: String,
    default: '',
  },
  form: {
    type: Object,
    required: true,
  },
  imageUploading: {
    type: Boolean,
    default: false,
  },
  productImage: {
    type: Function,
    required: true,
  },
  saving: {
    type: Boolean,
    default: false,
  },
  savingPriceId: {
    type: [Number, String],
    default: null,
  },
  selectedImageDescription: {
    type: String,
    default: '',
  },
  showForm: {
    type: Boolean,
    default: false,
  },
  uploadImageFile: {
    type: Object,
    default: null,
  },
  uploadImageName: {
    type: String,
    default: '',
  },
  uploadedImages: {
    type: Array,
    required: true,
  },
})

function updateForm(field, value) {
  emit('update:form', {
    ...props.form,
    [field]: value,
  })
}
</script>
