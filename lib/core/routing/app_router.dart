import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/bloc/channels_bloc.dart';
import '../../features/chat/presentation/bloc/chat_conversation_bloc.dart';
import '../../features/chat/presentation/pages/channels_list_page.dart';
import '../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../di/injection_container.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const CoreHomePage()),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/channels',
      builder: (context, state) => BlocProvider(
        create: (_) => serviceLocator<ChannelsBloc>(),
        child: const ChannelsListPage(),
      ),
    ),
    GoRoute(
      path: '/channels/:channelId',
      builder: (context, state) {
        final channelId = state.pathParameters['channelId'] ?? '';
        return BlocProvider(
          create: (_) => serviceLocator<ChatConversationBloc>(),
          child: ChatConversationPage(channelId: channelId),
        );
      },
    ),
  ],
);

final class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ultimate Solution')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/channels'),
              child: const Text('Channels'),
            ),
          ],
        ),
      ),
    );
  }
}
