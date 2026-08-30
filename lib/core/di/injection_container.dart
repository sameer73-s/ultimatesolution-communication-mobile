import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
  if (!serviceLocator.isRegistered<AccessTokenStore>()) {
    serviceLocator.registerSingleton<AccessTokenStore>(
      InMemoryAccessTokenStore(),
    );
  }
  if (!serviceLocator.isRegistered<ApiClient>()) {
    serviceLocator.registerLazySingleton<ApiClient>(
      () => ApiClient(tokenStore: serviceLocator<AccessTokenStore>()),
    );
  }
  if (!serviceLocator.isRegistered<Dio>()) {
    serviceLocator.registerLazySingleton<Dio>(
      () => serviceLocator<ApiClient>().dio,
    );
  }
}
