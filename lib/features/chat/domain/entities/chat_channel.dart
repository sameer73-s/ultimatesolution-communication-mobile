enum ChatChannelType {
  direct(1),
  group(2),
  channel(3);

  const ChatChannelType(this.value);
  final int value;

  static ChatChannelType fromValue(int value) {
    return ChatChannelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChatChannelType.group,
    );
  }
}

enum ChannelMemberRole {
  member(1),
  owner(2);

  const ChannelMemberRole(this.value);
  final int value;

  static ChannelMemberRole fromValue(int value) {
    return ChannelMemberRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => ChannelMemberRole.member,
    );
  }
}

final class ChannelMembership {
  const ChannelMembership({
    required this.userId,
    required this.role,
    required this.joinedAtUtc,
  });

  final String userId;
  final ChannelMemberRole role;
  final DateTime joinedAtUtc;
}

final class ChatChannel {
  const ChatChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdByUserId,
    required this.createdAtUtc,
    required this.isArchived,
    this.archivedAtUtc,
    required this.members,
  });

  final String id;
  final String name;
  final ChatChannelType type;
  final String createdByUserId;
  final DateTime createdAtUtc;
  final bool isArchived;
  final DateTime? archivedAtUtc;
  final List<ChannelMembership> members;
}
