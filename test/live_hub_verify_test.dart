import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Live Render ChatHub verification (not a unit fake).
/// Run:
/// flutter test test/live_hub_verify_test.dart --dart-define=LIVE_HUB=true --dart-define=API_BASE_URL=https://ultimatesolution-communication-backend.onrender.com
void main() {
  const liveHubEnabled = bool.fromEnvironment('LIVE_HUB', defaultValue: false);

  test(
    'Live Hub: messageCreated arrives over SignalR on Render',
    () async {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://ultimatesolution-communication-backend.onrender.com',
      );
      final password = Platform.environment['LIVE_HUB_PASSWORD'] ?? 'P@ssw0rd123!';
      final listenerEmail =
          Platform.environment['LIVE_HUB_EMAIL'] ?? 'test@example.com';

      stdout.writeln('[LIVE_HUB] baseUrl=$baseUrl');
      stdout.writeln('[LIVE_HUB] listener=$listenerEmail');

      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      Future<Map<String, dynamic>> login(String email, String pwd) async {
        final response = await dio.post<Map<String, dynamic>>(
          '/api/v1/auth/login',
          data: {'email': email, 'password': pwd},
        );
        final body = response.data ?? const <String, dynamic>{};
        if (body['success'] != true || body['data'] is! Map<String, dynamic>) {
          throw StateError(
            'Login failed for $email: status=${response.statusCode} body=${jsonEncode(body)}',
          );
        }
        return body['data']! as Map<String, dynamic>;
      }

      Future<String> profileUserId(String accessToken) async {
        final response = await dio.get<Map<String, dynamic>>(
          '/api/v1/profile',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> || data['userId'] is! String) {
          throw StateError('Profile missing userId: ${response.data}');
        }
        return data['userId'] as String;
      }

      // 1) Login listener (real account requested by reviewer).
      Map<String, dynamic> listenerSession;
      try {
        listenerSession = await login(listenerEmail, password);
      } catch (error) {
        // If the seeded account is missing on Render, register it once.
        stdout.writeln('[LIVE_HUB] login failed, attempting register: $error');
        final register = await dio.post<Map<String, dynamic>>(
          '/api/v1/auth/register',
          data: {
            'email': listenerEmail,
            'password': password,
            'displayName': 'Live Hub Listener',
          },
        );
        stdout.writeln(
          '[LIVE_HUB] register status=${register.statusCode} body=${register.data}',
        );
        listenerSession = await login(listenerEmail, password);
      }
      final listenerToken = listenerSession['accessToken'] as String;
      final listenerId = await profileUserId(listenerToken);
      stdout.writeln('[LIVE_HUB] listenerId=$listenerId');

      // 2) Register a peer sender so we can prove cross-party SignalR delivery.
      final peerEmail =
          'live.hub.peer.${DateTime.now().millisecondsSinceEpoch}@example.com';
      final peerPassword = 'StrongPassword!2026';
      final peerRegister = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'email': peerEmail,
          'password': peerPassword,
          'displayName': 'Live Hub Peer',
        },
      );
      if (peerRegister.statusCode != 201 &&
          peerRegister.data?['success'] != true) {
        throw StateError(
          'Peer register failed: status=${peerRegister.statusCode} body=${peerRegister.data}',
        );
      }
      final peerSession = await login(peerEmail, peerPassword);
      final peerToken = peerSession['accessToken'] as String;
      final peerId = await profileUserId(peerToken);
      stdout.writeln('[LIVE_HUB] peerId=$peerId email=$peerEmail');

      // 3) Listener creates a group channel that includes the peer.
      final createChannel = await dio.post<Map<String, dynamic>>(
        '/api/v1/channels',
        data: {
          'type': 2,
          'name': 'Live Hub Verify ${DateTime.now().toUtc().toIso8601String()}',
          'memberIds': [peerId],
        },
        options: Options(headers: {'Authorization': 'Bearer $listenerToken'}),
      );
      final channelData = createChannel.data?['data'];
      if (channelData is! Map<String, dynamic> || channelData['id'] is! String) {
        throw StateError(
          'Create channel failed: status=${createChannel.statusCode} body=${createChannel.data}',
        );
      }
      final channelId = channelData['id'] as String;
      stdout.writeln('[LIVE_HUB] channelId=$channelId');

      // 4) Connect ChatHub as listener with JWT (same path as app SignalR client).
      final messageCreated = Completer<Map<String, dynamic>>();
      final hubUrl = '$baseUrl/hubs/chat';
      final hub = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => listenerToken,
            ),
          )
          .withAutomaticReconnect()
          .build();

      hub.on('messageCreated', (args) {
        stdout.writeln('[LIVE_HUB] messageCreated raw args=$args');
        if (args == null || args.isEmpty) {
          return;
        }
        final first = args.first;
        Map<String, dynamic>? json;
        if (first is Map<String, dynamic>) {
          json = first;
        } else if (first is Map) {
          json = Map<String, dynamic>.from(first);
        }
        if (json != null && !messageCreated.isCompleted) {
          messageCreated.complete(json);
        }
      });

      stdout.writeln('[LIVE_HUB] connecting hub $hubUrl');
      await hub.start();
      stdout.writeln('[LIVE_HUB] hub state=${hub.state}');
      await hub.invoke('SubscribeChannel', args: <Object>[channelId]);
      stdout.writeln('[LIVE_HUB] subscribed to channel');

      // 5) Peer sends a REST message — listener must receive it via SignalR only.
      final marker =
          'LIVE_HUB_MARKER_${DateTime.now().toUtc().millisecondsSinceEpoch}';
      final sendStarted = DateTime.now().toUtc();
      final send = await dio.post<Map<String, dynamic>>(
        '/api/v1/channels/$channelId/messages',
        data: {'body': marker},
        options: Options(headers: {'Authorization': 'Bearer $peerToken'}),
      );
      final sent = send.data?['data'];
      if (sent is! Map<String, dynamic> || sent['id'] is! String) {
        throw StateError(
          'Peer send failed: status=${send.statusCode} body=${send.data}',
        );
      }
      final sentId = sent['id'] as String;
      stdout.writeln('[LIVE_HUB] peer sent messageId=$sentId body=$marker');

      Map<String, dynamic> event;
      try {
        event = await messageCreated.future.timeout(const Duration(seconds: 20));
      } on TimeoutException {
        await hub.stop();
        fail(
          'Timed out waiting for SignalR messageCreated on $hubUrl after peer REST send '
          '(messageId=$sentId, marker=$marker). Hub did not deliver realtime event.',
        );
      }

      final elapsedMs =
          DateTime.now().toUtc().difference(sendStarted).inMilliseconds;
      stdout.writeln('[LIVE_HUB] received event=$event in ${elapsedMs}ms');

      expect(event['id'], sentId);
      expect(event['channelId'], channelId);
      expect(event['body'], marker);
      expect(event['senderUserId'], peerId);

      await hub.stop();
      stdout.writeln('[LIVE_HUB] SUCCESS realtime delivery confirmed');
    },
    skip: liveHubEnabled
        ? false
        : 'Opt-in with --dart-define=LIVE_HUB=true',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
