final class MessageRead {
  const MessageRead({
    required this.channelId,
    required this.userId,
    required this.lastReadMessageId,
    required this.lastReadAtUtc,
  });

  final String channelId;
  final String userId;
  final String lastReadMessageId;
  final DateTime lastReadAtUtc;
}
