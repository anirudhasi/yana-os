import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

class SkillScreen extends StatelessWidget {
  const SkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Development')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF1E8449)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Text('🏆', style: TextStyle(fontSize: 28))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Your Points: 320', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Silver Rider Badge', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('80 points to Gold!', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Training Modules', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...[
            {'title': 'Delivery Etiquette', 'duration': '8 min', 'done': true, 'points': 50},
            {'title': 'App Usage Guide', 'duration': '5 min', 'done': true, 'points': 30},
            {'title': 'Road Safety & EV Care', 'duration': '12 min', 'done': false, 'points': 80},
            {'title': 'Customer Handling', 'duration': '10 min', 'done': false, 'points': 60},
            {'title': 'Emergency Protocols', 'duration': '7 min', 'done': false, 'points': 50},
          ].map((v) => _videoCard(context, v)),
        ],
      ),
    );
  }

  Widget _videoCard(BuildContext context, Map v) {
    final done = v['done'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? const Color(0xFF27AE60) : const Color(0xFFEEEEEE)),
      ),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: done ? const Color(0xFFD5F5E3) : const Color(0xFFD6EAF8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(done ? Icons.check_circle : Icons.play_circle_filled,
              color: done ? const Color(0xFF1E8449) : AppTheme.primary, size: 28),
        ),
        title: Text(v['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(children: [
          const Icon(Icons.access_time, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(v['duration'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 12),
          const Icon(Icons.star, size: 12, color: Color(0xFFD68910)),
          const SizedBox(width: 4),
          Text('+${v['points']} pts', style: const TextStyle(fontSize: 12, color: Color(0xFFD68910), fontWeight: FontWeight.w600)),
        ]),
        trailing: done ? const StatusIcon(done: true) : ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(minimumSize: const Size(60, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
          child: const Text('Start', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

class StatusIcon extends StatelessWidget {
  final bool done;
  const StatusIcon({super.key, required this.done});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFD5F5E3), borderRadius: BorderRadius.circular(20)),
    child: const Text('Done', style: TextStyle(color: Color(0xFF1E8449), fontSize: 11, fontWeight: FontWeight.bold)),
  );
}
