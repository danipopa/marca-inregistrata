export const MAX_NICE_CLASSES = 11

export function normalizeNiceClassNumbers(values) {
  if (!Array.isArray(values)) return []
  return [...new Set(values.filter(value => Number.isInteger(value) && value >= 1 && value <= 45))]
    .sort((a, b) => a - b).slice(0, MAX_NICE_CLASSES)
}

function searchable(value) {
  return String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()
}

export function filterNiceClasses(classes, query) {
  const search = searchable(query).trim()
  if (!search) return classes
  if (/^\d+$/.test(search)) return classes.filter(item => item.number === Number(search))
  const words = search.split(/\s+/)
  return classes.filter((item) => {
    const text = searchable(`${item.number} ${item.label} ${item.detail} ${item.typeLabel}`)
    return words.every(word => text.includes(word))
  })
}

export function formatNiceClassSelection(numbers, language = 'ro') {
  const selected = normalizeNiceClassNumbers(numbers)
  if (!selected.length) return ''
  return selected.map(number => `${language === 'ro' ? 'Clasa' : 'Class'} ${number}`).join('; ')
}
