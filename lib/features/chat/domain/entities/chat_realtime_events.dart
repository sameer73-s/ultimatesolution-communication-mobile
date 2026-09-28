enum PresenceStatus {
  offline(1),
  online(2),
  away(3);

  const PresenceStatus(this.value);
  final int value;

  static PresenceStatus fromValue(int value) {
    return PresenceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PresenceStatus.offline,
    );
  }
}

final class TypingChangedEvent {
  const TypingChangedEvent({
    required this.channelId,
    required this.userId,
    required this.isTyping,
  });

  final String channelId;
  final String userId;
  final bool isTyping;
}

final class PresenceChangedEvent {
  const PresenceChangedEvent({
    required this.userId,
    required this.status,
    required this.changedAtUtc,
  });

  final String userId;
  final PresenceStatus status;
  final DateTime changedAtUtc;
}
