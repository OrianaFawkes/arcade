import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/2048'),
          child: Text('2048'),
        ),
      ),
    );
  }
}
