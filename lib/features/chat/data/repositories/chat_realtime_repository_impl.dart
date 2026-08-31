import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_realtime_events.dart';
import '../../domain/repositories/chat_realtime_repository.dart';
import '../datasources/chat_realtime_data_source.dart';

final class ChatRealtimeRepositoryImpl implements ChatRealtimeRepository {
  ChatRealtimeRepositoryImpl(this._realtime);

  final ChatRealtimeDataSource _realtime;

  @override
  Future<void> connect() => _realtime.connect();

  @override
  Future<void> disconnect() => _realtime.disconnect();

  @override
  Future<void> subscribeChannel(String channelId) =>
      _realtime.subscribeChannel(channelId);

  @override
  Future<void> unsubscribeChannel(String channelId) =>
      _realtime.unsubscribeChannel(channelId);

  @override
  Future<void> startTyping(String channelId) =>
      _realtime.startTyping(channelId);

  @override
  Future<void> stopTyping(String channelId) => _realtime.stopTyping(channelId);

  @override
  Stream<ChatMessage> get messageCreated =>
      _realtime.messageCreated.map((model) => model.toEntity());

  @override
  Stream<ChatMessage> get messageUpdated =>
      _realtime.messageUpdated.map((model) => model.toEntity());

  @override
  Stream<ChatMessage> get messageDeleted =>
      _realtime.messageDeleted.map((model) => model.toEntity());

  @override
  Stream<TypingChangedEvent> get typingChanged =>
      _realtime.typingChanged.map((model) => model.toEntity());

  @override
  Stream<PresenceChangedEvent> get presenceChanged =>
      _realtime.presenceChanged.map((model) => model.toEntity());
}
