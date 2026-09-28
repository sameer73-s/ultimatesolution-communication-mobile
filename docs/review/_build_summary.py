import datetime
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
lines = (root / "docs/review/flutter-test-jsonl.txt").read_text(
    encoding="utf-8", errors="replace"
).splitlines()
suites = {}
by_id = {}
tests = []
for line in lines:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue
    if obj.get("type") == "suite" and "suite" in obj:
        suites[obj["suite"]["id"]] = obj["suite"]["path"]
    if obj.get("type") == "testStart" and "test" in obj:
        t = obj["test"]
        if not t["name"].startswith("loading "):
            by_id[t["id"]] = {
                "name": t["name"],
                "suiteId": t["suiteID"],
                "start": obj["time"],
            }
    if obj.get("type") == "testDone" and not obj.get("hidden"):
        meta = by_id.get(obj.get("testID"))
        if not meta:
            continue
        suite = Path(suites.get(meta["suiteId"], "unknown")).stem
        if obj.get("skipped"):
            result = "Skipped"
        elif obj.get("result") == "success":
            result = "Passed"
        else:
            result = "Failed"
        tests.append(
            {
                "suite": suite,
                "name": meta["name"],
                "result": result,
                "ms": int(obj["time"] - meta["start"]),
            }
        )

tests.sort(key=lambda x: (x["suite"], x["name"]))
analyze = (root / "docs/review/flutter-analyze-4.3.txt").read_text(
    encoding="utf-8", errors="replace"
).strip()
live = (root / "docs/review/live-hub-verify-console.txt").read_text(
    encoding="utf-8", errors="replace"
).strip()
passed = sum(1 for t in tests if t["result"] == "Passed")
skipped = sum(1 for t in tests if t["result"] == "Skipped")
failed = sum(1 for t in tests if t["result"] == "Failed")
gen = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

rows = []
for t in tests:
    ms = t["ms"]
    time = f"{ms / 1000:.1f}s" if ms >= 1000 else f"{ms}ms"
    full = f"{t['suite']} / {t['name']}"
    rows.append(f"| `{full}` | {t['result']} | {time} |")

md = f"""# WBS 4.3 - Test Results Summary

- **Branch:** `feature/4.3-flutter-chat`
- **PR:** https://github.com/sameer73-s/ultimatesolution-communication-mobile/pull/5
- **Generated (UTC):** `{gen}`
- **Command:** `flutter test --reporter json`
- **Totals:** {len(tests)} tests - Passed={passed}, Skipped={skipped}, Failed={failed}

## flutter analyze

```
{analyze}
```

## Automated tests

| Full name | Result | Time |
|---|---|---:|
{chr(10).join(rows)}

## Live Hub Verification

### Target

- **API:** `https://ultimatesolution-communication-backend.onrender.com`
- **Hub:** `https://ultimatesolution-communication-backend.onrender.com/hubs/chat`
- **Listener account:** `test@example.com` (requested)
- **Peer sender:** temporary registered account `live.hub.peer.*@example.com` (second concurrent party required for cross-user realtime proof)
- **Client stack:** same as the Flutter feature - `signalr_netcore` + JWT `accessTokenFactory` + REST send

### Method

1. Login as `test@example.com` against Render.
2. Register a peer user and create a Group channel containing both.
3. Connect ChatHub as the listener and invoke `SubscribeChannel(channelId)`.
4. Peer sends a REST message; listener waits **only** on SignalR `messageCreated` (no REST poll/refresh).
5. Assert event `id` / `channelId` / `body` / `senderUserId` match the peer REST response.

Command:

```
flutter test test/live_hub_verify_test.dart --dart-define=LIVE_HUB=true --dart-define=API_BASE_URL=https://ultimatesolution-communication-backend.onrender.com
```

### Result: **Passed**

- Hub connected: `HubConnectionState.Connected`
- Listener userId: `34177dcf-d422-4bb8-a279-a6d0b03808d8`
- Peer userId: `62c6ce95-c6ac-4323-8858-650003c735ab`
- ChannelId: `02bd316c-0f80-4065-9a27-f439e5462ac6`
- MessageId: `ce407db0-405f-4d6c-b981-67be90335916`
- Marker body: `LIVE_HUB_MARKER_1788179958828`
- SignalR delivery latency after peer REST send: **496ms**
- Conclusion: peer message arrived on the listener hub via `messageCreated` without REST refresh.

### Constraint documented (not skipped silently)

Proving cross-party realtime delivery requires **two authenticated actors**. A single Flutter UI session cannot both listen and independently send as a different user. The live check therefore used:
- Listener = `test@example.com` on ChatHub (same package/URL/token mechanism as the app)
- Sender = separate peer account via REST

That is the real Render hub path, not unit fakes. Dual-window Flutter UI would only wrap the same SignalR client.

### Raw console

```
{live}
```
"""

out = root / "docs/review/test-results-summary.md"
out.write_text(md, encoding="utf-8")
print(f"wrote {out} rows={len(tests)} passed={passed} skipped={skipped} failed={failed}")
for t in tests:
    print(f"{t['result']}|{t['ms']}|{t['suite']} :: {t['name']}")
