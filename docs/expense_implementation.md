# Duty and expenses (App Update v1.4; Expenses API v1.5)

## Duty/expense update - November 3, 2026

Primary contract: App Update guide v1.4. Reference: Expenses API guide v1.5.

- Android now uses a sticky native location foreground service for GPS and upload,
  independent of Flutter UI lifetime. High-accuracy reads request 10-second updates,
  5-second minimum and zero distance filtering. Restart credentials are encrypted
  with Android Keystore. iOS retains continuous background location without pauses
  or distance filtering, requests fresh fixes every 10 seconds and triggers uploads
  from background location callbacks as well as the minute timer.
- Save after 30 m OR 30 s, including stationary fixes. SQLite retains original UTC
  timestamps/accuracy. Upload oldest first, at most 500 per request; only HTTP 200
  acknowledges rows. Drain a large backlog before OFF/actual km. Android can sync
  an offline Stop without Flutter: GPS stops immediately, upload-only service keeps
  the original Stop time, drains points and sends OFF. Server OFF stops recording.
  ON now includes accuracy; History retains pending actual-km entry.
- GST state/widget identity is keyed by product ID. Every item sends its own
  `gst_applicable`; saved rows use their own `gst_rate_bp`. No purchase-level GST.
- Attachments have no total-count cap, including with stale five-file metadata.
  Forms select documents before save; create a draft with the first 10, upload the
  remainder in batches of 10, then submit. Partial failures retain the draft ID,
  latest version and remaining handles while the form stays open. Successful
  batches are not repeated on retry. File data streams rather than loading the
  entire selection into memory. Existing draft detail uploads use batches too.
- Petrol Start/End readings are optional, omitted when blank, support zero and
  one decimal; End below Start is refused when both exist. `end_km` is restored,
  submitted and displayed.
- Payment OCR sends one image under `file`, no PDF, at most 10 MB, with a three-minute
  timeout. Exact server success/error messages survive, including generic 500
  messages and JSON envelopes returned as text. Cash refreshes after success/409.

### Section 1 screen inventory

| Screen / capability | Current source status |
| --- | --- |
| Food Purchase | Implemented; per-product GST and document batches |
| Pickup / Delivery lists | Total Duty and per-order controls integrated |
| Duty ON popup | Address confirmation integrated; accuracy sent |
| Duty OFF / Actual km | Implemented; pending points precede finalization |
| Background tracking | Native Android service and iOS flow implemented; device acceptance pending |
| Delivered integration | Successful matching-order delivery stops duty; total duty stays ON |
| Duty History | Addresses, system/actual km, rate, payable and pending km entry integrated |
| My Cash | Ledger and screenshot dialog integrated; server messages preserved |

No app route-map screen is required; the map belongs to Super Admin.

### Verification and Section 9 acceptance

Full Flutter suite: **127 passed**, including all **11** expense HTTP tests against
the local Postman simulation (no skips). Android JVM recording-policy tests:
**2 passed**. Final targeted analyzer: **no issues**. The updated Android debug APK
built successfully at `build/app/outputs/flutter-apk/app-debug.apk`.

| Checklist | Automated evidence | Remaining device/live acceptance |
| --- | --- | --- |
| 1-4, Food Purchase | Aggregation, blank prices, independent mixed GST, reopen and previews | Deployed totals and saved-draft round trip |
| Documents / Petrol | 15 files; 25-file partial failure/retry; stale five-file metadata; no/one/both km; invalid End | Real file storage and backend 422 validation |
| 5-6, 11-14, Duty UI | Confirmation/cancel, duty state rules, GPS-optional/repeated Stop, History, actual-km errors/pending entry | Deployed permissions, configured km limits and payable |
| 7-10, lifecycle/offline | Restored state, failed/retried queue batches and original timestamps | Kill/reopen, locked travel, airplane mode and server point deduplication |
| 15-18, tracking | Android/Dart 30 m policy, ten stationary heartbeats in five minutes, 500+ batching | Physical round trip, turns, locked stop, long offline and Super Admin map |
| 19-22, Delivered | Matching-order stop; total/other duty preservation; closed-status handling | Customer OTP success/failure and deployed list buttons |
| 23-29, Cash | Synthetic OCR success/409/422/500 UI, cash refresh, expense debit/reversal simulation, negative balance display | Real bank OCR, sender/date rules, DUTY_DEBIT, zero rate and low-balance payout |

Policy tests do not simulate physical screen lock or road travel. No production
expense, payment or duty transaction was created. iOS build/device verification
requires macOS/Xcode and an iPhone and has not been run from this Windows workspace.

Reproduce with the pinned SDK:

```text
postman simulation run postman/simulations/expenses.sim.yaml --port 4901 --no-history
.fvm/flutter_sdk/bin/flutter.bat test --no-pub --dart-define=EXPENSE_TEST_BASE_URL=http://localhost:4901/expenses
cd android
gradlew.bat :app:testDebugUnitTest
```

Logs: `tmp/duty-expense-full-tests.log`, `tmp/duty-native-tests.log`,
`tmp/duty-expense-update-analysis.log`, `tmp/duty-expense-update-build.log`.

## Expense review fixes (November 2026)

- Filling and journey date controls display and clear their field errors.
  Cancelled-food usage errors appear beside the affected entry and inside its
  edit dialog. Food adjustments and usage entries can be edited in place,
  including incomplete drafts. Quantity limits exclude the entry being replaced.
- Food GST previews and the Yes label use `meta.gst_rate_percent` (5% fallback).
  Each product still sends only its own `gst_applicable`; saved totals remain
  authoritative server values.
- Payment OCR has a separate cooldown from other expense requests. It honors
  `Retry-After`, defaults to 60 seconds without it, and displays a retry countdown.
  Balance/list requests remain available during a payment cooldown. There is no
  automatic upload retry.
- Editable expenses with `actions.submit` offer Save and submit. The app first
  PATCHes full details, then submits using the returned version. If submission
  fails, the saved draft and its new version are retained and field errors are
  shown. Cancelled Orders continue to use their separate approval action.

The backend must return `CANCELLED_ORDER` in metadata for that form to appear.
The guide's general claim that app users never receive `actions.approve` has a
documented exception for Cancelled Orders; the app follows returned actions.
Real OCR, private file handling, cash reversals and push still need device/live
backend verification.

## November 2026 expense update (API guide v1.4)

Food Purchase uses independent `items[].gst_applicable` values (Yes = 5%).
Saved rows restore GST from their own `gst_rate_bp`; purchase-level GST summaries
are ignored and no purchase-level GST fields are sent. New product prices start
blank, line order is preserved, and weight, discounts and quantity changes sit
under More. Each row shows quantity, price, GST and its total, followed by the
purchase subtotal, discount, tax and grand total. Saved details show each row's
GST choice and use the server's totals.

My Cash has an Upload payment screenshot button. It accepts one JPG, PNG, WEBP or
HEIC image up to 10 MB and posts multipart `file` to `/v1/ocr/payment-bill` with
a three-minute send/receive timeout. Confirmation shows the rupee amount,
reference and sender; closing confirmation refreshes the server ledger. A 409
shows the server message and offers a balance refresh. Refused screenshots are
not automatically resent; network/service failures allow manual retry.

Duty implementation is deferred. Native image picking and the deployed OCR
endpoint still need device/live verification. Local tests cover mixed GST,
blank-price drafts, upload limits, success, duplicate handling, retries and the
authenticated request contract. The older implementation notes below describe
earlier versions; their purchase-wide GST behavior is superseded by this update.

## Original expense implementation

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
