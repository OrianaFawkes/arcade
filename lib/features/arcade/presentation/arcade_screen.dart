import 'dart:ui_web' as ui_web;

import 'package:arcade/features/arcade/presentation/arcade_world_card.dart';
import 'package:arcade/shared/presentation/widgets/shortcut_guide.dart';
import 'package:arcade/shared/presentation/widgets/text_link.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_padding/smart_padding.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final browser = ui_web.BrowserDetection.instance;

    return Scaffold(
      appBar: AppBar(title: Text('Arcade')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          spacing: 16.0,
          children: [
            Expanded(
              child: Align(
                alignment: .center,
                child: SmartPadding(
                  horizontal: 24.0,
                  child: SizedBox(width: 1080.0, child: ArcadeWorldCard()),
                ),
              ),
            ),
            Align(
              alignment: .center,
              child: SmartPadding(
                horizontal: 24.0,
                child: SizedBox(
                  width: 720.0,
                  child: Wrap(
                    alignment: .center,
                    spacing: 32.0,
                    children: [
                      if (browser.isMobile) ...[
                        ShortcutGuide(
                          description: 'move',
                          keys: ['Tap a floor tile'],
                        ),
                        ShortcutGuide(
                          description: 'interact',
                          keys: ['Tap an object'],
                        ),
                      ] else ...[
                        ShortcutGuide(
                          description: 'move',
                          keys: ['W A S D', 'Arrow keys', 'Click a floor tile'],
                        ),
                        ShortcutGuide(
                          description: 'move then interact',
                          keys: ['Click an object'],
                        ),
                        ShortcutGuide(
                          description: 'interact',
                          keys: ['E', 'Enter'],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: .center,
              child: SmartPadding(
                horizontal: 24.0,
                bottom: 16.0,
                child: SizedBox(
                  width: 1080.0,
                  child: Row(
                    children: [
                      TextLink(
                        label: 'Privacy',
                        onTap: () => context.go('/privacy'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
