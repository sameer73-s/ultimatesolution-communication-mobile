# WBS 4.3 — Flutter Chat / SignalR notes

## SignalR package choice

- Package: `signalr_netcore` `^1.4.4`
- Why:
  - Dart 3 compatible (`sdk: >=2.12.0 <4.0.0`) and resolves cleanly with this app’s Flutter SDK (`^3.13.2`).
  - Actively maintained relative to `signalr_core` (community guidance recommends migrating away from `signalr_core` when dependency conflicts appear).
  - Supports ASP.NET Core Hub protocol, `accessTokenFactory` for JWT (same token source as `ApiClient` / `SecureAccessTokenStore`), and automatic reconnect.
  - Matches backend hub path `/hubs/chat` and event names from WBS 3.3 (`messageCreated`, `typingChanged`, `presenceChanged`, plus `messageUpdated` / `messageDeleted`).

## Live hub verification

- **Not manually verified** against the Render-hosted `/hubs/chat` endpoint in this task.
- Coverage in this PR:
  - Unit/bloc tests with fakes for REST + realtime streams.
  - Router resolution tests for `/channels` and `/channels/:channelId`.
  - `flutter analyze` + `flutter test` locally.
- Backend already has integration coverage for ChatHub negotiation and live Long Polling events in `ChatAndPresenceEndpointsTests`.
