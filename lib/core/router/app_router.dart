import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/game_screen.dart';
import '../../presentation/screens/result_screen.dart';
import '../../presentation/screens/analytics_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/level_select_screen.dart';
import '../../presentation/screens/custom_mode_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../data/models/game_session.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',   // ← mulai dari splash
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          onComplete: () => context.go('/home'),
        ),
      ),
      GoRoute(path: '/home',      builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/levels',    builder: (_, __) => const LevelSelectScreen()),
      GoRoute(path: '/custom',    builder: (_, __) => const CustomModeScreen()),
      GoRoute(path: '/game',      builder: (_, __) => const GameScreen()),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final session = state.extra as GameSession;
          return ResultScreen(session: session);
        },
      ),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      GoRoute(path: '/settings',  builder: (_, __) => const SettingsScreen()),
    ],
  );
}