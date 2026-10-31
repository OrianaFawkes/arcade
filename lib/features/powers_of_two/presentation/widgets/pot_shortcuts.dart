import 'dart:ui_web' as ui_web;

import 'package:arcade/shared/presentation/widgets/shortcut_guide.dart';
import 'package:flutter/material.dart';

class PotShortcuts extends StatelessWidget {
  const PotShortcuts({super.key});

  @override
  Widget build(_) {
    final browser = ui_web.BrowserDetection.instance;

    return SizedBox(
      width: 320.0,
      child: Wrap(
        alignment: .center,
        spacing: 32.0,
        children: [
          if (browser.isMobile) ...[
            ShortcutGuide(description: 'move', keys: ['Directional swipe']),
          ] else ...[
            ShortcutGuide(description: 'move', keys: ['W A S D', 'Arrow keys']),
            ShortcutGuide(description: 'undo', keys: ['Z']),
            ShortcutGuide(description: 'restart', keys: ['R']),
            ShortcutGuide(description: 'settings', keys: ['Q']),
          ],
        ],
      ),
    );
  }
}
