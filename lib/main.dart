import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app_services.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final services = await AppServices.bootstrap();
  runApp(StarterApp(services: services));
}

class StarterApp extends StatelessWidget {
  const StarterApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Provider<AppServices>.value(
      value: services,
      child: MaterialApp(
        title: 'Starter App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
