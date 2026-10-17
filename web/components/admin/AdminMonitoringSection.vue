<template>
  <section class="monitoring-admin">
    <div class="section-title">
      <h2>Monitorizare mărci</h2>
      <button
        type="button"
        :disabled="busy"
        @click="loadSubscriptions"
      >
        Reîncarcă
      </button>
    </div>
    <p
      v-if="!providerConfigured"
      class="notice"
    >
      În așteptarea configurării API. Abonamentele pot fi aprobate, dar nu se efectuează verificări automate.
    </p>
    <p
      v-if="error"
      role="alert"
    >
      {{ error }}
    </p>
    <p
      v-if="message"
      role="status"
    >
      {{ message }}
    </p>
    <p v-if="!subscriptions.length && !busy">
      Nu există solicitări de monitorizare.
    </p>
    <article
      v-for="subscription in subscriptions"
      :key="subscription.id"
      class="subscription"
    >
      <h3>{{ subscription.mark }} · Comanda #{{ subscription.order_id }}</h3>
      <p>{{ subscription.email }} · {{ statusLabel(subscription.display_status) }}</p>
      <div class="subscription-fields">
        <label>
          Număr marcă înregistrată
          <input
            v-model="subscription.registration_number"
            type="text"
            maxlength="255"
          >
        </label>
        <label>
          Marcă înregistrată la
          <select v-model="subscription.registration_office">
            <option value="">Selectați oficiul</option>
            <option
              v-for="office in ['OSIM', 'EUIPO', 'WIPO']"
              :key="office"
            >{{ office }}</option>
          </select>
        </label>
        <label>
          Interval verificare (ore)
          <input
            v-model.number="subscription.interval_hours"
            type="number"
            min="6"
            max="720"
          >
        </label>
      </div>
      <label class="notifications">
        <input
          v-model="subscription.notifications_enabled"
          type="checkbox"
        >
        Alerte pentru rezultate relevante aprobate și raport lunar
      </label>
      <p>Ultima verificare reușită: {{ dateLabel(subscription.last_success_at) }}</p>
      <p>Următoarea verificare: {{ dateLabel(subscription.next_check_at) }} · Expiră: {{ dateLabel(subscription.expires_at) }}</p>
      <p
        v-if="subscription.last_error"
        role="status"
      >
        {{ subscription.last_error }}
      </p>
      <div class="actions">
        <button
          type="button"
          :disabled="busy"
          @click="save(subscription)"
        >
          Salvează datele
        </button>
        <button
          v-if="['pending_activation', 'paused'].includes(subscription.status)"
          type="button"
          :disabled="busy"
          @click="save(subscription, 'active')"
        >
          {{ subscription.status === 'paused' ? 'Reia monitorizarea' : 'Aprobă și activează un an' }}
        </button>
        <button
          v-if="subscription.status === 'active'"
          type="button"
          :disabled="busy"
          @click="save(subscription, 'paused')"
        >
          Pauză
        </button>
        <button
          v-if="!['cancelled', 'expired'].includes(subscription.status)"
          type="button"
          :disabled="busy"
          @click="save(subscription, 'cancelled')"
        >
          Anulează monitorizarea
        </button>
        <button
          type="button"
          :disabled="busy || !providerConfigured || subscription.display_status !== 'active'"
          @click="checkNow(subscription)"
        >
          Verifică acum
        </button>
        <button
          type="button"
          :disabled="busy"
          @click="loadDetails(subscription.id)"
        >
          Istoric și rezultate
        </button>
      </div>
      <div
        v-if="details?.subscription.id === subscription.id"
        class="check-details"
      >
        <h4>Ultimele 20 de verificări</h4>
        <p v-if="!details.checks.length">
          Nu există verificări. Configurarea API nu este considerată o verificare reușită.
        </p>
        <ul>
          <li
            v-for="check in details.checks"
            :key="check.id"
          >
            {{ dateLabel(check.started_at) }} · {{ statusLabel(check.status) }} · {{ check.results_count }} rezultate / {{ check.new_matches_count }} noi
            <span v-if="check.error_message"> · {{ check.error_message }}</span>
          </li>
        </ul>
        <h4>Rezultate pentru analiză</h4>
        <p v-if="!details.matches.length">
          Nu există rezultate salvate.
        </p>
        <div
          v-for="match in details.matches"
          :key="match.id"
          class="match"
        >
          <strong>{{ match.name }} · {{ match.office }} · {{ match.external_id }}</strong>
          <a
            v-if="match.source_url"
            :href="match.source_url"
            target="_blank"
            rel="noopener noreferrer"
          >Sursa</a>
          <label>
            Analiza echipei
            <select
              :value="match.review_status"
              :disabled="busy"
              @change="review(match, $event.target.value)"
            >
              <option value="pending">În analiză</option>
              <option value="relevant">Relevant — notifică clientul</option>
              <option value="dismissed">Nerelevant</option>
            </select>
          </label>
          <small v-if="match.notified_at">Client notificat: {{ dateLabel(match.notified_at) }}</small>
        </div>
        <div
          v-if="details.matches_total > 100"
          class="actions"
        >
          <button
            type="button"
            :disabled="busy || details.matches_page <= 1"
            @click="loadDetails(subscription.id, details.matches_page - 1)"
          >
            Rezultate anterioare
          </button>
          <span>Pagina {{ details.matches_page }} · {{ details.matches_total }} rezultate</span>
          <button
            type="button"
            :disabled="busy || details.matches_page * 100 >= details.matches_total"
            @click="loadDetails(subscription.id, details.matches_page + 1)"
          >
            Rezultate următoare
          </button>
        </div>
      </div>
    </article>
    <div class="actions">
      <button
        type="button"
        :disabled="busy || page === 1"
        @click="changePage(-1)"
      >
        Înapoi
      </button>
      <span>Pagina {{ page }} · {{ total }} abonamente</span>
      <button
        type="button"
        :disabled="busy || page * 50 >= total"
        @click="changePage(1)"
      >
        Înainte
      </button>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const props = defineProps({ authToken: { type: String, required: true } })
