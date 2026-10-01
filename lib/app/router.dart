import 'package:arcade/app/screens/not_found_screen.dart';
import 'package:arcade/features/2048/presentation/a_2048_screen.dart';
import 'package:arcade/features/arcade/arcade_screen.dart';
import 'package:arcade/features/minesweeper/presentation/minesweeper_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, _) => NoTransitionPage(child: ArcadeScreen()),
      ),
      GoRoute(
        path: '/2048',
        pageBuilder: (_, _) => NoTransitionPage(child: A2048Screen()),
      ),
      GoRoute(
        path: '/minesweeper',
        pageBuilder: (_, _) => NoTransitionPage(child: MinesweeperScreen()),
      ),
    ],
    errorBuilder: (_, _) => NotFoundScreen(),
    initialLocation: '/',
  );
}
