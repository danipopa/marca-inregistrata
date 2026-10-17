# Website traffic and SEO

## Visitor analytics provider

GA4 is now the selected production visitor provider with owner-provided Measurement ID `G-0V8E4ME4Y2`, pending deployment and account-side stream configuration. See [Google Analytics setup](google-analytics.md) and the staged [SEO plan](seo-plan.md). The existing first-party visitor tracker remains available explicitly or as the local `auto` fallback; it is not run alongside GA4. Admin → Traffic continues showing technical metrics, while visitor reporting moves to GA4 when selected. The sections below describing first-party visitor counts apply only while that provider is enabled.

## Traffic dashboard

After deploying both new images and preparing the Rails database, open `/admin` and choose **Traffic**. The endpoint is protected by the same admin login and MFA as other admin sections.

The dashboard offers 7, 30, or 90 days of:

- Unique visitor identifiers, browser sessions, page views, daily views, popular pages, and referring hostnames.
- API request totals, 4xx and 5xx totals, average and maximum response time, and busiest controller actions.

A visitor means one accepted consent identifier, not a verified person. Different browsers/devices count separately. Sessions use sessionStorage, expire after 30 minutes of inactivity, and are separate per tab. The referrer is the external document referrer associated with a view; it is not a campaign attribution or acquisition model. Query strings and fragments are never sent. Reports use the Rails application timezone (currently UTC). Unique totals cover the entire selected range, rather than summing daily unique counts.

Counts start when deployed. No historical traffic is imported. Browser tracking requires affirmative consent for policy `2026-10-17-analytics-v2`; existing visitors will see the updated banner. Essential-only choices, Do Not Track and Global Privacy Control prevent browser tracking. Visitors can reopen cookie preferences at the bottom of the page. Only known public form/content paths are accepted; account, admin, password-reset, and arbitrary paths are excluded. Basic user-agent bot filtering and a per-consent limit of 120 events/hour reduce noise; these are not a bot firewall. Client-submitted events can be blocked, spoofed, or lost and are not an accounting source.

Analytics stores HMAC-derived visitor/session identifiers, public paths, referring hostnames, and server timestamps. It does not add IP addresses, user agents, form contents, or full referrer URLs to analytics tables. Existing consent-proof and order records retain their pre-existing behavior. Keep the published privacy notice consistent with the actual configuration.

Technical API metrics run independently of browser analytics. Buckets store controller/action, response status, counts and total/max duration, without URLs, identifiers, query strings or request bodies. Health checks, OPTIONS, tracking events and dashboard polls are excluded. Durations measure application response creation, not full socket transfer. Metric failures are logged without breaking the request. API metrics do not include files served directly by the proxy, Nuxt, or ingress-rejected requests.

`PruneTrafficMetricsJob` deletes analytics and API buckets older than 90 calendar days. Solid Queue schedules it daily at 03:00 in production. Development without a recurring worker can run `bin/rails runner 'PruneTrafficMetricsJob.perform_now'` explicitly. Database backups and Kubernetes logs have separate retention policies.

## Web requests, errors, and bandwidth

Nuxt emits a sanitized JSON `web_request` record after responses, with method, status, normalized public path, and duration. Content-Length is logged when present; it is not a reliable measure of actual bandwidth. Unknown routes and asset filenames are collapsed into categories. No IPs, query strings, bodies, authentication headers, or referrers are included in these records. Nuxt's own framework error logs are separate.

Inspect and summarize recent web-server traffic:

```sh
kc logs -n inregistrare-marca deployment/marca-web --since=1h --all-pods=true --prefix | python3 deploy/traffic_report.py --source web
```

The development Nginx gateway emits `gateway_request` JSON logs with actual bytes sent (including response headers), status, normalized path, and total request duration:

```sh
kc logs -n inregistrare-marca deployment/marca-gateway --since=1h --all-pods=true --prefix | python3 deploy/traffic_report.py --source gateway
```

The log summary reports requests, server errors, average/max duration, bytes, status distribution, and busiest paths. Do not add gateway and web counts together: they observe overlapping requests. These commands use retained pod logs, not durable historical metrics. `--all-pods=true` requires a recent kubectl; on older clients use `-l app.kubernetes.io/name=marca-web --max-log-requests=10` (web), or `-l app=marca-gateway` (gateway).

Production routes through the existing ingress instead of `marca-gateway`. Actual production edge bandwidth and ingress errors must be read from that ingress controller's access logs/metrics; this change does not reconfigure the shared controller. There are no external uptime probes or automated alerting rules in this implementation. The `/up` readiness/liveness checks remain available. For durable edge metrics or alerts, connect the cluster's ingress monitoring/log aggregation separately.

## SEO configuration

Production canonical origin comes from the existing ingress: `https://inregistrare-marca.com`.

- `NUXT_PUBLIC_SITE_URL=https://inregistrare-marca.com` controls canonical URLs and sitemap entries; it is configurable at container runtime.
- `NUXT_PUBLIC_SITE_INDEXABLE=true` enables indexing on production. Default/local behavior is false; the development overlay explicitly sets false.
- SSR metadata adds description, canonical URL, HTML language, Open Graph, Twitter card, and Organization/WebSite JSON-LD on the home page. Existing page titles remain in use.
- `/sitemap.xml` includes the home page and the two public legal documents. Transactional forms are not separate service landing pages.
- `/robots.txt` advertises the production sitemap. Private/form pages return `noindex, follow` metadata and headers. They are not blocked in production robots.txt, so crawlers can read noindex. This is not an access-control mechanism.
- Development has `Disallow: /`, an empty sitemap, and noindex headers. Keep it private using network/authentication controls as appropriate.
- Romanian and English metadata follow the current language selection. Language selection currently uses the same URL and browser storage; separate English URLs and hreflang have deliberately not been invented. Search engines primarily see the default Romanian SSR content.

This establishes technical SEO foundations; it does not promise search ranking, crawl acceptance, or a Core Web Vitals score. Further SEO work can add substantive, reviewed service landing pages, language-specific URLs, and measured performance improvements. The site already has a home H1 and section H2 elements. Content/prices loaded after mount may require JavaScript rendering; this change does not claim all catalog data is server-rendered.

## Google Search Console

The domain owner must add and verify a Search Console domain property, normally through its DNS TXT record. No Google credentials or verification tokens have been added. Once the production changes are live, submit `https://inregistrare-marca.com/sitemap.xml`, inspect the home URL, and monitor indexing, search queries, impressions, clicks, and Core Web Vitals. Search Console metrics are separate from the first-party Traffic dashboard.

Google documentation: [developer SEO guide](https://developers.google.com/search/docs/fundamentals/get-started-developers), [JavaScript SEO](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics).

## Release

1. Run the Rails tests and Nuxt production build.
2. Build and publish both images using a versioned tag.
3. Deploy the updated web ConfigMap and deployments; the Rails entrypoint runs `db:prepare` for the new tables. For local development, run `bin/rails db:migrate` against the configured development database.
4. For the development gateway logging change, apply the updated gateway ConfigMap and restart `marca-gateway` (Nginx does not automatically reload mounted configuration).
5. Confirm public metadata, production/development robots behavior, and a consented page view in Admin → Traffic. Technical counters will appear independently as API requests arrive.

No production deployment is performed merely by editing these files.
