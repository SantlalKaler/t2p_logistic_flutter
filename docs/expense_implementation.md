# Expense module (API guide v1.2)

The existing dashboard entry now opens the `/v1` expense flow. It keeps the
project's GetX controller / Dio ApiService / domain models / shared widget layout.
Legacy COD and other admin API calls are separate and unchanged in behavior.

Implemented: seven category forms, own-expense list and filters/pagination,
detail/history and action permissions, draft/edit/submit/recall/cancel, direct
approval for cancelled-order food usage, private documents, and own cash ledger.
Food Purchase uses server-combined lines and signed quantity adjustments. API
money is converted between rupees on input and paise on output. Create retries
reuse one UUID per form; edits and applicable actions send the record version.

OTP verification persists the JWT in platform secure storage. Missing/expired
JWTs require login again. Old installed sessions need a fresh OTP login once the
backend returns the new `token`. The login allowlist includes the seven roles
in the guide; the expense tile is available in the existing dashboard lists.

## Local verification

Use the repository SDK (`.fvm/flutter_sdk/bin/flutter.bat` on Windows), not the
older Flutter on PATH.

In one terminal:

```powershell
postman simulation run postman/simulations/expenses.sim.yaml --port 4900 --output ndjson
```

In another:

```powershell
.fvm/flutter_sdk/bin/flutter.bat test --dart-define=EXPENSE_TEST_BASE_URL=http://127.0.0.1:4900/expenses
.fvm/flutter_sdk/bin/flutter.bat build apk --debug --no-pub
```

The API tests exercise the actual Dio client and ExpenseController over local
HTTP. The simulation uses synthetic fixtures derived from the supplied guide;
Postman's owner-workspace search was unavailable because the CLI was signed out.
The fixture models the tested paths only and responds 501 for unmodeled routes,
including document content handling. It is not evidence of a live backend test.
No workspace push, deployment, or production mutations are involved.

For an optional mobile-size form PNG, also pass `--dart-define=EXPENSE_CAPTURE=true`.
It writes `.codex/tmp/expense-petrol-form.png`.

## Live verification still needed

- Confirm the expense module has been deployed and OTP verification returns JWTs.
- Run the guide's release checklist with assigned orders and admin approval/rejection.
- Verify camera/gallery/PDF uploads, server content validation and private downloads
  on Android/iOS; those native operations are not exercised by headless tests.
- Android uses the existing google-services configuration. iOS currently has no
  GoogleService-Info.plist, so real iOS push needs Firebase/APNs provisioning.
  Keychain storage and camera/photo permission descriptions are configured.
- Notification routing handles foreground refresh, background taps and cold-start
  taps after dashboard navigation. The guide specifies `/app/update-token` but not
  its request schema; registration currently sends `user_id` and `device_token`
  as JSON. Confirm those two fields with the existing backend before push QA.
- The guide's sample meta omits CANCELLED_ORDER although it describes seven types.
  The app uses the actual meta category list; the backend must include that type
  for the cancelled-order form to be selectable.
- Delivery expenses remain zero-valued, and pickup default distance may be absent,
  as described by the guide. The server's returned amounts remain authoritative.

## Version 1.2 app updates

- Save draft and edit allow empty category fields while validating entered numeric
  values. Order references remain required for order-based categories.
- List/detail show Incomplete and editing highlights the server's missing fields;
  submit/approve validation messages include individual missing-field errors.
- Food Purchase supports purchase-wide GST, defaults from meta, percentage
  validation, estimated totals, saved GST restoration and legacy item-rate fallback.
  Missing rates remain blank when reopening a draft.
- Food orders linked to another expense open that record instead of being ticked.
  Delivery reuses an existing expense for the chosen side and displays delivery
  date/time slot. Date eligibility and search remain controlled by the server.
- Missing/deleted expenses refresh the list and cash balance. Deleted ledger rows
  display Deleted and do not open a missing record.

The new contract still needs verification against a deployed v1.2 backend,
including partial-draft persistence, GST rounding, order eligibility and deletion
cash reversals. Widget regression checks use an in-memory recording controller.

## Fixed GST and product cost UI

Food Purchase now displays unit rate multiplied by final quantity on each product.
A Yes (5%)/No GST dropdown appears before the discount fields. The API still has
one GST setting per purchase, so changing it updates every product. Yes sends
`gst_percent: "5"`; the editable percentage input has been removed. GST is
calculated after discount, consistently with the API contract. Editing older
purchases with another percentage now uses the requested fixed 5% on save.

## Order cities, delivery dates and calendar (October 2026)

Reviewed `T2P_Expenses_API_Guide.pdf` v1.2 before implementing these updates.
Sections 6.1 and 6.3 already document `vendor_city`, `order_city`,
`delivery_date` and `timeslot` on both expense order lookups.

- Delivery's order dropdown and selected-order summary show Purchase city
  (`vendor_city`), Delivery date and time slot for each order.
- Food Purchase's order dropdown (including orders linked to another expense)
  and selected-order summaries show Delivery city (`order_city`), Delivery date
  and time slot. Purchase city remains visible where supplied.
- Missing city names or dates show "Not available". No city is inferred from the
  user's profile, and city IDs are not displayed as names. Selected-order metadata
  is retained when searching for another order.
- Delivery dates are read-only order information. The existing calendar dropdown
  selects the expense date, with no future dates and the `meta.backdate_days`
  limit from section 3.3. Selecting a new expense date clears its previous server
  error; date inputs are disabled while loading or saving.
- Existing create/edit payloads are unchanged. The v1.2 saved expense examples
  only guarantee order IDs/numbers in `order_refs`; historical orders excluded
  from the lookups may therefore show unavailable city/date information when
  reopened for editing. Persisted metadata needs backend support.

Deferred until a revised backend contract is deployed: Intercity extra expenses
and revised totals; Delivery start/end addresses, routing, rate/km and payable
cost; multiple journey entries. The current contract still defines Intercity as
rate/kg times weight and Delivery as zero-valued (sections 6.2, 6.3 and 12).

Widget coverage verifies the per-order city/date mapping, missing metadata,
linked-order behavior, selection retention across searches, unchanged Delivery
save details, and calendar bounds/date persistence on a 390px-wide form.

Food Purchase dropdown items use bordered cards with spaced order details.
Selectable cards have a checkbox and a selected border; existing purchases show
a status badge, expense reference and an explicit Open expense button. Tapping
an existing order's title no longer navigates. The menu has more vertical room
while search and Apply remain fixed above and below the scrolling order list.
