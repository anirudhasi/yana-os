import 'package:flutter/material.dart';
import '../../../shared/widgets/yana_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('How can we help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[
            {'icon': Icons.electric_scooter, 'title': 'Vehicle Issue', 'sub': 'Breakdown, battery, damage'},
            {'icon': Icons.payment, 'title': 'Payment Issue', 'sub': 'Wrong deduction, refund'},
            {'icon': Icons.person, 'title': 'Account Issue', 'sub': 'KYC, profile, login'},
            {'icon': Icons.work, 'title': 'Job / Gig Issue', 'sub': 'Order, customer complaint'},
            {'icon': Icons.other_houses, 'title': 'Other', 'sub': 'Anything else'},
          ].map((c) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFFD6EAF8), child: Icon(c['icon'] as IconData, color: const Color(0xFF1A5276))),
              title: Text(c['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(c['sub'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showTicketSheet(context, c['title'] as String),
            ),
          )),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('My Tickets', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ticketRow('Vehicle battery issue', 'In Progress', const Color(0xFFD68910)),
          _ticketRow('Payment deduction incorrect', 'Resolved', const Color(0xFF1E8449)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.chat),
        label: const Text('WhatsApp Support'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  Widget _ticketRow(String title, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Text('22 Mar 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  void _showTicketSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Raise $category Ticket', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(maxLines: 4, decoration: const InputDecoration(labelText: 'Describe your issue', alignLabelWithHint: true)),
          const SizedBox(height: 16),
          YanaButton(label: 'Submit Ticket', icon: Icons.send, onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket raised! We\'ll respond within 2 hours.')));
          }),
        ]),
      ),
    );
  }
}
