import '../../domain/entities/chat_channel.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_realtime_events.dart';
import '../../domain/entities/message_read.dart';

final class ChannelMembershipModel {
  const ChannelMembershipModel({
    required this.userId,
    required this.role,
    required this.joinedAtUtc,
  });

  final String userId;
  final int role;
  final DateTime joinedAtUtc;

  factory ChannelMembershipModel.fromJson(Map<String, dynamic> json) {
    return ChannelMembershipModel(
      userId: json['userId'] as String,
      role: json['role'] as int,
      joinedAtUtc: DateTime.parse(json['joinedAtUtc'] as String),
    );
  }

  ChannelMembership toEntity() => ChannelMembership(
    userId: userId,
    role: ChannelMemberRole.fromValue(role),
    joinedAtUtc: joinedAtUtc,
  );
}

final class ChatChannelModel {
  const ChatChannelModel({
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
  final int type;
  final String createdByUserId;
  final DateTime createdAtUtc;
  final bool isArchived;
  final DateTime? archivedAtUtc;
  final List<ChannelMembershipModel> members;

  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    final members = <ChannelMembershipModel>[];
    if (membersRaw is List<dynamic>) {
      for (final item in membersRaw) {
        if (item is Map<String, dynamic>) {
          members.add(ChannelMembershipModel.fromJson(item));
        }
      }
    }

    return ChatChannelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as int,
      createdByUserId: json['createdByUserId'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
      archivedAtUtc: json['archivedAtUtc'] == null
          ? null
          : DateTime.parse(json['archivedAtUtc'] as String),
      members: members,
    );
  }

  ChatChannel toEntity() => ChatChannel(
    id: id,
    name: name,
    type: ChatChannelType.fromValue(type),
    createdByUserId: createdByUserId,
    createdAtUtc: createdAtUtc,
    isArchived: isArchived,
    archivedAtUtc: archivedAtUtc,
    members: [for (final member in members) member.toEntity()],
  );
}

final class ChatMessageModel {
  const ChatMessageModel({
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

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      senderUserId: json['senderUserId'] as String,
      body: json['body'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      editedAtUtc: json['editedAtUtc'] == null
          ? null
          : DateTime.parse(json['editedAtUtc'] as String),
      deletedAtUtc: json['deletedAtUtc'] == null
          ? null
          : DateTime.parse(json['deletedAtUtc'] as String),
    );
  }

  ChatMessage toEntity() => ChatMessage(
    id: id,
    channelId: channelId,
    senderUserId: senderUserId,
    body: body,
    createdAtUtc: createdAtUtc,
    editedAtUtc: editedAtUtc,
    deletedAtUtc: deletedAtUtc,
  );
}

final class MessageReadModel {
  const MessageReadModel({
    required this.channelId,
    required this.userId,
    required this.lastReadMessageId,
    required this.lastReadAtUtc,
  });

  final String channelId;
  final String userId;
  final String lastReadMessageId;
  final DateTime lastReadAtUtc;

  factory MessageReadModel.fromJson(Map<String, dynamic> json) {
    return MessageReadModel(
      channelId: json['channelId'] as String,
      userId: json['userId'] as String,
      lastReadMessageId: json['lastReadMessageId'] as String,
      lastReadAtUtc: DateTime.parse(json['lastReadAtUtc'] as String),
    );
  }

  MessageRead toEntity() => MessageRead(
    channelId: channelId,
    userId: userId,
    lastReadMessageId: lastReadMessageId,
    lastReadAtUtc: lastReadAtUtc,
  );
}

final class TypingChangedModel {
  const TypingChangedModel({
    required this.channelId,
    required this.userId,
    required this.isTyping,
  });

  final String channelId;
  final String userId;
  final bool isTyping;

  factory TypingChangedModel.fromJson(Map<String, dynamic> json) {
    return TypingChangedModel(
      channelId: json['channelId'] as String,
      userId: json['userId'] as String,
      isTyping: json['isTyping'] as bool,
    );
  }

  TypingChangedEvent toEntity() => TypingChangedEvent(
    channelId: channelId,
    userId: userId,
    isTyping: isTyping,
  );
}

final class PresenceChangedModel {
  const PresenceChangedModel({
    required this.userId,
    required this.status,
    required this.changedAtUtc,
  });

  final String userId;
  final int status;
  final DateTime changedAtUtc;

  factory PresenceChangedModel.fromJson(Map<String, dynamic> json) {
    return PresenceChangedModel(
      userId: json['userId'] as String,
      status: json['status'] as int,
      changedAtUtc: DateTime.parse(json['changedAtUtc'] as String),
    );
  }

  PresenceChangedEvent toEntity() => PresenceChangedEvent(
    userId: userId,
    status: PresenceStatus.fromValue(status),
    changedAtUtc: changedAtUtc,
  );
}

final class CreateChannelRequestModel {
  const CreateChannelRequestModel({
    required this.type,
    this.name,
    required this.memberIds,
  });

  final int type;
  final String? name;
  final List<String> memberIds;

  Map<String, dynamic> toJson() => {
    'type': type,
    if (name != null) 'name': name,
    'memberIds': memberIds,
  };
}

final class SendChatMessageRequestModel {
  const SendChatMessageRequestModel(this.body);

  final String body;

  Map<String, dynamic> toJson() => {'body': body};
}

final class UpdateChatMessageRequestModel {
  const UpdateChatMessageRequestModel(this.body);

  final String body;

  Map<String, dynamic> toJson() => {'body': body};
}

final class AddChannelMemberRequestModel {
  const AddChannelMemberRequestModel(this.userId);

  final String userId;

  Map<String, dynamic> toJson() => {'userId': userId};
}
