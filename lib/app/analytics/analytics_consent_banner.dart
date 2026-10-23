import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        final controller = analyticsConsentController;

        final shouldShow =
            controller.analyticsAvailableHere &&
            controller.choice == .undecided;

        return Stack(
          fit: .expand,
          children: [
            child,
            if (shouldShow) ...[
              Align(
                alignment: .bottomCenter,
                child: SafeArea(
                  minimum: .all(16.0),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 280),
                      child: Material(
                        elevation: 8,
                        borderRadius: .circular(16.0),
                        clipBehavior: .antiAlias,
                        child: SmartPadding(
                          all: 24.0,
                          child: Column(
                            mainAxisSize: .min,
                            crossAxisAlignment: .start,
                            spacing: 8.0,
                            children: [
                              Text(
                                'A little analytics, by choice.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Optional Google Analytics helps us '
                                'understand visits to Arcade and which '
                                'pages people use. It stays off unless '
                                'you choose to allow it.',
                              ),
                              TextButton(
                                onPressed: () => context.push('/privacy'),
                                child: const Text('Read the privacy notice'),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      analyticsConsentController.setChoice(
                                        .rejected,
                                      );
                                    },
                                    child: Text('Reject analytics'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      analyticsConsentController.setChoice(
                                        .accepted,
                                      );
                                    },
                                    child: Text('Allow analytics'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
