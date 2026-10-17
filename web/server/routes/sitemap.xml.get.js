import { defineEventHandler, setHeader } from 'h3'
import { useRuntimeConfig } from 'nitropack/runtime'
import { INDEXABLE_PATHS, isSiteIndexable, siteOrigin } from '../../utils/seo'

export default defineEventHandler((event) => {
  const config = useRuntimeConfig(event)
  setHeader(event, 'Content-Type', 'application/xml; charset=utf-8')
  const paths = isSiteIndexable(config.public.siteIndexable) ? INDEXABLE_PATHS : []
  const origin = siteOrigin(config.public.siteUrl)
  const escape = value => value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;')
  return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${paths.map(path => `<url><loc>${escape(origin + path)}</loc></url>`).join('')}</urlset>`
})
