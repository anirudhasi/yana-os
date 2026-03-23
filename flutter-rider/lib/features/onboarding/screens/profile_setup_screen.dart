import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../shared/widgets/yana_button.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _language = 'hi';
  bool _loading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'label': 'हिंदी (Hindi)'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ (Kannada)'},
    {'code': 'te', 'label': 'తెలుగు (Telugu)'},
    {'code': 'ta', 'label': 'தமிழ் (Tamil)'},
    {'code': 'en', 'label': 'English'},
  ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/auth/me/', data: {
        'full_name': _nameCtrl.text.trim(),
        'preferred_language': _language,
      });
      if (mounted) context.go('/kyc');
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 48, backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person, size: 48, color: Colors.blue)),
                  Positioned(bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(labelText: 'Preferred Language', prefixIcon: Icon(Icons.language)),
              items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text(l['label']!))).toList(),
              onChanged: (v) => setState(() => _language = v!),
            ),
            const SizedBox(height: 40),
            YanaButton(label: 'Continue to KYC', loading: _loading, onPressed: _save, icon: Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
