# App update implementation

Contract: `T2P_App_Update_Guide.pdf`, version 1.1.

## Implemented

- A single permanent GetX DutyController owns total/order duty state across
  dashboard and pickup/delivery lists. Order controls are limited to pickup and
  delivery roles. Terminal orders cannot start duty; other orders are disabled
  while a session runs. Existing order Start actions remain separate.
- `/v1/duty/me`, `/on`, `/off`, `/points`, and `/history` reuse bearer-token API
  handling. Requests never send a user ID. HTTP 429 respects Retry-After.
- The SQLite outbox stores session state, Stop intent and GPS points, scoped to
  the logged-in account. Point identity is owner/session/original UTC timestamp.
  Upload batches are capped at 500, and only acknowledged row IDs are deleted.
  A failed request retains the batch. Successful batches also discard rejected
  points as required by the contract.
- Location events are sampled for persistence after 30 seconds or 50 metres.
  Upload/reconciliation runs each minute and when the app resumes. Android uses
  Geolocator's location foreground service, permanent notification and wake lock.
  iOS uses background location updates with automatic pausing disabled.
- A location disclosure precedes permission requests. Android users receive a
  battery settings prompt. GPS/permission interruptions appear in the duty panel.
- Stop persists the original tap time before cancelling tracking. It works without
  GPS and is retried before a new ON. An in-flight refresh cannot overwrite a
  newer Stop. Late points from ended sessions are still uploaded.
- Successful OTP, non-OTP and AF2AP delivery paths stop only a matching order
  duty. Failed delivery, total duty, and a different order's duty do not stop it.
- Stop shows server addresses, duration, distance, rate and amount and refreshes
  cash. Zero rate displays "Rate not set". No client distance/payment calculation
  is used for the duty module.
- Duty history provides dates, side/order filters, pagination and server totals
  across all matches. Display times and date filters use India time.
- My Cash includes duty debit/reversal filters, notes and references, excludes
  duty rows from expense navigation, and shows negative balances in red with a
  leading minus. The duty subtotal is labelled as included in expenses.
- Existing per-product GST, blank initial rates, draft editing, linked purchase
  handling, screenshot upload/duplicate recovery and three-minute timeout were
  retained and covered by the existing regression tests.

## Verification

Use the pinned SDK at `.fvm/flutter_sdk`, Flutter 3.47.7.

```powershell
postman simulation run postman/simulations/expenses.sim.yaml --port 4900 --output ndjson
.fvm/flutter_sdk/bin/flutter.bat test --no-pub --dart-define=EXPENSE_TEST_BASE_URL=http://127.0.0.1:4900/expenses
.fvm/flutter_sdk/bin/flutter.bat build apk --debug --no-pub
```

47 tests passed with the local expense API simulation enabled. Duty tests use a
recording API and in-memory outbox to verify offline Stop replay, original time
retention, 500-point batching, retry retention, matching-order delivery, repeated
Stop, and Stop during an in-flight refresh. These are contract tests, not live
backend or native background-execution tests.

## Device and deployed-server verification

Before release, run all 23 acceptance cases in section 9 of the guide against the
deployed APIs, with special attention to:

1. Screen locked/background travel for 2–3 km on Android and iOS.
2. Five minutes of movement in airplane mode, then original-time batch replay.
3. App process termination and reopening: session restoration and queued points.
4. GPS/permission removal during duty; Stop with GPS disabled.
5. OEM battery restrictions, persistent notification and Android location service.
6. Duplicate uploads and rejected senders on the deployed OCR endpoint.
7. Duty cash debit, late-point adjustment, zero rate and negative balance.
8. Foreground location disclosure and store privacy/Data Safety declarations.

An explicit OS force-stop cannot keep collecting points; reopening restores the
server session and uploads already persisted points. No route is invented for
the missing interval. iOS signing/build and real-device validation require macOS
and the provisioned app configuration. The new duty/OCR deployment status still
needs confirmation from the office; no production mutations were made here.
