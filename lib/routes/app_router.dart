import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/defect_details/defect_details_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/enhanced_bottom_nav.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: '/',
      navigatorKey: _rootNavigatorKey,
      refreshListenable: appState,
      redirect: (context, state) {
        final isAuthenticated = appState.isAuthenticated;
        final isAuthPath = state.matchedLocation == '/signin' || 
                           state.matchedLocation == '/signup' ||
                           state.matchedLocation == '/onboarding' ||
                           state.matchedLocation == '/';

        if (!isAuthenticated && !isAuthPath) {
          return '/signin';
        }

        if (isAuthenticated && isAuthPath && state.matchedLocation != '/') {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/signin',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/signup',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SignUpScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return Scaffold(
              body: child,
              bottomNavigationBar: EnhancedBottomNavigationBar(
                currentIndex: _getSelectedIndex(state.matchedLocation),
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/about',
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/scanner',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ScannerScreen(),
        ),
        GoRoute(
          path: '/analysis',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            if (state.extra is Map<String, dynamic>) {
              final extra = state.extra as Map<String, dynamic>;
              final rawBytes = extra['bytes'];
              Uint8List? bytes;
              if (rawBytes is Uint8List) {
                bytes = rawBytes;
              } else if (rawBytes is List) {
                bytes = Uint8List.fromList(List<int>.from(rawBytes));
              }
              
              return AnalysisScreen(
                imagePath: extra['path'] as String?,
                imageBytes: bytes,
              );
            }
            final imagePath = state.extra as String?;
            return AnalysisScreen(imagePath: imagePath);
          },
        ),
        GoRoute(
          path: '/result',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ResultScreen(),
        ),
        GoRoute(
          path: '/defect-details',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DefectDetailsScreen(),
        ),
      ],
    );
  }

  static int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/scanner')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/about')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }
}
