import { ref } from 'vue'
import { useRuntimeConfig } from '#app'

const authToken = ref('')
const currentUser = ref(null)
const authHydrating = ref(false)

export function useAuthSession() {
  const config = useRuntimeConfig()

  function authHeaders(token = authToken.value) {
    return token ? { Authorization: `Bearer ${token}` } : {}
  }

  function persistSession(token, user) {
    authToken.value = token
    currentUser.value = user
    window.localStorage.setItem('account-token', token)
    window.localStorage.setItem('account-user', JSON.stringify(user))
  }

  function clearSession() {
    authToken.value = ''
    currentUser.value = null
    window.localStorage.removeItem('account-token')
    window.localStorage.removeItem('account-user')
  }

  async function verifyStoredSession({ requireAdmin = false } = {}) {
    const storedToken = window.localStorage.getItem('account-token')

    if (!storedToken) {
      clearSession()
      return false
    }

    authHydrating.value = true

    try {
      const response = await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
        headers: authHeaders(storedToken),
      })
      const payload = await response.json().catch(() => ({}))

      if (!response.ok || (requireAdmin && !payload.user?.admin)) throw new Error()

      persistSession(storedToken, payload.user)
      return true
    }
    catch {
      clearSession()
      return false
    }
    finally {
      authHydrating.value = false
    }
  }

  async function logout() {
    if (authToken.value) {
      await fetch(`${config.public.apiBaseUrl}/api/v1/session`, {
        method: 'DELETE',
        headers: authHeaders(),
      }).catch(() => {})
    }

    clearSession()
  }

  return {
    authHeaders,
    authHydrating,
    authToken,
    clearSession,
    currentUser,
    logout,
    persistSession,
    verifyStoredSession,
  }
}
