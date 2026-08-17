import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
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
import 'shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
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
    // Generic routes replaced with real screens
    GoRoute(path: '/nearby_incidents', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const NearbyIncidentsScreen()),
    GoRoute(path: '/location_risk', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const LocationRiskScreen()),
    GoRoute(path: '/route_comparison', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const RouteComparisonScreen()),
    GoRoute(path: '/ai_safety_suggestions', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AiSafetySuggestionsScreen()),
    GoRoute(path: '/historical_safety', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const HistoricalSafetyScreen()),
    GoRoute(path: '/ai_classification_preview', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AiClassificationPreviewScreen()),
    GoRoute(path: '/emergency_support', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const EmergencySupportScreen()),
    GoRoute(path: '/trip_safety_mode', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const TripSafetyModeScreen()),
    GoRoute(path: '/saved_locations', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const SavedLocationsScreen()),
    GoRoute(path: '/about', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const AboutScreen()),
  ],
);

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
