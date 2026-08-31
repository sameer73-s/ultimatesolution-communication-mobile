import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/refresh_session_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_realtime_data_source.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_realtime_repository_impl.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_realtime_repository.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/add_channel_member_use_case.dart';
import '../../features/chat/domain/usecases/create_channel_use_case.dart';
import '../../features/chat/domain/usecases/delete_message_use_case.dart';
import '../../features/chat/domain/usecases/edit_message_use_case.dart';
import '../../features/chat/domain/usecases/get_channel_use_case.dart';
import '../../features/chat/domain/usecases/get_channels_use_case.dart';
import '../../features/chat/domain/usecases/get_messages_use_case.dart';
import '../../features/chat/domain/usecases/mark_message_read_use_case.dart';
import '../../features/chat/domain/usecases/remove_channel_member_use_case.dart';
import '../../features/chat/domain/usecases/send_message_use_case.dart';
import '../../features/chat/presentation/bloc/channels_bloc.dart';
import '../../features/chat/presentation/bloc/chat_conversation_bloc.dart';

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
  if (!serviceLocator.isRegistered<LoginUseCase>()) {
    serviceLocator.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<RegisterUseCase>()) {
    serviceLocator.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<RefreshSessionUseCase>()) {
    serviceLocator.registerLazySingleton<RefreshSessionUseCase>(
      () => RefreshSessionUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<LogoutUseCase>()) {
    serviceLocator.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<AuthBloc>()) {
    serviceLocator.registerFactory<AuthBloc>(
      () => AuthBloc(
        serviceLocator<LoginUseCase>(),
        serviceLocator<RegisterUseCase>(),
        serviceLocator<RefreshSessionUseCase>(),
        serviceLocator<LogoutUseCase>(),
      ),
    );
  }

  if (!serviceLocator.isRegistered<ChatRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<ChatRemoteDataSource>(
      () => DioChatRemoteDataSource(serviceLocator<ApiClient>()),
    );
  }
  if (!serviceLocator.isRegistered<ChatRealtimeDataSource>()) {
    serviceLocator.registerLazySingleton<ChatRealtimeDataSource>(
      () => SignalRChatRealtimeDataSource(
        tokenStore: serviceLocator<AccessTokenStore>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<ChatRepository>()) {
    serviceLocator.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(serviceLocator<ChatRemoteDataSource>()),
    );
  }
  if (!serviceLocator.isRegistered<ChatRealtimeRepository>()) {
    serviceLocator.registerLazySingleton<ChatRealtimeRepository>(
      () => ChatRealtimeRepositoryImpl(
        serviceLocator<ChatRealtimeDataSource>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<GetChannelsUseCase>()) {
    serviceLocator.registerLazySingleton<GetChannelsUseCase>(
      () => GetChannelsUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<GetChannelUseCase>()) {
    serviceLocator.registerLazySingleton<GetChannelUseCase>(
      () => GetChannelUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<CreateChannelUseCase>()) {
    serviceLocator.registerLazySingleton<CreateChannelUseCase>(
      () => CreateChannelUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<GetMessagesUseCase>()) {
    serviceLocator.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<SendMessageUseCase>()) {
    serviceLocator.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<EditMessageUseCase>()) {
    serviceLocator.registerLazySingleton<EditMessageUseCase>(
      () => EditMessageUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<DeleteMessageUseCase>()) {
    serviceLocator.registerLazySingleton<DeleteMessageUseCase>(
      () => DeleteMessageUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<MarkMessageReadUseCase>()) {
    serviceLocator.registerLazySingleton<MarkMessageReadUseCase>(
      () => MarkMessageReadUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<AddChannelMemberUseCase>()) {
    serviceLocator.registerLazySingleton<AddChannelMemberUseCase>(
      () => AddChannelMemberUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<RemoveChannelMemberUseCase>()) {
    serviceLocator.registerLazySingleton<RemoveChannelMemberUseCase>(
      () => RemoveChannelMemberUseCase(serviceLocator<ChatRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<ChannelsBloc>()) {
    serviceLocator.registerFactory<ChannelsBloc>(
      () => ChannelsBloc(serviceLocator<GetChannelsUseCase>()),
    );
  }
  if (!serviceLocator.isRegistered<ChatConversationBloc>()) {
    serviceLocator.registerFactory<ChatConversationBloc>(
      () => ChatConversationBloc(
        serviceLocator<GetMessagesUseCase>(),
        serviceLocator<SendMessageUseCase>(),
        serviceLocator<ChatRealtimeRepository>(),
      ),
    );
  }
}
