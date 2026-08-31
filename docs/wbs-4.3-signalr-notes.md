# WBS 4.3 — Flutter Chat / SignalR notes

## SignalR package choice

- Package: `signalr_netcore` `^1.4.4`
- Why:
  - Dart 3 compatible (`sdk: >=2.12.0 <4.0.0`) and resolves cleanly with this app’s Flutter SDK (`^3.13.2`).
  - Actively maintained relative to `signalr_core` (community guidance recommends migrating away from `signalr_core` when dependency conflicts appear).
  - Supports ASP.NET Core Hub protocol, `accessTokenFactory` for JWT (same token source as `ApiClient` / `SecureAccessTokenStore`), and automatic reconnect.
  - Matches backend hub path `/hubs/chat` and event names from WBS 3.3 (`messageCreated`, `typingChanged`, `presenceChanged`, plus `messageUpdated` / `messageDeleted`).

## Live hub verification

- **Passed** against Render on 2026-08-31.
- Target: `https://ultimatesolution-communication-backend.onrender.com/hubs/chat`
- Listener: `test@example.com`; peer sender temporary account; event `messageCreated` received in ~496ms after peer REST send.
- Details and raw console: `docs/review/test-results-summary.md` → section **Live Hub Verification**.
- Opt-in re-run: `flutter test test/live_hub_verify_test.dart --dart-define=LIVE_HUB=true --dart-define=API_BASE_URL=https://ultimatesolution-communication-backend.onrender.com`