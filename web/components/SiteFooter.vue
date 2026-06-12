<template>
  <footer class="site-footer">
    <div class="wrap footer-grid">
      <div class="footer-brand">
        <span
          class="footer-brand__logo"
          :style="{ '--footer-fallback-logo-image': `url(${footerLogoUrl})` }"
          role="img"
          :aria-label="brandName"
        />
        <p>
          {{ footerCopy }}
        </p>
      </div>

      <nav
        :aria-label="labels.servicesLabel"
        class="footer-column"
      >
        <h2>{{ labels.footerResources }}</h2>
        <a
          href="#formular"
          @click.prevent="$emit('openOrderForm')"
        >{{ labels.quickRegistration }}</a>
        <a href="#reinnoire">{{ labels.quickRenewal }}</a>
        <a href="#monitorizare">{{ labels.quickMonitoring }}</a>
        <a href="#verificare">{{ labels.quickCheck }}</a>
      </nav>

      <div class="footer-column">
        <h2>Contact</h2>
        <a href="tel:0770898767">0770 898 767</a>
        <a href="mailto:office@sandusiasociatii.ro">office@sandusiasociatii.ro</a>
        <a href="mailto:contact@inregistrare-marca.com">contact@inregistrare-marca.com</a>
        <span>Str. C. Libertății, Nr. 42, Sector 3, București</span>
        <span>{{ labels.businessHours }}</span>
      </div>

      <nav
        :aria-label="labels.anpcLinksLabel"
        class="footer-column anpc-links"
      >
        <h2>ANPC</h2>
        <a
          href="https://anpc.ro/"
          target="_blank"
          rel="noopener noreferrer"
        >ANPC</a>
        <a
          href="https://ec.europa.eu/consumers/odr"
          target="_blank"
          rel="noopener noreferrer"
        >
          {{ labels.odr }}
        </a>
        <a
          href="https://anpc.ro/ce-este-sal/"
          target="_blank"
          rel="noopener noreferrer"
        >
          {{ labels.sal }}
        </a>
      </nav>
    </div>

    <div class="wrap footer-bottom">
      <span>{{ copyrightText }}</span>
      <span class="legal-links">
        <NuxtLink to="/politica-de-confidentialitate">
          {{ labels.privacyPolicy }}
        </NuxtLink>
        <NuxtLink to="/termeni-si-conditii">
          {{ labels.termsOfUse }}
        </NuxtLink>
      </span>
    </div>
  </footer>
</template>

<script setup>
import footerLogoUrl from '../assets/images/logo_footbar-removebg-preview.png'

defineEmits(['openOrderForm'])

defineProps({
  brandName: {
    type: String,
    required: true,
  },
  copyrightText: {
    type: String,
    required: true,
  },
  footerCopy: {
    type: String,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
})
</script>

<style scoped>
.site-footer {
  background: var(--brand);
  color: #f8f3ea;
  font-family: var(--font-family, 'Montserrat', sans-serif);
  padding: 42px 0 22px;
}

.wrap {
  width: min(1180px, calc(100% - 32px));
  margin: 0 auto;
}

.footer-grid {
  display: grid;
  grid-template-columns: minmax(220px, 320px) minmax(220px, 320px) repeat(3, minmax(110px, 0.7fr));
  gap: clamp(24px, 3vw, 48px);
  align-items: start;
}

.footer-brand {
  display: contents;
}

.footer-brand__logo {
  display: block;
  width: clamp(220px, 24vw, 320px);
  aspect-ratio: 7 / 5;
  background: var(--footer-fallback-logo-image) center / contain no-repeat;
}

.footer-brand p {
  max-width: 360px;
  min-width: 0;
  margin: 0;
  color: #f8f3ea;
  font-size: 14px;
  line-height: 1.3;
}

.footer-column {
  display: grid;
  align-content: start;
  gap: 10px;
}

.footer-column h2 {
  margin: 0 0 8px;
  color: #fff;
  font-size: 13px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.footer-column a,
.footer-column span {
  color: #fff;
  font-size: 16px;
  line-height: 1.35;
  text-decoration: none;
}

.footer-column a:hover {
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 4px;
}

.footer-bottom {
  display: flex;
  justify-content: space-between;
  gap: 18px;
  margin-top: 34px;
  border-top: 1px solid rgba(248, 243, 234, 0.16);
  padding-top: 18px;
  color: #b8afa2;
  font-size: 13px;
}

.legal-links {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
}

.legal-links a {
  color: inherit;
  text-decoration: none;
}

.legal-links a:hover {
  color: #fff;
  text-decoration: underline;
  text-underline-offset: 4px;
}

@media (max-width: 980px) {
  .footer-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .footer-brand {
    display: grid;
    grid-template-columns: minmax(220px, 320px) minmax(0, 1fr);
    gap: clamp(18px, 2.4vw, 32px);
    align-items: start;
    grid-column: 1 / -1;
    min-width: 0;
  }
}

@media (max-width: 640px) {
  .footer-grid,
  .footer-bottom {
    grid-template-columns: 1fr;
    flex-direction: column;
  }

  .footer-brand {
    grid-template-columns: 1fr;
  }

  .footer-brand__logo {
    width: clamp(220px, 76vw, 320px);
  }
}
</style>
