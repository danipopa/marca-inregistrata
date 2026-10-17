import { computed, ref } from 'vue'
import { useAnalytics } from './useAnalytics'

const cartItems = ref([])

function persistCart() {
  window.localStorage.setItem('cart-items', JSON.stringify(cartItems.value))
}

export function useCart() {
  const { trackEvent } = useAnalytics()
  function loadCart() {
    if (typeof window === 'undefined') return

    try {
      cartItems.value = JSON.parse(window.localStorage.getItem('cart-items') || '[]')
    }
    catch {
      cartItems.value = []
    }
  }

  function addCartItem(item) {
    cartItems.value = [...cartItems.value, item]
    persistCart()
    trackEvent('add_to_cart', { items: [item] })
  }

  function clearCart() {
    cartItems.value = []
    persistCart()
  }

  function removeFromCart(id) {
    cartItems.value = cartItems.value.filter(item => item.id !== id)
    persistCart()
  }

  const cartCount = computed(() => cartItems.value.length)
  const cartTotal = computed(() => cartItems.value.reduce((sum, item) => sum + Number(item.total || 0), 0))
  const cartCurrencies = computed(() => [...new Set(cartItems.value.map(item => item.currency || 'RON'))])

  return {
    addCartItem,
    cartCount,
    cartCurrencies,
    cartItems,
    cartTotal,
    clearCart,
    loadCart,
    removeFromCart,
  }
}
