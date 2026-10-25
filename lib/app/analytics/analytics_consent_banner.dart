import 'dart:ui_web' as ui_web;

import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:arcade/shared/presentation/widgets/pixel_button.dart';
import 'package:flutter/material.dart';
import 'package:smart_padding/smart_padding.dart';
import 'analytics_consent_controller.dart';

class AnalyticsConsentBanner extends StatelessWidget {
  final Widget child;

  const AnalyticsConsentBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: analyticsConsentController,
      builder: (context, _) {
        final browser = ui_web.BrowserDetection.instance;

        final controller = analyticsConsentController;

        final shouldShow =
            controller.analyticsAvailableHere &&
            controller.choice == .undecided;

        return Stack(
          fit: .expand,
          children: [
            AbsorbPointer(absorbing: shouldShow, child: child),
            if (shouldShow) ...[
              Positioned(
                left: browser.isMobile ? 0 : null,
                top: browser.isMobile ? 0 : null,
                right: browser.isMobile ? 0 : null,
                bottom: 0,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: SmartPadding(all: 24.0, child: _ConsentDialog()),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DialogContainer(
      width: 320.0,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        spacing: 16.0,
        children: [
          Text(
            'Welcome to the arcade!\nMind the dust.',
            style: textTheme.titleMedium,
          ),
          Text(
            "Hi, I'm Ori! I use optional Google Analytics to get a rough "
            'idea of which rooms get visited. It stays inactive until '
            'you say otherwise.',
            style: textTheme.bodyMedium,
          ),
          PixelButton(
            height: 36.0,
            fillColor: Color(0xFF36343D),
            borderColor: Color(0xFFF2D3F2),
            onPressed: () {
              analyticsConsentController.setChoice(.rejected);
            },
            child: Text('Reject analytics', style: textTheme.bodyLarge),
          ),
          PixelButton(
            height: 36.0,
            onPressed: () {
              analyticsConsentController.setChoice(.accepted);
            },
            child: Text(
              'Allow analytics',
              style: textTheme.bodyLarge?.copyWith(color: Color(0xFF383138)),
            ),
          ),
        ],
      ),
    );
  }
}
