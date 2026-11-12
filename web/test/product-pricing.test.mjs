import assert from 'node:assert/strict'
import test from 'node:test'
import { classPriceDraft, defaultClassTotal, productClassTotal, productOffice, serializeClassPrices, supportsClassPricing } from '../utils/productPricing.js'

test('office grouping follows product codes and keeps other offices separately', () => {
  assert.equal(productOffice({ code: 'eu-word', region: 'OSIM' }), 'EUIPO')
  assert.equal(productOffice({ code: 'renew-eu-color', region: 'OSIM' }), 'EUIPO')
  assert.equal(productOffice({ code: 'renew-ro-word', region: 'EUIPO' }), 'OSIM')
  assert.equal(productOffice({ code: 'custom', region: 'RO' }), 'OSIM')
  assert.equal(productOffice({ code: 'custom', region: 'WIPO' }), 'other')
})

test('class prices are absolute totals, with base and legacy defaults retained', () => {
  const product = { code: 'ro-word', base_lei: 1000, class_prices: { 2: 1800, 3: 0 } }
  assert.equal(productClassTotal(product, 1), 1000)
  assert.equal(productClassTotal(product, 2), 1800)
  assert.equal(productClassTotal(product, 3), 0)
  assert.equal(productClassTotal(product, 4), 1762)
  assert.equal(defaultClassTotal(product, 4, 2000), 2762)
  assert.equal(productClassTotal(product, 0), 1000)
})

test('catalog surcharge data takes precedence and EUR products keep their own amounts', () => {
  assert.equal(defaultClassTotal({ code: 'ro-word', baseLei: 1000, class_surcharges: { 2: 300 } }, 2), 1300)
  const product = { code: 'renew-eu-word', currency: 'EUR', base_lei: 850, class_prices: { 3: 1200 } }
  assert.equal(productClassTotal(product, 2), 900)
  assert.equal(productClassTotal(product, 3), 1200)
  assert.equal(productClassTotal(product, 11), 2250)
})

test('non-class services do not get class pricing', () => {
  assert.equal(supportsClassPricing({ code: 'monitoring-brand' }), false)
  assert.equal(supportsClassPricing({ code: 'verification-brand' }), false)
  assert.equal(productClassTotal({ code: 'monitoring-brand', base_lei: 726, class_prices: { 2: 1 } }, 2), 726)
})

test('price drafts preserve zero and empty fields reset overrides', () => {
  const draft = classPriceDraft({ class_prices: { 2: 0, 3: 2800 } })
  assert.equal(draft[2], 0)
  assert.equal(draft[4], '')
  assert.deepEqual(serializeClassPrices(draft), { 2: 0, 3: 2800 })
  draft[3] = ''
  assert.deepEqual(serializeClassPrices(draft), { 2: 0 })
  assert.deepEqual(serializeClassPrices(classPriceDraft({})), {})
  assert.deepEqual(serializeClassPrices({ 2: '2800.00' }), { 2: 2800 })
  for (const invalid of [{ 1: 100 }, { 12: 100 }, { 2: '-1' }, { 2: '1.5' }, { 2: 'not a price' }]) assert.throws(() => serializeClassPrices(invalid))
})
