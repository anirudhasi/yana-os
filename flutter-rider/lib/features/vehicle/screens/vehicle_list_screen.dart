import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';

final vehiclesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final res = await dio.get('/fleet/vehicles/available/');
  return res.data is List ? res.data : (res.data['results'] ?? []);
});

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Vehicles'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by hub or vehicle type...',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.electric_scooter, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No vehicles loaded', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                // Fallback demo data
                _buildDemoList(context),
              ])),
              data: (vehicles) => vehicles.isEmpty
                ? _buildDemoList(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vehicles.length,
                    itemBuilder: (ctx, i) => _VehicleCard(vehicle: vehicles[i]),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoList(BuildContext context) {
    final demos = [
      {'id': 'v1', 'registration_number': 'KA-01-AB-1234', 'model': 'Hero Electric Optima', 'hub_name': 'Koramangala Hub', 'battery_health_pct': 82.0, 'odometer_km': 12400.0, 'status': 'available', 'daily_rent': 120},
      {'id': 'v2', 'registration_number': 'KA-01-CD-5678', 'model': 'Bounce Infinity E1', 'hub_name': 'HSR Layout Hub', 'battery_health_pct': 54.0, 'odometer_km': 8220.0, 'status': 'available', 'daily_rent': 100},
      {'id': 'v3', 'registration_number': 'KA-03-EF-9012', 'model': 'Ather Rizta', 'hub_name': 'Whitefield Hub', 'battery_health_pct': 95.0, 'odometer_km': 3100.0, 'status': 'available', 'daily_rent': 150},
    ];
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: demos.length,
      itemBuilder: (ctx, i) => _VehicleCard(vehicle: demos[i]),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final battery = (vehicle['battery_health_pct'] ?? 0).toDouble();
    final batteryColor = battery > 70 ? const Color(0xFF1E8449) : battery > 40 ? const Color(0xFFD68910) : const Color(0xFF922B21);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/vehicle/${vehicle['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFFD6EAF8), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.electric_scooter, color: Color(0xFF1A5276), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vehicle['model'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(vehicle['registration_number'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ])),
              StatusBadge(vehicle['status'] ?? 'available'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(vehicle['hub_name'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Text('₹${vehicle['daily_rent'] ?? 0}/day', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4F72), fontSize: 15)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.battery_charging_full, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${battery.toInt()}%', style: TextStyle(fontSize: 12, color: batteryColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: battery / 100, color: batteryColor, backgroundColor: Colors.grey[200], minHeight: 6),
              )),
              const SizedBox(width: 12),
              const Icon(Icons.speed, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${((vehicle['odometer_km'] ?? 0) / 1000).toStringAsFixed(1)}k km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ]),
          ]),
        ),
      ),
    );
  }
}
