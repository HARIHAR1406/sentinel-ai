import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'features/home/home_screen.dart';
import 'features/map/map_screen.dart';
import 'features/incident/report_incident_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/incident/incident_tracking_screen.dart';
import 'features/profile/trusted_contacts_screen.dart';
import 'features/profile/settings_screen.dart';
import 'features/ai_assistant/safety_assistant_screen.dart';
import 'features/incident/nearby_incidents_screen.dart';
import 'features/incident/historical_safety_screen.dart';
import 'features/map/location_risk_screen.dart';
import 'features/map/route_comparison_screen.dart';
import 'features/map/saved_locations_screen.dart';
import 'features/ai_assistant/ai_safety_suggestions_screen.dart';
import 'features/ai_assistant/ai_classification_preview_screen.dart';
import 'features/profile/emergency_support_screen.dart';
import 'features/profile/trip_safety_mode_screen.dart';
import 'features/profile/about_screen.dart';
import 'features/admin/incident_verification_screen.dart';
import 'features/incident/incident_detail_screen.dart';
import 'features/notifications/notification_center_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'data/models/incident_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider).value;
      final isAuth = authState != null;
      
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/';
      final isGoingToForgot = state.matchedLocation == '/forgot_password';
      
      final isPublicRoute = isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToForgot;

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportIncidentScreen(),
      ),
      GoRoute(
        path: '/incident_tracking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IncidentTrackingScreen(),
      ),
      GoRoute(
        path: '/trusted_contacts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/safety_assistant',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SafetyAssistantScreen(),
      ),
      GoRoute(path: '/nearby_incidents', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const NearbyIncidentsScreen()),
      GoRoute(path: '/location_risk', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const LocationRiskScreen()),
      GoRoute(path: '/route_comparison', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const RouteComparisonScreen()),
      GoRoute(path: '/ai_safety_suggestions', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AiSafetySuggestionsScreen()),
      GoRoute(path: '/historical_safety', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const HistoricalSafetyScreen()),
      GoRoute(path: '/ai_classification_preview', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AiClassificationPreviewScreen()),
      GoRoute(path: '/emergency_support', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const EmergencySupportScreen()),
      GoRoute(path: '/trip_safety_mode', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const TripSafetyModeScreen()),
      GoRoute(path: '/saved_locations', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const SavedLocationsScreen()),
      GoRoute(path: '/incident_verification', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const IncidentVerificationScreen()),
      GoRoute(path: '/about', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AboutScreen()),
      GoRoute(
        path: '/incident_detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final incident = state.extra as IncidentModel;
          return IncidentDetailScreen(incident: incident);
        },
      ),
      GoRoute(path: '/notifications', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const NotificationCenterScreen()),
    ],
  );
});

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/report'),
        backgroundColor: AppColors.sentinelBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
