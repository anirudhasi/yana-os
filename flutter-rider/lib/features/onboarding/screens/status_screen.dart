import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';

class OnboardingStatusScreen extends ConsumerWidget {
  const OnboardingStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.hourglass_top, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 28),
                const Text('Application Under Review', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text('Our team is verifying your documents. You\'ll receive a notification within 24 hours.', style: TextStyle(color: Colors.white70, fontSize: 15), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                _stepItem('Applied', true),
                _stepItem('Documents submitted', true),
                _stepItem('KYC verification', false, active: true),
                _stepItem('Training', false),
                _stepItem('Active rider', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String label, bool done, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 28, height: 28, decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppTheme.secondary : (active ? Colors.white : Colors.white24),
          ),
          child: Icon(done ? Icons.check : (active ? Icons.circle : Icons.circle_outlined),
              color: done ? Colors.white : (active ? AppTheme.primary : Colors.white38), size: 16),
        ),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: done || active ? Colors.white : Colors.white54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
      ]),
    );
  }
}
