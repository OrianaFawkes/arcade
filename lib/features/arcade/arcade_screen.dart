import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 16.0,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/2048'),
              child: Text('2048'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/minesweeper'),
              child: Text('Minesweeper'),
            ),
          ],
        ),
      ),
    );
  }
}
