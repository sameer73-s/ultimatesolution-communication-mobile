$lines = Get-Content "docs\review\flutter-test-jsonl.txt"
$suites = @{}
$byId = @{}
$tests = New-Object System.Collections.Generic.List[object]
foreach ($line in $lines) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  try { $obj = $line | ConvertFrom-Json -ErrorAction Stop } catch { continue }
  if ($obj.type -eq "suite" -and $obj.suite) { $suites[$obj.suite.id] = $obj.suite.path }
  if ($obj.type -eq "testStart" -and $obj.test -and $obj.test.name -notlike "loading *") {
    $byId[$obj.test.id] = @{ name = $obj.test.name; suiteId = $obj.test.suiteID; startTime = $obj.time }
  }
  if ($obj.type -eq "testDone" -and $null -ne $obj.testID -and -not $obj.hidden) {
    $meta = $byId[$obj.testID]
    if ($meta) {
      $suiteName = [IO.Path]::GetFileNameWithoutExtension($suites[$meta.suiteId])
      $result = if ($obj.skipped -eq $true) { "Skipped" } elseif ($obj.result -eq "success") { "Passed" } else { "Failed" }
      $elapsedMs = [int]($obj.time - $meta.startTime)
      $tests.Add([pscustomobject]@{ Suite=$suiteName; Name=$meta.name; Result=$result; TimeMs=$elapsedMs }) | Out-Null
    }
  }
}
$ordered = $tests | Sort-Object Suite, Name
$analyze = (Get-Content "docs\review\flutter-analyze-4.3.txt" -Raw).Trim()
$liveConsole = (Get-Content "docs\review\live-hub-verify-console.txt" -Raw).Trim()
$gen = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$passed = @($ordered | Where-Object { $_.Result -eq "Passed" }).Count
$skipped = @($ordered | Where-Object { $_.Result -eq "Skipped" }).Count
$failed = @($ordered | Where-Object { $_.Result -eq "Failed" }).Count
$nl = [Environment]::NewLine
$out = New-Object System.Text.StringBuilder
[void]$out.AppendLine("# WBS 4.3 — Test Results Summary")
[void]$out.AppendLine("")
[void]$out.AppendLine("- **Branch:** ``feature/4.3-flutter-chat``")
[void]$out.AppendLine("- **PR:** https://github.com/sameer73-s/ultimatesolution-communication-mobile/pull/5")
[void]$out.AppendLine("- **Generated (UTC):** ``$gen``")
[void]$out.AppendLine("- **Command:** ``flutter test --reporter json``")
[void]$out.AppendLine("- **Totals:** $($ordered.Count) tests — Passed=$passed, Skipped=$skipped, Failed=$failed")
[void]$out.AppendLine("")
[void]$out.AppendLine("## flutter analyze")
[void]$out.AppendLine("")
[void]$out.AppendLine("``````")
[void]$out.AppendLine($analyze)
[void]$out.AppendLine("``````")
[void]$out.AppendLine("")
[void]$out.AppendLine("## Automated tests")
[void]$out.AppendLine("")
[void]$out.AppendLine("| Full name | Result | Time |")
[void]$out.AppendLine("|---|---|---:|")
foreach ($t in $ordered) {
  $full = "$($t.Suite) · $($t.Name)"
  $ms = [int]$t.TimeMs
  $time = if ($ms -ge 1000) { ("{0:N1}s" -f ($ms/1000.0)) } else { "${ms}ms" }
  [void]$out.AppendLine("| ``$full`` | $($t.Result) | $time |")
}
[void]$out.AppendLine("")
[void]$out.AppendLine("## Live Hub Verification")
[void]$out.AppendLine("")
[void]$out.AppendLine("### Target")
[void]$out.AppendLine("")
[void]$out.AppendLine("- **API:** ``https://ultimatesolution-communication-backend.onrender.com``")
[void]$out.AppendLine("- **Hub:** ``https://ultimatesolution-communication-backend.onrender.com/hubs/chat``")
[void]$out.AppendLine("- **Listener account:** ``test@example.com`` (requested)")
[void]$out.AppendLine("- **Peer sender:** temporary registered account ``live.hub.peer.*@example.com`` (second concurrent party required for cross-user realtime proof)")
[void]$out.AppendLine("- **Client stack:** same as the Flutter feature — ``signalr_netcore`` + JWT ``accessTokenFactory`` + REST send")
[void]$out.AppendLine("")
[void]$out.AppendLine("### Method")
[void]$out.AppendLine("")
[void]$out.AppendLine("1. Login as ``test@example.com`` against Render.")
[void]$out.AppendLine("2. Register a peer user and create a Group channel containing both.")
[void]$out.AppendLine("3. Connect ChatHub as the listener and invoke ``SubscribeChannel(channelId)``.")
[void]$out.AppendLine("4. Peer sends a REST message; listener waits **only** on SignalR ``messageCreated`` (no REST poll/refresh).")
[void]$out.AppendLine("5. Assert event ``id`` / ``channelId`` / ``body`` / ``senderUserId`` match the peer REST response.")
[void]$out.AppendLine("")
[void]$out.AppendLine("Command:")
[void]$out.AppendLine("")
[void]$out.AppendLine("``````")
[void]$out.AppendLine("flutter test test/live_hub_verify_test.dart --dart-define=LIVE_HUB=true --dart-define=API_BASE_URL=https://ultimatesolution-communication-backend.onrender.com")
[void]$out.AppendLine("``````")
[void]$out.AppendLine("")
[void]$out.AppendLine("### Result: **Passed**")
[void]$out.AppendLine("")
[void]$out.AppendLine("- Hub connected: ``HubConnectionState.Connected``")
[void]$out.AppendLine("- Listener userId: ``34177dcf-d422-4bb8-a279-a6d0b03808d8``")
[void]$out.AppendLine("- Peer userId: ``62c6ce95-c6ac-4323-8858-650003c735ab``")
[void]$out.AppendLine("- ChannelId: ``02bd316c-0f80-4065-9a27-f439e5462ac6``")
[void]$out.AppendLine("- MessageId: ``ce407db0-405f-4d6c-b981-67be90335916``")
[void]$out.AppendLine("- Marker body: ``LIVE_HUB_MARKER_1788179958828``")
[void]$out.AppendLine("- SignalR delivery latency after peer REST send: **496ms**")
[void]$out.AppendLine("- Conclusion: peer message arrived on the listener hub via ``messageCreated`` without REST refresh.")
[void]$out.AppendLine("")
[void]$out.AppendLine("### Constraint documented (not skipped silently)")
[void]$out.AppendLine("")
[void]$out.AppendLine("Proving cross-party realtime delivery requires **two authenticated actors**. A single Flutter UI session cannot both listen and independently send as a different user. The live check therefore used:")
[void]$out.AppendLine("- Listener = ``test@example.com`` on ChatHub (same package/URL/token mechanism as the app)")
[void]$out.AppendLine("- Sender = separate peer account via REST")
[void]$out.AppendLine("")
[void]$out.AppendLine("That is the real Render hub path, not unit fakes. Dual-window Flutter UI would only wrap the same SignalR client.")
[void]$out.AppendLine("")
[void]$out.AppendLine("### Raw console")
[void]$out.AppendLine("")
[void]$out.AppendLine("``````")
[void]$out.AppendLine($liveConsole)
[void]$out.AppendLine("``````")
$markdown = $out.ToString().Replace("``````", "```")
[System.IO.File]::WriteAllText((Join-Path (Get-Location) "docs\review\test-results-summary.md"), $markdown, [System.Text.UTF8Encoding]::new($false))
Write-Output "WROTE $($ordered.Count) rows"
$ordered | ForEach-Object { "$($_.Result)|$($_.TimeMs)|$($_.Suite) · $($_.Name)" }