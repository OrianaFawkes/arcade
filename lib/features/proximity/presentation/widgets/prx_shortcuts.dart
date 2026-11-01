import 'dart:ui_web' as ui_web;

import 'package:arcade/shared/presentation/widgets/shortcut_guide.dart';
import 'package:flutter/material.dart';

class PrxShortcuts extends StatelessWidget {
  const PrxShortcuts({super.key});

  @override
  Widget build(_) {
    final browser = ui_web.BrowserDetection.instance;

    return SizedBox(
      width: 360.0,
      child: Wrap(
        alignment: .center,
        spacing: 32.0,
        children: [
          if (browser.isMobile) ...[
            ShortcutGuide(description: 'open', keys: ['Tap']),
            ShortcutGuide(description: 'flag', keys: ['Hold']),
          ] else ...[
            ShortcutGuide(description: 'open', keys: ['Click']),
            ShortcutGuide(description: 'flag', keys: ['Hold']),
            ShortcutGuide(description: 'change difficulty', keys: ['D']),
            ShortcutGuide(description: 'restart', keys: ['R']),
          ],
        ],
      ),
    );
  }
}
