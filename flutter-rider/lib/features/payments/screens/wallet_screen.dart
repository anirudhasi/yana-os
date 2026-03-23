import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/yana_button.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('₹ 1,240.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                _walletStat('Pending Dues', '₹120'),
                const SizedBox(width: 24),
                _walletStat('Incentives', '₹350'),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          YanaButton(label: 'Add Money via UPI', icon: Icons.add, onPressed: () {}),
          const SizedBox(height: 12),
          YanaButton(label: 'Pay Rent (₹120 due today)', icon: Icons.payment, outlined: true, onPressed: () {}),
          const SizedBox(height: 24),
          const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...[
            {'type': 'Rent Debit', 'amount': '-₹120', 'date': 'Today', 'icon': Icons.remove_circle, 'color': const Color(0xFFE74C3C)},
            {'type': 'Incentive Credit', 'amount': '+₹50', 'date': 'Yesterday', 'icon': Icons.add_circle, 'color': const Color(0xFF27AE60)},
            {'type': 'Wallet Top-up', 'amount': '+₹500', 'date': '21 Mar', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF2E86C1)},
            {'type': 'Rent Debit', 'amount': '-₹120', 'date': '20 Mar', 'icon': Icons.remove_circle, 'color': const Color(0xFFE74C3C)},
          ].map((t) => _txnRow(t)),
        ],
      ),
    );
  }

  Widget _walletStat(String label, String val) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ]);
  }

  Widget _txnRow(Map t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(children: [
        Icon(t['icon'] as IconData, color: t['color'] as Color, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['type'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(t['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        Text(t['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: t['color'] as Color, fontSize: 16)),
      ]),
    );
  }
}
