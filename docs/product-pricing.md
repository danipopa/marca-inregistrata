# Product pricing by class count

Admin → Products groups products under OSIM and EUIPO, retaining the service categories inside each office. Other or multi-office products remain under **Alte servicii / oficii**. For standard registration/renewal codes, the office follows the product code even if older region metadata is inconsistent.

Each registration or renewal product has **Prețuri după numărul de clase**, available both in the full product form and in each product card's price form.

- Edit the existing base amount for **one class**. The display-price label remains separately editable, as before.
- For **2–11 classes**, enter an optional **total product price** in that product's currency, not a surcharge. Amounts use whole currency units, consistent with the existing base-price model.
- Blank fields use the existing base-plus-class calculation; the calculated amount appears as the placeholder. Clear a field and save to restore that calculation. Zero is an explicit price, not an empty value.
- Save with **Save price** (card) or **Save changes/Create product** (full form).
- The OSIM renewal owner-change option is added separately. Monitoring and verification services retain their service prices and do not expose a class-price table.

The catalog API returns the overrides and default surcharges. The order form uses these values, and the Rails API recalculates new orders from the same product configuration. Existing order totals/currencies stay unchanged during later status, payment, or comment updates. Explicitly changing an order's product, class count or owner-change option recalculates its price.

The migration adds a nullable JSON `trademark_products.class_prices` column, with empty defaults handled in Rails for MySQL compatibility. There are no new credentials or environment variables. Deploy both API and frontend together; the API entrypoint applies migrations via `db:prepare`.

For local development, run `cd api && bin/rails db:migrate` while the development MySQL tunnel is open, then restart Rails (or restart `./dev.sh`) so its schema cache sees the new column. The dedicated development MySQL database was migrated during implementation; production was not changed.
