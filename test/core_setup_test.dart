import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/di/injection_container.dart';
import 'package:ultimate_solution_mobile/core/network/api_client.dart';
import 'package:ultimate_solution_mobile/core/theme/app_theme.dart';

void main() {
  setUp(() async {
    await serviceLocator.reset();
  });

  test('registers ApiClient and Dio through get_it', () async {
    await configureDependencies();

    expect(serviceLocator<ApiClient>().dio, isA<Dio>());
    expect(serviceLocator<Dio>(), same(serviceLocator<ApiClient>().dio));
  });

  test('attaches a bearer token through the network interceptor', () async {
    final tokenStore = InMemoryAccessTokenStore();
    await tokenStore.write('test-token');
    final client = ApiClient(tokenStore: tokenStore);
    client.dio.httpClientAdapter = _CaptureAdapter();

    await client.dio.get<void>('/health');

    expect(_CaptureAdapter.lastHeaders['Authorization'], 'Bearer test-token');
  });

  testWidgets('exposes the placeholder theme centrally', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Theme test')),
      ),
    );

    expect(
      Theme.of(tester.element(find.text('Theme test'))).colorScheme.primary,
      AppColors.primary,
    );
  });
}

final class _CaptureAdapter implements HttpClientAdapter {
  static Map<String, dynamic> lastHeaders = <String, dynamic>{};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastHeaders = options.headers;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
