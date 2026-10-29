import 'package:arcade/app/screens/not_found_screen.dart';
import 'package:arcade/app/screens/privacy_screen.dart';
import 'package:arcade/features/powers_of_two/presentation/powers_of_two_screen.dart';
import 'package:arcade/features/arcade/presentation/arcade_screen.dart';
import 'package:arcade/features/proximity/presentation/proximity_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, _) => NoTransitionPage(
          child: Title(
            title: 'Arcade',
            color: Color(0xFF000000),
            child: ArcadeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/powers-of-two',
        pageBuilder: (_, _) => NoTransitionPage(
          child: Title(
            title: 'Arcade | Powers of Two',
            color: Color(0xFF000000),
            child: PowersOfTwoScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/proximity',
        pageBuilder: (_, _) => NoTransitionPage(
          child: Title(
            title: 'Arcade | Proximity',
            color: Color(0xFF000000),
            child: ProximityScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (_, _) => NoTransitionPage(
          child: Title(
            title: 'Arcade | Privacy',
            color: Color(0xFF000000),
            child: PrivacyScreen(),
          ),
        ),
      ),
    ],
    errorBuilder: (_, _) => NotFoundScreen(),
    initialLocation: '/',
  );
}
