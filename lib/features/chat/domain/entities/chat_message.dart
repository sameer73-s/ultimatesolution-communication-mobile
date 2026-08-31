final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderUserId,
    required this.body,
    required this.createdAtUtc,
    this.editedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String channelId;
  final String senderUserId;
  final String body;
  final DateTime createdAtUtc;
  final DateTime? editedAtUtc;
  final DateTime? deletedAtUtc;

  bool get isDeleted => deletedAtUtc != null;
}
