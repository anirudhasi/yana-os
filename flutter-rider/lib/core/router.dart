import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/otp_screen.dart';
import '../features/onboarding/screens/profile_setup_screen.dart';
import '../features/onboarding/screens/kyc_screen.dart';
import '../features/onboarding/screens/status_screen.dart';
import '../features/vehicle/screens/vehicle_list_screen.dart';
import '../features/vehicle/screens/vehicle_detail_screen.dart';
import '../features/payments/screens/wallet_screen.dart';
import '../features/support/screens/support_screen.dart';
import '../features/skilldev/screens/skill_screen.dart';
import '../shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (ctx, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (ctx, state) => const OTPScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (ctx, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/kyc',
      builder: (ctx, state) => const KYCScreen(),
    ),
    GoRoute(
      path: '/status',
      builder: (ctx, state) => const OnboardingStatusScreen(),
    ),
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (ctx, state) => const VehicleListScreen(),
        ),
        GoRoute(
          path: '/vehicle/:id',
          builder: (ctx, state) => VehicleDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/wallet',
          builder: (ctx, state) => const WalletScreen(),
        ),
        GoRoute(
          path: '/support',
          builder: (ctx, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/skills',
          builder: (ctx, state) => const SkillScreen(),
        ),
      ],
    ),
  ],
);
