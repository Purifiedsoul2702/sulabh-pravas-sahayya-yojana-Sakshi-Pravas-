import 'package:go_router/go_router.dart';

import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/welcome_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

import '../screens/profile/profile_setup_screen.dart';
import '../screens/profile/college_schedule_screen.dart';
import '../screens/profile/profile_screen.dart';

import '../screens/home/home_screen.dart';

import '../screens/bus/bus_schedule_screen.dart';
import '../screens/bus/bus_details_screen.dart';

import '../screens/trip/plan_trip_screen.dart';
import '../screens/trip/active_journey_screen.dart';
import '../screens/trip/report_delay_screen.dart';
import '../screens/trip/travel_problem_screen.dart';
import '../screens/trip/reached_college_screen.dart';

import '../screens/location/nearby_stops_screen.dart';
import '../screens/safety/safety_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/history/travel_history_screen.dart';
import '../screens/notifications/notifications_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_collection_screen.dart';
import '../screens/admin/research_data_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // =========================================================
    // ONBOARDING
    // =========================================================

    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),

    GoRoute(
      path: '/language',
      builder: (_, __) => const LanguageScreen(),
    ),

    GoRoute(
      path: '/welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),

    // =========================================================
    // AUTHENTICATION
    // =========================================================

    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),

    // =========================================================
    // PROFILE
    // =========================================================

    GoRoute(
      path: '/profile-setup',
      builder: (_, __) => const ProfileSetupScreen(),
    ),

    GoRoute(
      path: '/college-schedule',
      builder: (_, __) => const CollegeScheduleScreen(),
    ),

    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),

    // =========================================================
    // HOME
    // =========================================================

    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),

    // =========================================================
    // BUS
    // =========================================================

    GoRoute(
      path: '/buses',
      builder: (_, __) => const BusScheduleScreen(),
    ),

    GoRoute(
      path: '/bus-details',
      builder: (_, state) => BusDetailsScreen(
        data: (state.extra as Map<String, String>?) ?? const {},
      ),
    ),

    // =========================================================
    // TRIP
    // =========================================================

    GoRoute(
      path: '/plan-trip',
      builder: (_, __) => const PlanTripScreen(),
    ),

    GoRoute(
      path: '/active-journey',
      builder: (_, state) => ActiveJourneyScreen(
        data: (state.extra as Map<String, String>?) ?? const {},
      ),
    ),

    GoRoute(
      path: '/report-delay',
      builder: (_, state) => ReportDelayScreen(
        data: (state.extra as Map<String, String>?) ?? const {},
      ),
    ),

    GoRoute(
      path: '/travel-problem',
      builder: (_, state) => TravelProblemScreen(
        data: (state.extra as Map<String, String>?) ?? const {},
      ),
    ),

    GoRoute(
      path: '/reached-college',
      builder: (_, state) => ReachedCollegeScreen(
        data: (state.extra as Map<String, String>?) ?? const {},
      ),
    ),

    // =========================================================
    // LOCATION / SAFETY
    // =========================================================

    GoRoute(
      path: '/nearby-stops',
      builder: (_, __) => const NearbyStopsScreen(),
    ),

    GoRoute(
      path: '/safety',
      builder: (_, __) => const SafetyScreen(),
    ),

    // =========================================================
    // ATTENDANCE / HISTORY / NOTIFICATIONS
    // =========================================================

    GoRoute(
      path: '/attendance',
      builder: (_, __) => const AttendanceScreen(),
    ),

    GoRoute(
      path: '/travel-history',
      builder: (_, __) => const TravelHistoryScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),

    // =========================================================
    // ADMIN DASHBOARD
    // =========================================================

    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminDashboardScreen(),
    ),

    // =========================================================
    // ADMIN - PRE/POST RESEARCH DATA
    // =========================================================

    GoRoute(
      path: '/admin/research-data',
      builder: (_, __) => const ResearchDataScreen(),
    ),

    // =========================================================
    // ADMIN - RESEARCH RECORDS
    // =========================================================

    GoRoute(
      path: '/admin/students',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'users',
        title: 'Students',
      ),
    ),

    GoRoute(
      path: '/admin/delay-reports',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'delayReports',
        title: 'Delay Reports',
      ),
    ),

    GoRoute(
      path: '/admin/travel-problems',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'travelProblems',
        title: 'Travel Problems',
      ),
    ),

    // =========================================================
    // FILTERED ATTENDANCE RECORDS
    // =========================================================

    GoRoute(
      path: '/admin/late-arrivals',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'attendance',
        title: 'Late Arrivals',
        filterType: 'lateArrivals',
      ),
    ),

    GoRoute(
      path: '/admin/transport-absences',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'attendance',
        title: 'Transport Absences',
        filterType: 'transportAbsences',
      ),
    ),

    // =========================================================
    // ADMIN - BUS MANAGEMENT
    // =========================================================

    GoRoute(
      path: '/admin/routes',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'routes',
        title: 'Routes',
      ),
    ),

    GoRoute(
      path: '/admin/stops',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'busStops',
        title: 'Bus Stops',
      ),
    ),

    GoRoute(
      path: '/admin/buses',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'buses',
        title: 'Buses',
      ),
    ),

    GoRoute(
      path: '/admin/schedules',
      builder: (_, __) => const AdminCollectionScreen(
        collection: 'busSchedules',
        title: 'Bus Schedules',
      ),
    ),
  ],
);