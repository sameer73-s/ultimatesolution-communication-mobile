import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ultimate_solution_mobile/core/routing/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GoRouter resolves /login without a GoException', () {
    final match = appRouter.configuration.findMatch(Uri.parse('/login'));

    expect(match.isError, isFalse);
    expect(match.error, isNull);
    expect(match.uri.path, '/login');
    expect(match.matches, isNotEmpty);
  });

  test('GoRouter resolves /register without a GoException', () {
    final match = appRouter.configuration.findMatch(Uri.parse('/register'));

    expect(match.isError, isFalse);
    expect(match.error, isNull);
    expect(match.uri.path, '/register');
    expect(match.matches, isNotEmpty);
  });

  test('GoRouter resolves /channels without a GoException', () {
    final match = appRouter.configuration.findMatch(Uri.parse('/channels'));

    expect(match.isError, isFalse);
    expect(match.error, isNull);
    expect(match.uri.path, '/channels');
    expect(match.matches, isNotEmpty);
  });

  test('GoRouter resolves /channels/:channelId without a GoException', () {
    final match = appRouter.configuration.findMatch(
      Uri.parse('/channels/11111111-1111-1111-1111-111111111111'),
    );

    expect(match.isError, isFalse);
    expect(match.error, isNull);
    expect(
      match.uri.path,
      '/channels/11111111-1111-1111-1111-111111111111',
    );
    expect(match.matches, isNotEmpty);
  });

  test('unregistered locations still surface as match errors', () {
    final match = appRouter.configuration.findMatch(
      Uri.parse('/definitely-not-registered'),
    );

    expect(match.isError, isTrue);
    expect(match.error, isA<GoException>());
  });
}