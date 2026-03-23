import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home') || location.startsWith('/vehicle')) return 0;
    if (location.startsWith('/wallet')) return 1;
    if (location.startsWith('/skills')) return 2;
    if (location.startsWith('/support')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/wallet'); break;
            case 2: context.go('/skills'); break;
            case 3: context.go('/support'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.electric_scooter), label: 'Vehicle'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Skills'),
          NavigationDestination(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }
}
