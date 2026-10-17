<template>
  <section class="traffic-admin">
    <div class="traffic-toolbar">
      <h2>Trafic și performanță</h2>
      <label>Perioadă
        <select
          v-model="days"
          @change="load"
        >
          <option :value="7">7 zile</option>
          <option :value="30">30 zile</option>
          <option :value="90">90 zile</option>
        </select>
      </label>
      <button
        :disabled="loading"
        @click="load"
      >
        Reîncarcă
      </button>
    </div>
    <p
      v-if="error"
      role="alert"
    >
      {{ error }}
    </p>
    <p v-if="loading">
      Se încarcă…
    </p>
    <p
      v-if="provider === 'google'"
      class="analytics-notice"
    >
      Statisticile vizitatorilor și conversiile sunt disponibile în
      <a
        href="https://analytics.google.com/"
        target="_blank"
        rel="noopener noreferrer"
      >Google Analytics</a>.
      <span v-if="!config.public.googleAnalyticsId">Colectarea GA4 așteaptă configurarea Measurement ID.</span>
      Mai jos sunt afișate metricile tehnice ale API-ului.
    </p>
    <p v-else-if="provider === 'none'">
      Colectarea statisticilor despre vizitatori este dezactivată. Metricile tehnice sunt disponibile mai jos.
    </p>
    <template v-if="data">
      <template v-if="provider === 'first-party'">
        <p>Vizitele sunt măsurate după acordul pentru statistici. Sunt excluse paginile de administrare și cont. Datele se păstrează 90 de zile. Fus orar: {{ data.timezone }}.</p>
        <div class="traffic-cards">
          <article><strong>{{ data.visitors }}</strong><span>Vizitatori unici</span></article>
          <article><strong>{{ data.sessions }}</strong><span>Sesiuni</span></article>
          <article><strong>{{ data.page_views }}</strong><span>Afișări de pagină</span></article>
        </div>
        <h3>Afișări pe zi</h3>
        <div
          class="traffic-chart"
          aria-label="Afișări zilnice"
        >
          <div
            v-for="day in data.daily"
            :key="day.date"
            :title="`${day.date}: ${day.views}`"
            class="traffic-day"
          >
            <span :style="{ height: `${Math.max(2, day.views / maximumViews * 100)}%` }" />
            <small>{{ day.date.slice(5) }}</small>
          </div>
        </div>
        <div class="traffic-tables">
          <div>
            <h3>Pagini</h3><table>
              <thead><tr><th>Pagină</th><th>Afișări</th></tr></thead><tbody>
                <tr
                  v-for="page in data.pages"
                  :key="page.path"
                >
                  <td>{{ page.path }}</td><td>{{ page.views }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div>
            <h3>Surse</h3><table>
              <thead><tr><th>Domeniu</th><th>Afișări</th></tr></thead><tbody>
                <tr
                  v-for="source in data.referrers"
                  :key="source.host"
                >
                  <td>{{ source.host }}</td><td>{{ source.views }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
      <h3>API — trafic tehnic</h3>
      <p>Aceste totaluri includ cererile API indiferent de acordul pentru statistici. Fișierele, paginile Nuxt, verificările de sănătate și cererile acestui raport sunt excluse. Jurnalele web oferă vizibilitate separată pentru serverul Nuxt.</p>
      <div class="traffic-cards">
        <article><strong>{{ data.technical.requests }}</strong><span>Cereri API</span></article>
        <article><strong>{{ data.technical.server_errors }}</strong><span>Erori 5xx</span></article>
        <article><strong>{{ data.technical.client_errors }}</strong><span>Răspunsuri 4xx</span></article>
        <article><strong>{{ data.technical.average_ms }} ms</strong><span>Timp mediu API</span></article>
        <article><strong>{{ data.technical.max_ms }} ms</strong><span>Timp maxim API</span></article>
      </div>
      <table>
        <thead><tr><th>Rută API</th><th>Cereri</th></tr></thead><tbody>
          <tr
            v-for="endpoint in data.technical.endpoints"
            :key="endpoint.endpoint"
          >
            <td>{{ endpoint.endpoint }}</td><td>{{ endpoint.requests }}</td>
          </tr>
        </tbody>
      </table>
      <p v-if="provider === 'first-party' && !data.page_views">
        Nu există încă afișări pentru perioada selectată.
      </p>
    </template>
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { analyticsProvider } from '../../utils/analytics'

const props = defineProps({ authToken: { type: String, required: true } })
const config = useRuntimeConfig()
const provider = computed(() => analyticsProvider(config.public))
const days = ref(30)
const data = ref(null)
const loading = ref(false)
const error = ref('')
const maximumViews = computed(() => Math.max(1, ...(data.value?.daily || []).map(day => day.views)))

async function load() {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/traffic?days=${days.value}`, {
      headers: { Authorization: `Bearer ${props.authToken}` },
    })
    if (!response.ok) throw new Error('Nu am putut încărca statisticile.')
    data.value = await response.json()
  }
  catch (err) { error.value = err.message || 'Eroare la încărcare.' }
  finally { loading.value = false }
}
onMounted(load)
</script>

<style scoped>
.traffic-admin { display: grid; gap: 16px; }
.traffic-toolbar { display: flex; gap: 16px; flex-wrap: wrap; align-items: center; }
.traffic-toolbar h2 { margin-right: auto; }
.traffic-cards { display: flex; flex-wrap: wrap; gap: 16px; }
.traffic-cards article { border: 1px solid #ded8cf; border-radius: 8px; padding: 18px; min-width: 140px; display: grid; gap: 8px; }
.traffic-cards strong { font-size: 26px; }
.traffic-tables { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 24px; }
table { width: 100%; text-align: left; border-collapse: collapse; overflow-wrap: anywhere; }
th, td { padding: 10px; border-bottom: 1px solid #ded8cf; }
.traffic-chart { height: 180px; display: flex; align-items: end; gap: 3px; padding-bottom: 26px; overflow-x: auto; }
.traffic-day { height: 100%; min-width: 8px; flex: 1; position: relative; display: flex; align-items: end; }
.traffic-day > span { display: block; width: 100%; background: #00add9; border-radius: 3px 3px 0 0; }
.traffic-day small { display: none; position: absolute; top: 100%; font-size: 10px; }
.traffic-day:nth-child(7n + 1) small { display: block; }
</style>
