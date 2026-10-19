import 'package:arcade/app/screens/not_found_screen.dart';
import 'package:arcade/features/powers_of_two/presentation/powers_of_two_screen.dart';
import 'package:arcade/features/arcade/presentation/arcade_screen.dart';
import 'package:arcade/features/proximity/presentation/proximity_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, _) => NoTransitionPage(child: ArcadeScreen()),
      ),
      GoRoute(
        path: '/powers-of-two',
        pageBuilder: (_, _) => NoTransitionPage(child: PowersOfTwoScreen()),
      ),
      GoRoute(
        path: '/proximity',
        pageBuilder: (_, _) => NoTransitionPage(child: ProximityScreen()),
      ),
    ],
    errorBuilder: (_, _) => NotFoundScreen(),
    initialLocation: '/',
  );
}