const config = useRuntimeConfig()
const subscriptions = ref([])
const providerConfigured = ref(false)
const details = ref(null)
const busy = ref(false)
const error = ref('')
const message = ref('')
const page = ref(1)
const total = ref(0)

function statusLabel(status) {
  return {
    pending_activation: 'În așteptarea plății sau aprobării',
    awaiting_api_configuration: 'În așteptarea configurării API',
    active: 'Activ', paused: 'Suspendat', cancelled: 'Anulat', expired: 'Expirat',
    running: 'În curs', succeeded: 'Finalizat', failed: 'Eșuat', blocked: 'Blocat',
  }[status] || status
}

function dateLabel(value) {
  return value ? new Date(value).toLocaleString('ro-RO') : '—'
}

async function request(path, method = 'GET', body) {
  const response = await fetch(`${config.public.apiBaseUrl}/api/v1/admin/${path}`, {
    method,
    headers: { 'Authorization': `Bearer ${props.authToken}`, 'Content-Type': 'application/json' },
    ...(body ? { body: JSON.stringify(body) } : {}),
  })
  const payload = await response.json().catch(() => ({}))
  if (!response.ok) throw new Error(payload.message || Object.values(payload.errors || {}).flat().join('; ') || 'Solicitarea a eșuat.')
  return payload
}

async function run(action) {
  busy.value = true
  error.value = ''
  message.value = ''
  try {
    await action()
  }
  catch (cause) {
    error.value = cause.message || 'Solicitarea a eșuat.'
  }
  finally {
    busy.value = false
  }
}

async function refresh() {
  const payload = await request(`monitoring_subscriptions?page=${page.value}`)
  subscriptions.value = payload.subscriptions
  providerConfigured.value = payload.provider_configured
  total.value = payload.total
}

function loadSubscriptions() {
  return run(refresh)
}

function save(subscription, status) {
  return run(async () => {
    await request(`monitoring_subscriptions/${subscription.id}`, 'PATCH', { monitoring_subscription: {
      registration_number: subscription.registration_number,
      registration_office: subscription.registration_office,
      interval_hours: subscription.interval_hours,
      notifications_enabled: subscription.notifications_enabled,
      ...(status ? { status } : {}),
    } })
    await refresh()
    message.value = 'Datele monitorizării au fost salvate.'
  })
}

function loadDetails(id, matchPage = 1) {
  return run(async () => {
    details.value = await request(`monitoring_subscriptions/${id}?match_page=${matchPage}`)
  })
}

function checkNow(subscription) {
  return run(async () => {
    await request(`monitoring_subscriptions/${subscription.id}/check`, 'POST')
    message.value = 'Verificarea a fost pusă în coadă. Reîncărcați istoricul pentru rezultat.'
  })
}

function review(match, reviewStatus) {
  return run(async () => {
    await request(`monitoring_matches/${match.id}`, 'PATCH', { monitoring_match: { review_status: reviewStatus } })
    details.value = await request(`monitoring_subscriptions/${details.value.subscription.id}?match_page=${details.value.matches_page}`)
    message.value = 'Analiza a fost salvată.'
  })
}

function changePage(direction) {
  page.value += direction
  return loadSubscriptions()
}

onMounted(loadSubscriptions)
</script>

<style scoped>
.monitoring-admin { display: grid; gap: 20px; font-family: 'Montserrat', sans-serif; }
.subscription { border: 1px solid var(--line, #ddd); padding: 20px; background: #fff; }
.subscription-fields { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; }
label { display: grid; gap: 6px; }
input, select, button { font: inherit; padding: 8px; }
.actions { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-top: 16px; }
.notifications { display: flex; align-items: center; gap: 8px; margin-top: 16px; }
.notice { padding: 16px; background: #fff3cd; color: #493b00; }
.check-details { margin-top: 24px; }
.match { display: grid; gap: 8px; border-top: 1px solid #ddd; padding: 16px 0; }
button { cursor: pointer; }
button:disabled { cursor: default; opacity: 0.5; }
</style>
