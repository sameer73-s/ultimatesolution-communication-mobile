import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/channels_bloc.dart';

final class ChannelsListPage extends StatefulWidget {
  const ChannelsListPage({super.key});

  @override
  State<ChannelsListPage> createState() => _ChannelsListPageState();
}

final class _ChannelsListPageState extends State<ChannelsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChannelsBloc>().add(const ChannelsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: BlocBuilder<ChannelsBloc, ChannelsState>(
        builder: (context, state) {
          return switch (state) {
            ChannelsInitial() || ChannelsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ChannelsFailure(:final failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      failure.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<ChannelsBloc>().add(
                        const ChannelsLoadRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            ChannelsLoaded(:final channels) when channels.isEmpty => Center(
              child: Text(
                'No channels yet.',
                style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
              ),
            ),
            ChannelsLoaded(:final channels) => ListView.separated(
              itemCount: channels.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  title: Text(channel.name),
                  subtitle: Text(
                    channel.isArchived ? 'Archived' : channel.type.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () => context.go('/channels/${channel.id}'),
                );
              },
            ),
          };
        },
      ),
    );
  }
}
