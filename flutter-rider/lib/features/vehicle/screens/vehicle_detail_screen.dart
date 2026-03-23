import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/yana_button.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String id;
  const VehicleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EAF8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Icon(Icons.electric_scooter, size: 100, color: Color(0xFF1A5276))),
          ),
          const SizedBox(height: 20),
          const Text('Hero Electric Optima', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('KA-01-AB-1234', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          const SizedBox(height: 20),
          Row(children: [
            _statCard('Battery', '82%', Icons.battery_charging_full, const Color(0xFF1E8449)),
            const SizedBox(width: 12),
            _statCard('Odometer', '12,400 km', Icons.speed, AppTheme.primary),
            const SizedBox(width: 12),
            _statCard('Range', '~65 km', Icons.map, const Color(0xFFD68910)),
          ]),
          const SizedBox(height: 20),
          _infoRow('Hub', 'Koramangala Hub'),
          _infoRow('Manufacturer', 'Hero Electric'),
          _infoRow('Type', '2-Wheeler EV'),
          _infoRow('Last serviced', '12 Feb 2026'),
          _infoRow('Daily rent', '₹120'),
          const SizedBox(height: 32),
          YanaButton(label: 'Book this Vehicle', icon: Icons.electric_scooter, onPressed: () => _showBookingSheet(context)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ));
  }

  Widget _infoRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        SizedBox(width: 130, child: Text(key, style: const TextStyle(color: Colors.grey))),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Confirm Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Rental Plan'),
            items: ['Daily (₹120/day)', 'Weekly (₹750/week)', 'Monthly (₹2,800/month)']
                .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Start Date'), readOnly: true)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'End Date'), readOnly: true)),
          ]),
          const SizedBox(height: 24),
          YanaButton(label: 'Request Booking', icon: Icons.check, onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request sent! Ops team will confirm shortly.'), backgroundColor: Color(0xFF1E8449)));
          }),
        ]),
      ),
    );
  }
}
