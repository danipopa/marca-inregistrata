import { defineEventHandler, setHeader } from 'h3'
import { useRuntimeConfig } from 'nitropack/runtime'
import { isSiteIndexable, siteOrigin } from '../../utils/seo'

export default defineEventHandler((event) => {
  const config = useRuntimeConfig(event)
  setHeader(event, 'Content-Type', 'text/plain; charset=utf-8')
  if (!isSiteIndexable(config.public.siteIndexable)) return 'User-agent: *\nDisallow: /\n'
  // Keep private pages crawlable so crawlers can see their noindex directives.
  return `User-agent: *\nDisallow: /api/\nSitemap: ${siteOrigin(config.public.siteUrl)}/sitemap.xml\n`
})
