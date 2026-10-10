import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_services.dart';
import '../widgets/empty_state.dart';

/// Placeholder home screen. Replace with your app's first screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.read<AppServices>();
    return Scaffold(
      appBar: AppBar(title: const Text('Starter App')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Hello'),
          Text('API: ${services.api.baseUrl}', key: const Key('api-base-url')),
          const Expanded(
            child: EmptyState(
              title: 'Nothing here yet',
              message: "Replace this placeholder with your app's content.",
            ),
          ),
        ],
      ),
    );
  }
}
