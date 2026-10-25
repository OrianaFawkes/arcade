import 'package:arcade/shared/presentation/widgets/pixel_button.dart';
import 'package:flutter/material.dart';

import 'package:arcade/app/analytics/analytics_consent_controller.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text('Privacy & analytics'),
      ),
      body: ListView(
        padding: .all(24.0),
        children: [
          Text('A note from Ori', style: textTheme.titleMedium),
          SizedBox(height: 4.0),
          Text(
            'Welcome! The Arcade is a little place in an Empty Space. '
            'You can wander through it without making an account. '
            'I use optional Google Analytics to get a rough idea '
            'of how the place is visited and which pages people open. '
            'It is not a guestbook, a security camera, or a headcount '
            'of everyone who walks through the door.',
          ),
          SizedBox(height: 16.0),
          Text('What gets observed?', style: textTheme.titleMedium),
          SizedBox(height: 4.0),
          Text(
            'If you allow analytics, Google Analytics may process '
            'page views, page addresses and titles, browser and '
            'device information, referral information, and related '
            'usage data. I have restricted some advertising-'
            'related signals, but this does not make analytics '
            'completely cookieless or anonymous.',
          ),
          SizedBox(height: 16.0),
          Text('Your choice', style: textTheme.titleMedium),
          SizedBox(height: 4.0),
          Text(
            'Analytics starts only if you allow it. If you decline, '
            'the Google Analytics tag is not loaded by this site. '
            'You can change your choice here at any time. Withdrawing '
            'consent stops future collection through this integration; '
            'it does not erase information already sent to Google.',
          ),
          SizedBox(height: 16.0),
          Text('Where the data goes', style: textTheme.titleMedium),
          SizedBox(height: 4.0),
          Text(
            'Google provides the analytics service and processes '
            'the data it receives under its applicable terms and '
            'privacy practices. Data retention depends on the '
            'Google Analytics property settings. For more details, '
            "see Google's privacy information: "
            'https://policies.google.com/privacy',
          ),
          Text(
            'The numbers are imperfect. Some visitors keep '
            'analytics inactive; some traffic may be automated; and '
            'the reports may not represent every visit. I use the '
            'numbers as rough observations, not as a definitive '
            'record of who came here.',
          ),
          SizedBox(height: 24.0),
          AnimatedBuilder(
            animation: analyticsConsentController,
            builder: (context, _) {
              final controller = analyticsConsentController;

              final status = !controller.analyticsAvailableHere
                  ? 'Analytics is not active in this domain.'
                  : switch (controller.choice) {
                      .accepted => 'You have allowed analytics.',
                      .rejected => 'You have rejected analytics.',
                      .undecided =>
                        'You have not made an analytics choice yet.',
                    };

              return Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: 16.0,
                children: [
                  Text(status, style: textTheme.titleMedium),
                  if (controller.analyticsAvailableHere) ...[
                    if (controller.choice != .undecided) ...[
                      PixelButton(
                        height: 36.0,
                        onPressed: () {
                          controller.setChoice(.undecided);
                        },
                        child: Text(
                          'Reset my choice',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Color(0xFF383138),
                          ),
                        ),
                      ),
                    ] else ...[
                      PixelButton(
                        height: 36.0,
                        fillColor: Color(0xFF383138),
                        borderColor: Color(0xFFF2D3F2),
                        onPressed: () {
                          controller.setChoice(.rejected);
                        },
                        child: Text(
                          'Reject analytics',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      PixelButton(
                        height: 36.0,
                        onPressed: () {
                          controller.setChoice(.accepted);
                        },
                        child: Text(
                          'Allow analytics',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Color(0xFF383138),
                          ),
                        ),
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
