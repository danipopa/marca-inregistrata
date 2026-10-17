# Google Analytics 4

## What is implemented

GA4 loads through a client-only Nuxt plugin, using the existing cookie-consent banner. It sends no Google tag request until there is a valid Measurement ID and affirmative consent for `2026-10-17-analytics-v2`. The version changed because this introduces a third-party analytics provider. DNT, Global Privacy Control, essential-only choices and blocked storage prevent initialization. Advertising storage, advertising user data, ad personalization and Google Signals are not enabled by this integration.

Page views are sent manually for the known public paths. Queries, fragments, customer names, trademark names/numbers, emails, phone numbers, descriptions and payment provider URLs/tokens are not forwarded by the application tracking code. Public page titles are fixed analytics labels. Referrers are limited to the referring origin. Explicit checkout/purchase actions from `/account` use `/checkout` as their analytics context, without account query parameters. The plugin suspends collection during route navigation and disables it on private/unknown routes. Google may still generate its standard lifecycle events after consent and tag loading; this is not a replacement for configuring the GA4 stream correctly.

The tag is not installed through Google Tag Manager, and no extra analytics dependency is required. Do not install another GA snippet or GTM GA tag alongside it.

## Owner setup required

1. Create/select a GA4 property and a **Web** data stream for `https://inregistrare-marca.com`. Copy its **Measurement ID**, in the form `G-XXXXXXXXXX`. This is not the Google OAuth client ID used for login; no API secret or Google password is needed.
2. **Disable Enhanced Measurement for this web stream**, including automatic page/history views, form interactions, site search, outbound links and downloads. The application sends its own safe events. `send_page_view: false` alone does not disable Enhanced Measurement's history listener. Keep it off to avoid duplicates and accidental automatic collection of URLs or form information.
3. Review the Google tag's automatic event-detection settings and leave unwanted automatic form/commerce event collection off. Use only the explicit events listed below for this application.
4. Keep Google Signals and advertising personalization off for this initial scope. Review the GA property retention, processing terms and privacy notice for the chosen configuration. The application sets GA cookie expiry to 90 days; that does not configure retention inside Google's servers.
5. Optionally link the verified Search Console property. Mark the desired lead/purchase events as key events and build a checkout funnel using the explicit events below.

## Environment and Kubernetes

```dotenv
NUXT_PUBLIC_ANALYTICS_PROVIDER=google
NUXT_PUBLIC_GOOGLE_ANALYTICS_ID=G-YOURREALID
NUXT_PUBLIC_GOOGLE_ANALYTICS_DEBUG=false
```

`auto` (local default) chooses GA4 when a valid ID is present, otherwise the previous first-party page-view tracker. `first-party` explicitly selects that tracker; `none` disables browser visitor tracking. These choices are mutually exclusive. Technical API metrics remain independent of the visitor provider.

Production `k8s/web-configmap.yaml` selects `google` and configures owner-provided Measurement ID `G-0V8E4ME4Y2`. This validates the ID format, not account ownership or the stream settings. **No GA collection occurs with an empty ID.** The development overlay explicitly selects `none` and clears the ID, so a production ID is not accidentally used on development. Use a separate GA4 test property for local QA rather than polluting production data.

These values are Nuxt public runtime config, not secrets. With a newly built image containing the plugin, an ID change only requires updating the web ConfigMap and restarting `marca-web`:

```sh
# First set the real ID in k8s/web-configmap.yaml and review that change.
kubectl apply -f k8s/web-configmap.yaml
kubectl rollout restart deployment/marca-web -n inregistrare-marca
kubectl rollout status deployment/marca-web -n inregistrare-marca
```

For the initial release, rebuild/deploy both API and web: the API payment verification response now supplies the product code and server order total/currency, and the cookie-policy version is coordinated with the first-party fallback endpoint. No new database migration is needed specifically for GA4. The earlier traffic migration is still needed if not deployed already.

Admin → Traffic points visitor reporting to Google Analytics when the Google provider is selected; it continues to display local technical API metrics. Existing first-party historical records are not imported into GA4 or deleted. Technical metrics do not depend on the Measurement ID.

## Event definitions

| Event | Trigger | Allowed business data |
| --- | --- | --- |
| `page_view` | Initial accepted public route / completed public navigation | Known page path/title and sanitized referring origin or previous public location |
| `generate_lead` | Contact API returns success | Fixed `form_name: contact`; no contact content |
| `add_to_cart` | Item added to local cart | Known catalog code/category, amount, currency, quantity |
| `begin_checkout` | Nonempty cart submitted after authentication/billing checks | Safe cart items and total for a single currency |
| `order_submitted` | Individual order API returns success | Safe server product code/total/currency; this is not payment confirmation |
| `purchase` | Authenticated payment verification API returns `verified: true` and order status `paid` | `order-<server ID>` transaction ID, server order total/currency, known catalog code |

Unknown product codes and invalid/negative amounts are dropped rather than forwarding arbitrary strings. Mixed-currency carts do not emit a combined value; individual order events can still be recorded. Item quantity currently reflects the application's one-item-per-cart-entry behavior. Totals are the business order amount/currency, not a separate computation of tax/net revenue or provider FX settlement.

Purchase events are deduplicated within the running page, through local storage after the Google event callback, and using the same GA4 transaction ID on retries. Callback invocation is not a delivery/ingestion guarantee. Blockers, lost connections, denied consent and customers not returning after payment can cause missed events. Bank-transfer orders are not purchases until paid, and the current manual/admin confirmation flow does not send GA4 purchase events. This is client-side ecommerce analytics, not financial reconciliation or guaranteed server-side delivery.

## Consent withdrawal and privacy notice

Cookie preferences remain accessible at the bottom of the page. Withdrawal sets the GA disable flag, updates consent to denied, attempts to delete `_ga`/`_ga_*` cookies on applicable host domains, and reloads an initialized page to discard the third-party runtime. The same preference is honored across tabs via storage events. No pending application conversion is replayed after a later acceptance; that would incorrectly count an action taken without consent.

The banner identifies Google Analytics and the possibility of processing outside the EEA when the Google provider is selected. Review/update the actual published privacy notice (including any custom admin-provided notice) to describe the provider, purposes, identifiers, retention, recipients/transfers as applicable, and how to withdraw consent. This repository does not certify legal compliance or accept Google processing terms on the owner's behalf.

## Validation

```sh
cd web
npm run test:analytics
npm run build
```

Use a separate test Measurement ID and `NUXT_PUBLIC_GOOGLE_ANALYTICS_DEBUG=true` for DebugView QA; keep debug off in production. Check browser Network and GA4 DebugView/Realtime after acceptance. Test essential-only, old policy, DNT/GPC, withdrawal, public navigation, private pages, failed/successful contact, cart/checkout and verified/unverified payments. Confirm automatic Enhanced Measurement is off in the GA4 UI; local tests cannot verify account-side settings or actual Google ingestion. Use supported payment-provider test mode for payment QA, not real production charges.

References: [Google consent-mode guide](https://developers.google.com/tag-platform/security/guides/consent), [manual page views and Enhanced Measurement](https://developers.google.com/analytics/devguides/collection/ga4/views), [ecommerce events](https://developers.google.com/analytics/devguides/collection/ga4/ecommerce).
