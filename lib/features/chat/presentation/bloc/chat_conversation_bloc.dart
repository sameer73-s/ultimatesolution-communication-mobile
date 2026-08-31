import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_realtime_events.dart';
import '../../domain/repositories/chat_realtime_repository.dart';
import '../../domain/usecases/get_messages_use_case.dart';
import '../../domain/usecases/send_message_use_case.dart';

sealed class ChatConversationEvent {
  const ChatConversationEvent();
}

final class ChatConversationStarted extends ChatConversationEvent {
  const ChatConversationStarted(this.channelId);

  final String channelId;
}

final class ChatMessageSendRequested extends ChatConversationEvent {
  const ChatMessageSendRequested(this.body);

  final String body;
}

final class _RealtimeMessageReceived extends ChatConversationEvent {
  const _RealtimeMessageReceived(this.message);

  final ChatMessage message;
}

final class _RealtimeTypingChanged extends ChatConversationEvent {
  const _RealtimeTypingChanged(this.event);

  final TypingChangedEvent event;
}

final class _RealtimePresenceChanged extends ChatConversationEvent {
  const _RealtimePresenceChanged(this.event);

  final PresenceChangedEvent event;
}

sealed class ChatConversationState {
  const ChatConversationState();
}

final class ChatConversationInitial extends ChatConversationState {
  const ChatConversationInitial();
}

final class ChatConversationLoading extends ChatConversationState {
  const ChatConversationLoading();
}

final class ChatConversationReady extends ChatConversationState {
  const ChatConversationReady({
    required this.channelId,
    required this.messages,
    this.typingUserIds = const {},
    this.presenceByUserId = const {},
    this.failure,
    this.isSending = false,
  });

  final String channelId;
  final List<ChatMessage> messages;
  final Set<String> typingUserIds;
  final Map<String, PresenceStatus> presenceByUserId;
  final Failure? failure;
  final bool isSending;

  ChatConversationReady copyWith({
    List<ChatMessage>? messages,
    Set<String>? typingUserIds,
    Map<String, PresenceStatus>? presenceByUserId,
    Failure? failure,
    bool clearFailure = false,
    bool? isSending,
  }) {
    return ChatConversationReady(
      channelId: channelId,
      messages: messages ?? this.messages,
      typingUserIds: typingUserIds ?? this.typingUserIds,
      presenceByUserId: presenceByUserId ?? this.presenceByUserId,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSending: isSending ?? this.isSending,
    );
  }
}

final class ChatConversationFailure extends ChatConversationState {
  const ChatConversationFailure(this.failure);

  final Failure failure;
}

final class ChatConversationBloc
    extends Bloc<ChatConversationEvent, ChatConversationState> {
  ChatConversationBloc(
    this._getMessages,
    this._sendMessage,
    this._realtime,
  ) : super(const ChatConversationInitial()) {
    on<ChatConversationStarted>(_onStarted);
    on<ChatMessageSendRequested>(_onSend);
    on<_RealtimeMessageReceived>(_onRealtimeMessage);
    on<_RealtimeTypingChanged>(_onRealtimeTyping);
    on<_RealtimePresenceChanged>(_onRealtimePresence);
  }

  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final ChatRealtimeRepository _realtime;

  String? _channelId;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Future<void> _onStarted(
    ChatConversationStarted event,
    Emitter<ChatConversationState> emit,
  ) async {
    await _tearDownRealtime();
    _channelId = event.channelId;
    emit(const ChatConversationLoading());

    final result = await _getMessages(channelId: event.channelId);
    final messages = result.messages;
    if (messages == null) {
      emit(ChatConversationFailure(result.failure ?? const UnknownFailure()));
      return;
    }

    emit(
      ChatConversationReady(
        channelId: event.channelId,
        messages: List<ChatMessage>.unmodifiable(messages),
      ),
    );

    try {
      await _realtime.connect();
      await _realtime.subscribeChannel(event.channelId);
      _subscriptions.addAll([
        _realtime.messageCreated.listen((message) {
          if (message.channelId == event.channelId) {
            add(_RealtimeMessageReceived(message));
          }
        }),
        _realtime.messageUpdated.listen((message) {
          if (message.channelId == event.channelId) {
            add(_RealtimeMessageReceived(message));
          }
        }),
        _realtime.messageDeleted.listen((message) {
          if (message.channelId == event.channelId) {
            add(_RealtimeMessageReceived(message));
          }
        }),
        _realtime.typingChanged.listen((typing) {
          if (typing.channelId == event.channelId) {
            add(_RealtimeTypingChanged(typing));
          }
        }),
        _realtime.presenceChanged.listen((presence) {
          add(_RealtimePresenceChanged(presence));
        }),
      ]);
    } catch (_) {
      // REST history still usable if hub connection fails.
    }
  }

  Future<void> _onSend(
    ChatMessageSendRequested event,
    Emitter<ChatConversationState> emit,
  ) async {
    final current = state;
    final channelId = _channelId;
    if (current is! ChatConversationReady || channelId == null) {
      return;
    }

    final body = event.body.trim();
    if (body.isEmpty) {
      return;
    }

    emit(current.copyWith(isSending: true, clearFailure: true));
    final result = await _sendMessage(channelId: channelId, body: body);
    final message = result.message;
    if (message == null) {
      emit(
        current.copyWith(
          isSending: false,
          failure: result.failure ?? const UnknownFailure(),
        ),
      );
      return;
    }

    final merged = _upsertMessage(current.messages, message);
    emit(
      current.copyWith(
        messages: List<ChatMessage>.unmodifiable(merged),
        isSending: false,
        clearFailure: true,
      ),
    );
  }

  void _onRealtimeMessage(
    _RealtimeMessageReceived event,
    Emitter<ChatConversationState> emit,
  ) {
    final current = state;
    if (current is! ChatConversationReady) {
      return;
    }
    final merged = _upsertMessage(current.messages, event.message);
    emit(
      current.copyWith(messages: List<ChatMessage>.unmodifiable(merged)),
    );
  }

  void _onRealtimeTyping(
    _RealtimeTypingChanged event,
    Emitter<ChatConversationState> emit,
  ) {
    final current = state;
    if (current is! ChatConversationReady) {
      return;
    }
    final typing = Set<String>.from(current.typingUserIds);
    if (event.event.isTyping) {
      typing.add(event.event.userId);
    } else {
      typing.remove(event.event.userId);
    }
    emit(current.copyWith(typingUserIds: typing));
  }

  void _onRealtimePresence(
    _RealtimePresenceChanged event,
    Emitter<ChatConversationState> emit,
  ) {
    final current = state;
    if (current is! ChatConversationReady) {
      return;
    }
    final presence = Map<String, PresenceStatus>.from(current.presenceByUserId);
    presence[event.event.userId] = event.event.status;
    emit(current.copyWith(presenceByUserId: presence));
  }

  List<ChatMessage> _upsertMessage(
    List<ChatMessage> existing,
    ChatMessage incoming,
  ) {
    final next = List<ChatMessage>.from(existing);
    final index = next.indexWhere((message) => message.id == incoming.id);
    if (incoming.isDeleted) {
      if (index >= 0) {
        next.removeAt(index);
      }
      return next;
    }
    if (index >= 0) {
      next[index] = incoming;
    } else {
      next.add(incoming);
    }
    next.sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));
    return next;
  }

  Future<void> _tearDownRealtime() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    final channelId = _channelId;
    if (channelId != null) {
      try {
        await _realtime.unsubscribeChannel(channelId);
      } catch (_) {}
    }
  }

  @override
  Future<void> close() async {
    await _tearDownRealtime();
    return super.close();
  }
}
