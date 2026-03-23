import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  Color get _bg => switch (status.toLowerCase()) {
    'active' => const Color(0xFFD5F5E3),
    'applied' => const Color(0xFFD6EAF8),
    'kyc_verified' || 'verified' => const Color(0xFFD5F5E3),
    'kyc_pending' || 'pending' => const Color(0xFFFEF9E7),
    'rejected' => const Color(0xFFFDECEC),
    'available' => const Color(0xFFD5F5E3),
    'allocated' => const Color(0xFFD6EAF8),
    'maintenance' => const Color(0xFFFDECEC),
    _ => const Color(0xFFF2F3F4),
  };

  Color get _fg => switch (status.toLowerCase()) {
    'active' || 'kyc_verified' || 'verified' || 'available' => const Color(0xFF1E8449),
    'applied' || 'allocated' => const Color(0xFF1A5276),
    'kyc_pending' || 'pending' => const Color(0xFF7D6608),
    'rejected' || 'maintenance' => const Color(0xFF922B21),
    _ => const Color(0xFF626567),
  };

  String get _label => status.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_label, style: TextStyle(color: _fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
