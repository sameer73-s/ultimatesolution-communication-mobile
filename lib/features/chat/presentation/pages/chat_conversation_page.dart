import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/chat_conversation_bloc.dart';

final class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({required this.channelId, super.key});

  final String channelId;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

final class _ChatConversationPageState extends State<ChatConversationPage> {
  final _composerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatConversationBloc>().add(
      ChatConversationStarted(widget.channelId),
    );
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: BlocBuilder<ChatConversationBloc, ChatConversationState>(
        builder: (context, state) {
          return switch (state) {
            ChatConversationInitial() || ChatConversationLoading() =>
              const Center(child: CircularProgressIndicator()),
            ChatConversationFailure(:final failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  failure.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ChatConversationReady(
              :final messages,
              :final typingUserIds,
              :final failure,
              :final isSending,
            ) =>
              Column(
                children: [
                  if (failure != null)
                    Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(failure.message),
                      ),
                    ),
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.mutedText,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.body,
                                      style: AppTextStyles.body,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.editedAtUtc == null
                                          ? message.createdAtUtc
                                                .toLocal()
                                                .toString()
                                          : 'Edited ${message.editedAtUtc!.toLocal()}',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.mutedText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  if (typingUserIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Someone is typing…',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _composerController,
                              enabled: !isSending,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: isSending ? null : _send,
                            child: isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }

  void _send() {
    final body = _composerController.text;
    context.read<ChatConversationBloc>().add(ChatMessageSendRequested(body));
    _composerController.clear();
  }
}
