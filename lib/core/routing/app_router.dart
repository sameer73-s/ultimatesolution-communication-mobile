import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const CoreHomePage()),
  ],
);

final class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ultimate Solution')),
      body: const Center(child: Text('Core setup is ready.')),
    );
  }
}
