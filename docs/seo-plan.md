# SEO plan — inregistrare-marca.com

## Outcome and baseline

The business goal is qualified trademark enquiries and paid service orders. Organic visits alone are not the success criterion. Primary market: Romanian-language searches in Romania; EUIPO/WIPO services need their own clearly explained scope. Keyword groups below are research candidates, not verified search volumes or promised rankings.

Technical foundations exist in the working tree: SSR descriptions/canonicals/language tags, Organization/WebSite structured data, sitemap/robots routes, and noindex for transactional/private pages. These changes still need deployment. Current sitemap has three pages: home and two legal documents. Most services share one home page; product/pricing data and custom theme/legal content load after mount. English is currently a browser-language switch on the same URL, not a separate indexable English site. Automated trademark-monitoring coverage must not be promised while the provider is unconfigured.

GA4 integration is implemented with owner-provided Measurement ID `G-0V8E4ME4Y2`; activation still requires deployment and the GA4 stream configuration in [google-analytics.md](google-analytics.md). Search Console ownership has not been verified by this code change. No ranking, backlink or speed baseline has been measured here.

## Priorities and ownership

| Stage | Work | Owner | Definition of done |
| --- | --- | --- | --- |
| Week 1 — measurement and indexing | Create GA4 web stream; configure consent and Enhanced Measurement; verify Search Console domain; deploy metadata/sitemap changes; test events | Site owner + developer | Production public pages return indexable 200 responses; sitemap accepted; one consented navigation creates one page_view; a provider-verified test payment creates one purchase |
| Weeks 1–2 — baseline and research | Export initial Search Console pages/queries; inspect key URLs; measure mobile lab performance; record available field Core Web Vitals; research Romanian query groups and actual competitors | SEO/content owner | Dated baseline with non-brand clicks, impressions, CTR, landing pages, lead/purchase counts and performance issues; prioritized query-to-page map |
| Weeks 2–4 — core service pages | Write and review registration, verification, renewal and monitoring landing pages; add crawlable navigation; render useful main content on the server | Content owner + IP specialist + developer | Four substantive pages published with unique H1/title/description, canonical, useful CTA, internal links and sitemap entries; no copied thin office variants |
| Weeks 4–6 — supporting content and performance | Publish the first useful supporting guides; fix measured image/font/JS/rendering bottlenecks; improve trust/contact details | Content owner + developer | First reviewed guides are linked to services; before/after performance measurements; key content visible in initial HTML |
| Weeks 7–8 — review and improve | Review indexing, actual queries, page CTR and conversion paths; improve pages getting impressions without qualified enquiries | SEO/content owner + developer | Written review of what was changed, actual data and next priorities; no claims of success based only on average position |
| Ongoing — monthly | Check indexing regressions, broken links, payment/lead event health, content accuracy and real enquiries | Site owner | Monthly report with named next actions and the same comparison periods |

Timings are a proposed sequence, not a guarantee that Google will crawl, index or rank pages on that schedule. One person can fill multiple owner roles.

## Landing pages and search intent

Retain the home page as the broad brand/service overview. It should summarize the offer and link to the detailed service pages. Keep `/order?code=...` as noindex transaction flows; those URLs should not compete with service pages.

| Proposed URL | Main query candidates | Page purpose and useful content | Primary CTA |
| --- | --- | --- | --- |
| `/servicii/inregistrare-marca` | înregistrare marcă, înregistrare marcă OSIM, înregistrare marcă EUIPO | Explain territorial scope, verbal/logo options, NISA classes, required information, stages, professional fees vs official fees, and realistic limitations | Choose the appropriate registration service |
| `/servicii/verificare-marca` | verificare marcă, verificare disponibilitate marcă | Explain what a search can assess, offices/territories covered, information needed and what the customer receives; distinguish a search from a guarantee of registration | Request a trademark verification |
| `/servicii/reinnoire-marca` | reînnoire marcă, reînnoire marcă OSIM, reînnoire marcă EUIPO | Explain identification of the existing mark, offices supported, class selection, documents and the actual renewal service offered | Choose the appropriate renewal service |
| `/servicii/monitorizare-marca` | monitorizare marcă, supraveghere marcă | Explain the monitoring request, office/registration number, scope, review process, reporting and activation conditions; state available coverage honestly | Request monitoring |

Do not invent search volumes, exact legal deadlines, official fees, protection guarantees, or automated coverage. The IP specialist must check substantive legal/service claims against current official OSIM/EUIPO/WIPO information before publication. Include the actual responsible professional/organization and keep contact/business details consistent.

Suggested title patterns, to validate against actual content:

- Home: `Înregistrare marcă OSIM și EUIPO | SANDU și Asociații`
- Registration: `Înregistrare marcă la OSIM și EUIPO | SANDU și Asociații`
- Verification: `Verificare disponibilitate marcă | SANDU și Asociații`
- Renewal: `Reînnoire marcă OSIM și EUIPO | SANDU și Asociații`
- Monitoring: `Monitorizare marcă | SANDU și Asociații`

