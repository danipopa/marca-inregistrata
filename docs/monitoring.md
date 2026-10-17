# Trademark monitoring

Customers order monitoring from the homepage with the mark's name, registration
number and OSIM/EUIPO/WIPO office. These values are stored as structured order
fields and copied to a dedicated `MonitoringSubscription` after order creation.

New subscriptions await payment or explicit admin approval. Verified payment
(`paid`, `processing`, or `completed`) activates a complete subscription for one
year. Subsequent order updates do not extend the term or undo an admin pause.
Refunded/cancelled orders cancel monitoring. Expired/cancelled subscriptions need
a new order; resuming a paused subscription preserves its original expiry.

## Admin and customer screens

The admin sidebar's **Monitoring** page lists subscriptions, the provider state,
and the last/next check. Admins can correct registration details, approve, pause,
resume, cancel, change the interval (6–720 hours), enable notifications, run a
manual check, inspect history, and classify matches as pending/relevant/dismissed.
Approval does not mark an unpaid order as paid.

Customer order history shows monitoring status and the registration identifier.
Older orders without structured registration details appear after the scheduler
backfill and require an admin to fill in identification before activation.

## Scheduling and results

Solid Queue dispatches `ScheduleMonitoringChecksJob` every 15 minutes. Each active
subscription defaults to a check every 24 hours. `CheckTrademarkJob` rechecks
eligibility under a database lock and claims a 15-minute lease, so duplicate jobs
do not issue parallel checks. Expired worker leases are recoverable. A paused or
expired subscription cannot accept results from an already-running request.

Checks preserve their outcome, provider, timestamps, result counts and error
category. Provider failures schedule exponential backoff (5 minutes–6 hours),
while explicit provider rate limits delay the next attempt. Manual checks cannot
bypass failure backoff. Match identities combine provider, office and stable
provider ID, so repeat results update `last_seen_at` without duplicating alerts.

Pending matches go to the admin review queue. Marking a match relevant queues a
customer email; dismissed/pending matches do not trigger alerts. Monthly reports
include completed/failed check counts, relevant matches and the count awaiting
review. Reports without any recorded checks are not sent. Notifications honour
the subscription's preference and active term. SMTP must be configured to deliver
email. Email jobs retry delivery failures; as with ordinary SMTP, a process crash
after delivery but before recording delivery can cause a duplicate notification.

## Provider access is deliberately not enabled

The current default is **Awaiting API configuration**. The scheduler does not
call the TMview website endpoint or manufacture successful checks. Only tests
use an in-memory fake provider. Registering API credentials alone does not turn
on monitoring: no approved live adapter is included yet.

When EUIPO approves the product and coverage:

1. Implement an adapter registered in `TrademarkMonitoring::Provider::ADAPTERS`.
   It must implement `name`, `configured?`, and `search(subscription:)`.
2. Fetch all result pages for the agreed search criteria before returning a result
   set. Search the registration to resolve its identity/classes, and separately
   search for potential conflicting marks. Confirm coverage of each office;
   never label an unsupported office as successfully monitored.
3. Return an array of symbol-keyed hashes with non-empty string `id`, `name` and
   `office`, optionally `status`, `application_number`, `registration_number`,
   `source_url`. IDs must remain stable between checks. `[]` must mean a completed
   successful search with no matches, not authentication failure or incomplete data.
4. Use request timeouts shorter than the worker lease, refresh access tokens, obey
   subscription quotas and response retry headers, and raise `Provider::Error`
   for failed/incomplete requests or `Provider::RateLimited` with `retry_after`.
5. Keep credentials in the API Kubernetes Secret. Validate the adapter against the
   official sandbox with its actual OpenAPI spec and representative responses.
6. Set `TRADEMARK_MONITORING_PROVIDER` to the registered adapter name and
   `TRADEMARK_MONITORING_ENABLED=true` only after integration tests pass.

## Database and workers

Run `bin/rails db:migrate` against the development database after updating the
checkout. Production's existing Docker entrypoint runs `db:prepare` on startup.
Production already runs the Solid Queue supervisor through Puma with
`SOLID_QUEUE_IN_PUMA=true`; queue workers consume all queues, including
`monitoring` and `mailers`. With separate workers, use `bin/jobs` and keep its
recurring scheduler enabled. Plain local Rails development does not itself run
the production recurring schedule.

Tests use the isolated SQLite test database:

```bash
cd api
RAILS_ENV=test bin/rails db:prepare
PARALLEL_WORKERS=1 RAILS_ENV=test bin/rails test
```
