import '../entities/chat_message.dart';
import '../entities/chat_realtime_events.dart';

/// Domain gateway for ChatHub realtime events (messageCreated, typing, presence).
abstract interface class ChatRealtimeRepository {
  Future<void> connect();

  Future<void> disconnect();

  Future<void> subscribeChannel(String channelId);

  Future<void> unsubscribeChannel(String channelId);

  Future<void> startTyping(String channelId);

  Future<void> stopTyping(String channelId);

  Stream<ChatMessage> get messageCreated;

  Stream<ChatMessage> get messageUpdated;

  Stream<ChatMessage> get messageDeleted;

  Stream<TypingChangedEvent> get typingChanged;

  Stream<PresenceChangedEvent> get presenceChanged;
}
