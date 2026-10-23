import 'package:flutter/material.dart';

import 'package:arcade/app/analytics/analytics_consent_controller.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy & analytics')),
      body: ListView(
        padding: .all(24.0),
        children: [
          Text(
            'Your choice matters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 12.0),
          Text(
            'Arcade is designed to be usable without an account. '
            'Optional Google Analytics helps us understand overall '
            'site traffic and which pages are visited.',
          ),
          SizedBox(height: 20.0),
          Text(
            'What analytics may collect',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.0),
          Text(
            'When enabled, Google Analytics may process page-view '
            'information, browser and device information, referral '
            'information, and related usage data. The precise data '
            'collected depends on the Google Analytics configuration.',
          ),
          SizedBox(height: 28),
          AnimatedBuilder(
            animation: analyticsConsentController,
            builder: (context, _) {
              final controller = analyticsConsentController;

              final status = !controller.analyticsAvailableHere
                  ? 'Analytics is not active in this build or hostname.'
                  : switch (controller.choice) {
                      .accepted => 'You have allowed analytics.',
                      .rejected => 'You have rejected analytics.',
                      .undecided =>
                        'You have not made an analytics choice yet.',
                    };

              return Column(
                crossAxisAlignment: .start,
                spacing: 12.0,
                children: [
                  Text(status, style: Theme.of(context).textTheme.titleMedium),
                  if (controller.analyticsAvailableHere) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            controller.setChoice(.rejected);
                          },
                          child: Text('Reject / withdraw consent'),
                        ),
                        FilledButton(
                          onPressed: () {
                            controller.setChoice(.accepted);
                          },
                          child: Text('Allow analytics'),
                        ),
                      ],
                    ),
                    if (controller.choice != .undecided) ...[
                      TextButton(
                        onPressed: () {
                          controller.setChoice(.undecided);
                        },
                        child: Text('Reset my choice'),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
