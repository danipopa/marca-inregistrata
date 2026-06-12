<template>
  <div class="admin-section">
    <div class="section-title">
      <h2>Settings</h2>
    </div>

    <div class="settings-grid">
      <article>
        <span>Admin account</span>
        <strong>{{ user?.email }}</strong>
      </article>
      <article>
        <span>Product records</span>
        <strong>{{ productsCount }}</strong>
      </article>
    </div>

    <form
      class="theme-form"
      @submit.prevent="$emit('saveTheme')"
    >
      <div class="section-title">
        <h2>Website theme</h2>
        <button
          class="ghost-btn"
          type="button"
          :disabled="themeSaving"
          @click="$emit('loadTheme')"
        >
          Reload
        </button>
      </div>

      <div class="theme-grid">
        <label class="theme-grid__wide">
          Brand name
          <input
            :value="form.brand_name"
            type="text"
            placeholder="SANDU și Asociații IP Attorney"
            @input="updateForm('brand_name', $event.target.value)"
          >
        </label>
        <label class="theme-grid__wide">
          Homepage hero image
          <select
            :value="form.hero_image_key"
            @change="updateForm('hero_image_key', $event.target.value)"
          >
            <option value="">Built-in default image</option>
            <option
              v-for="image in uploadedImages"
              :key="image.key"
              :value="image.key"
            >
              {{ image.name }}
            </option>
          </select>
        </label>
        <label class="theme-grid__wide">
          Website logo image
          <select
            :value="form.logo_image_key"
            @change="updateForm('logo_image_key', $event.target.value)"
          >
            <option value="">Built-in default logo</option>
            <option
              v-for="image in uploadedImages"
              :key="image.key"
              :value="image.key"
            >
              {{ image.name }}
            </option>
          </select>
        </label>
        <label class="theme-grid__wide">
          Upload theme image
          <input
            :value="uploadThemeImageName"
            type="text"
            placeholder="Display name"
            @input="$emit('update:uploadThemeImageName', $event.target.value)"
          >
          <input
            type="file"
            accept="image/*"
            @change="$emit('selectUploadThemeImage', $event)"
          >
          <button
            class="ghost-btn"
            type="button"
            :disabled="themeImageUploading || !uploadThemeImageFile"
            @click="$emit('uploadThemeImage')"
          >
            {{ themeImageUploading ? 'Uploading...' : 'Upload theme image' }}
          </button>
        </label>
        <label class="theme-grid__wide">
          Footer logo text
          <textarea
            :value="form.footer_text"
            rows="5"
            placeholder="Text shown next to the footer logo"
            @input="updateForm('footer_text', $event.target.value)"
          />
        </label>
        <label class="theme-grid__wide">
          Terms and conditions
          <textarea
            :value="form.terms_content"
            rows="12"
            placeholder="# Termeni si conditii"
            @input="updateForm('terms_content', $event.target.value)"
          />
        </label>
        <label class="theme-grid__wide">
          Privacy policy
          <textarea
            :value="form.privacy_policy_content"
            rows="16"
            placeholder="# Politica de confidentialitate"
            @input="updateForm('privacy_policy_content', $event.target.value)"
          />
        </label>
        <label
          v-for="field in fields"
          :key="field.key"
        >
          {{ field.label }}
          <span
            v-if="field.type === 'color'"
            class="theme-color-control"
          >
            <input
              :value="form[field.key]"
              type="color"
              @input="updateForm(field.key, $event.target.value)"
            >
            <input
              :value="form[field.key]"
              type="text"
              placeholder="#00add9"
              pattern="^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$"
              @input="updateForm(field.key, $event.target.value)"
            >
          </span>
          <input
            v-else
            :value="form[field.key]"
            :placeholder="field.placeholder"
            @input="updateForm(field.key, $event.target.value)"
          >
        </label>
      </div>

      <div class="theme-preview">
        <span :style="{ background: form.brand_color }" />
        <span :style="{ background: form.primary_color }" />
        <span :style="{ background: form.primary_dark_color }" />
        <strong :style="{ fontFamily: themeFontStack }">Theme preview</strong>
      </div>

      <div class="form-actions">
        <button
          class="primary-btn"
          type="submit"
          :disabled="themeSaving"
        >
          {{ themeSaving ? 'Saving theme...' : 'Save theme' }}
        </button>
      </div>

      <p
        v-if="themeMessage"
        class="success-message"
      >
        {{ themeMessage }}
      </p>
    </form>

    <h2>Recent users</h2>
    <div class="user-list">
      <article
        v-for="recentUser in users"
        :key="recentUser.id"
      >
        <div>
          <strong>{{ recentUser.email }}</strong>
          <span>{{ recentUser.orders_count }} orders</span>
        </div>
        <span>{{ recentUser.admin ? 'Admin' : 'Client' }}</span>
        <button
          v-if="recentUser.mfa_enabled"
          class="ghost-btn"
          type="button"
          @click="$emit('resetUserMfa', recentUser)"
        >
          Reset MFA
        </button>
      </article>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits([
  'loadTheme',
  'saveTheme',
  'selectUploadThemeImage',
  'resetUserMfa',
  'update:form',
  'update:uploadThemeImageName',
  'uploadThemeImage',
])

const props = defineProps({
  fields: {
    type: Array,
    required: true,
  },
  form: {
    type: Object,
    required: true,
  },
  productsCount: {
    type: Number,
    required: true,
  },
  themeFontStack: {
    type: String,
    required: true,
  },
  themeImageUploading: {
    type: Boolean,
    default: false,
  },
  themeMessage: {
    type: String,
    default: '',
  },
  themeSaving: {
    type: Boolean,
    default: false,
  },
  uploadThemeImageFile: {
    type: Object,
    default: null,
  },
  uploadThemeImageName: {
    type: String,
    default: '',
  },
  uploadedImages: {
    type: Array,
    required: true,
  },
  user: {
    type: Object,
    default: null,
  },
  users: {
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
