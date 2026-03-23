import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../shared/widgets/yana_button.dart';
import '../../../shared/widgets/status_badge.dart';

class KYCScreen extends ConsumerStatefulWidget {
  const KYCScreen({super.key});
  @override
  ConsumerState<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends ConsumerState<KYCScreen> {
  final _aadhaarCtrl = TextEditingController();
  final _dlCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final Map<String, File?> _docs = {'aadhaar': null, 'dl': null, 'photo': null};
  bool _loading = false;
  int _step = 0;

  Future<void> _pickImage(String docType) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _docs[docType] = File(img.path));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      // Create rider profile
      await dio.post('/onboarding/riders/', data: {
        'aadhaar_number': _aadhaarCtrl.text.trim(),
        'dl_number': _dlCtrl.text.trim(),
        'bank_account': _bankCtrl.text.trim(),
        'ifsc_code': _ifscCtrl.text.trim().toUpperCase(),
      });
      // Upload docs
      for (final entry in _docs.entries) {
        if (entry.value != null) {
          final formData = FormData.fromMap({
            'doc_type': entry.key,
            'file': await MultipartFile.fromFile(entry.value!.path),
          });
          await dio.post('/onboarding/riders/upload_document/', data: formData);
        }
      }
      if (mounted) context.go('/status');
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Widget _docUploadCard(String type, String label, IconData icon) {
    final file = _docs[type];
    return InkWell(
      onTap: () => _pickImage(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: file != null ? const Color(0xFFD5F5E3) : Colors.white,
          border: Border.all(color: file != null ? const Color(0xFF1E8449) : const Color(0xFFDDE2E5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: file != null ? const Color(0xFF1E8449) : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(file != null ? 'Uploaded ✓' : 'Tap to upload', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ]),
            ),
            Icon(file != null ? Icons.check_circle : Icons.upload, color: file != null ? const Color(0xFF1E8449) : Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification'), bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(value: (_step + 1) / 3, backgroundColor: Colors.white30, color: Colors.white),
      )),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Step indicator
          Row(
            children: ['Personal Details', 'Documents', 'Bank Details'].asMap().entries.map((e) {
              final active = e.key == _step;
              final done = e.key < _step;
              return Expanded(child: Column(children: [
                CircleAvatar(radius: 14, backgroundColor: done || active ? const Color(0xFF1B4F72) : Colors.grey[300],
                  child: done ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${e.key + 1}', style: TextStyle(color: active ? Colors.white : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(height: 4),
                Text(e.value, style: TextStyle(fontSize: 10, color: active ? const Color(0xFF1B4F72) : Colors.grey, fontWeight: active ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center),
              ]));
            }).toList(),
          ),
          const SizedBox(height: 32),
          if (_step == 0) ...[
            const Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(controller: _aadhaarCtrl,
              decoration: const InputDecoration(labelText: 'Aadhaar Number (12 digits)', prefixIcon: Icon(Icons.credit_card)),
              keyboardType: TextInputType.number, maxLength: 12),
            const SizedBox(height: 16),
            TextFormField(controller: _dlCtrl,
              decoration: const InputDecoration(labelText: 'Driving License Number', prefixIcon: Icon(Icons.directions_car)),
              textCapitalization: TextCapitalization.characters),
          ] else if (_step == 1) ...[
            const Text('Upload Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Upload clear photos of your documents', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            _docUploadCard('aadhaar', 'Aadhaar Card', Icons.credit_card),
            const SizedBox(height: 12),
            _docUploadCard('dl', 'Driving License', Icons.badge),
            const SizedBox(height: 12),
            _docUploadCard('photo', 'Passport Photo', Icons.face),
          ] else ...[
            const Text('Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('For salary & incentive transfers', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            TextFormField(controller: _bankCtrl,
              decoration: const InputDecoration(labelText: 'Account Number', prefixIcon: Icon(Icons.account_balance)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextFormField(controller: _ifscCtrl,
              decoration: const InputDecoration(labelText: 'IFSC Code', prefixIcon: Icon(Icons.code)),
              textCapitalization: TextCapitalization.characters, maxLength: 11),
          ],
          const SizedBox(height: 32),
          Row(children: [
            if (_step > 0) ...[
              Expanded(child: YanaButton(label: 'Back', outlined: true, onPressed: () => setState(() => _step--))),
              const SizedBox(width: 12),
            ],
            Expanded(child: YanaButton(
              label: _step < 2 ? 'Next' : 'Submit for Review',
              loading: _loading,
              icon: _step < 2 ? Icons.arrow_forward : Icons.send,
              onPressed: _step < 2 ? () => setState(() => _step++) : _submit,
            )),
          ]),
        ],
      ),
    );
  }
}