Use one descriptive H1 per page, logical H2s and a concise, unique description that matches the actual offer. Avoid stuffing office names into every heading. Prices shown in content must remain synchronized with the real catalog; do not publish fixed prices in prose without an update process.

## Supporting content

Start with questions the business actually receives and validate wording using Search Console and customer enquiries:

1. Choosing the territory: OSIM, EUIPO and WIPO routes, with their differences explained accurately.
2. Understanding NISA classes using concrete product/service examples.
3. What a trademark availability check does and does not establish.
4. Preparing for renewal: information and documents to gather.
5. What monitoring reports mean and when professional review is needed.

Each article should answer a distinct question, name the reviewer, show a meaningful review date, cite current primary sources for legal claims and link to the relevant service. Create real examples with permission or use clearly fictional examples. Do not publish fabricated testimonials, case studies or ratings. Prefer a small number of useful pages over mass-generated variants by city or office.

## Technical implementation backlog

1. Server-render service descriptions, headings and usable links. If prices/legal content are essential to the page, fetch them server-side with controlled caching and graceful fallbacks rather than relying solely on `onMounted`.
2. Add each approved service page to the central indexable path list, sitemap, SEO metadata and crawlable navigation. Coordinate analytics' safe path/title allowlist and web noindex headers at the same time; otherwise a new page can accidentally remain noindex or unmeasured.
3. Check canonical host/protocol handling across HTTP/HTTPS and www/non-www. If needed, add a tested permanent redirect while preserving API behavior and certificate issuance. Do not introduce a redirect loop.
4. Inspect mobile performance before changing assets. Prioritize the actual LCP element, correct image sizes/formats, below-the-fold lazy loading, font loading and excess JavaScript. Test forms and language selection after changes.
5. Use truthful structured data for the organization and visible service content. Add BreadcrumbList where real breadcrumbs exist. Do not add fake review stars or assume FAQ markup will receive rich results.
6. Keep admin/account/checkout/order/reset pages out of the sitemap and noindex. Keep them crawlable where necessary to let crawlers see noindex; authentication is the access control.
7. If English organic search becomes a business priority, introduce stable `/en/...` URLs with equivalent reviewed translations, SSR language, self-canonicals and reciprocal hreflang. Do not point hreflang at a localStorage language state or canonicalize all English pages to Romanian.
8. Validate real 404 status codes, broken links, accidental noindex and structured-data output after releases. Development must stay non-indexable.

## Measurement

Search Console: track organic clicks, impressions and CTR by query and landing page, indexed/canonical status of important pages, and available Core Web Vitals. Keep branded and non-branded search separate. Average position is contextual, not the sole KPI.

GA4: track `generate_lead` for successful contact submissions, `add_to_cart`, `begin_checkout`, custom `order_submitted`, and `purchase` only after a successful server-side payment verification. Mark `generate_lead` and `purchase` as key events as appropriate; do not treat a cart addition, bank-transfer order submission or unverified payment-return query as a completed purchase. Configure the required ecommerce reports/explorations and compare actual business enquiries/orders alongside GA4.

Consent and blockers mean GA4 will not observe every visitor or sale. Client-side purchases miss customers who never return from the provider, refuse analytics or have tracking blocked. Bank-transfer confirmations/admin updates are not currently sent as GA4 purchases. Do not reconcile GA4 revenue as if it were the financial ledger. Search Console clicks and GA4 sessions are different measurements and should not be expected to match exactly.

At baseline, record the previous 28 days where available. Review the latest 28 days against the prior period and, later, the comparable period a year earlier. With small samples, review 90 days and individual enquiries. Set numerical targets after the baseline and after checking actual capacity, budget and search demand; no percentage growth target is invented here.

## First production acceptance check

- Domain ownership verified in Search Console, sitemap submitted, public home inspected.
- GA4 Measurement ID configured; Enhanced Measurement disabled; Google Signals and unwanted advertising features off for this scope.
- No Google tag request before consent, on essential-only choice, or under DNT/GPC. Revocation stops subsequent events.
- One page_view per public route navigation; no query strings/customer form content in payloads; no private-page page_view.
- A successful contact submission produces one lead event; rejected submissions do not.
- A provider-verified test purchase uses the server order ID/total/currency and is deduplicated. No purchase event for cancellation, failed verification or pending bank transfer.
- Production public pages indexable; development excluded; admin/account/form pages noindex; sitemap contains only intended public pages.

## Primary references

- [Google SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)
- [Sitemap guidance](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)
- [JavaScript SEO](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)
- [Core Web Vitals and search](https://developers.google.com/search/docs/appearance/core-web-vitals)
- [Search Console and Analytics together](https://developers.google.com/search/docs/monitor-debug/google-analytics-search-console)
