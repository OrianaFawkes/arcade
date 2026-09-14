import 'package:arcade/app/router.dart';
import 'package:flutter/material.dart';
import 'package:arcade/app/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(_) {
    final theme = createTheme();

    final router = createRouter();

    return MaterialApp.router(
      routerConfig: router,
      title: 'Arcade',
      theme: theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
