import assert from 'node:assert/strict'
import test from 'node:test'
import { MAX_NICE_CLASSES, filterNiceClasses, formatNiceClassSelection, normalizeNiceClassNumbers } from '../utils/niceClassSelection.js'

test('selections use stable unique class numbers with the current pricing limit', () => {
  assert.deepEqual(normalizeNiceClassNumbers([35, 9, 35, 42, 0, 46, '4', 2.5, null]), [9, 35, 42])
  assert.deepEqual(normalizeNiceClassNumbers(null), [])
  assert.equal(normalizeNiceClassNumbers(Array.from({ length: 45 }, (_, index) => index + 1)).length, MAX_NICE_CLASSES)
})

test('search supports exact class numbers, descriptions, case and Romanian diacritics', () => {
  const classes = [
    { number: 1, label: 'Clasa 1: Chimie', detail: 'Îngrășăminte pentru agricultură', typeLabel: 'Produse' },
    { number: 11, label: 'Clasa 11: Iluminat', detail: 'Aparate electrice', typeLabel: 'Produse' },
    { number: 35, label: 'Clasa 35: Publicitate', detail: 'Administrarea afacerilor', typeLabel: 'Servicii' },
  ]
  assert.deepEqual(filterNiceClasses(classes, '1').map(item => item.number), [1])
  assert.deepEqual(filterNiceClasses(classes, ' 35 ').map(item => item.number), [35])
  assert.deepEqual(filterNiceClasses(classes, 'INGRASAMINTE agricultura').map(item => item.number), [1])
  assert.deepEqual(filterNiceClasses(classes, 'clasa servicii').map(item => item.number), [35])
  assert.deepEqual(filterNiceClasses(classes, 'missing'), [])
  assert.equal(filterNiceClasses(classes, ''), classes)
})

test('cart and API class descriptions retain all selected numbers within the existing column size', () => {
  assert.equal(formatNiceClassSelection([42, 9, 35, 9]), 'Clasa 9; Clasa 35; Clasa 42')
  assert.equal(formatNiceClassSelection([42, 9, 35], 'en'), 'Class 9; Class 35; Class 42')
  assert.equal(formatNiceClassSelection([]), '')
  assert(formatNiceClassSelection(Array.from({ length: MAX_NICE_CLASSES }, (_, index) => index + 35)).length < 255)
})
