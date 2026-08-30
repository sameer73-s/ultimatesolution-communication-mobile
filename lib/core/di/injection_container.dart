import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
  if (!serviceLocator.isRegistered<AccessTokenStore>()) {
    serviceLocator.registerSingleton<AccessTokenStore>(
      SecureAccessTokenStore(),
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
  if (!serviceLocator.isRegistered<AuthRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
      () => DioAuthRemoteDataSource(serviceLocator<ApiClient>()),
    );
  }
  if (!serviceLocator.isRegistered<AuthRepository>()) {
    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator<AuthRemoteDataSource>(),
        serviceLocator<AccessTokenStore>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<AuthBloc>()) {
    serviceLocator.registerFactory<AuthBloc>(
      () => AuthBloc(serviceLocator<AuthRepository>()),
    );
  }
}
