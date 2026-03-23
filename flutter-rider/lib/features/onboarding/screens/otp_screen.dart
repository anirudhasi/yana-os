import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/yana_button.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key});
  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocuses = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;
  bool _loading = false;
  String _phone = '';
  String? _error;

  Future<void> _sendOTP() async {
    if (_phone.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/otp/request/', data: {'phone_number': '+91$_phone'});
      setState(() { _otpSent = true; _loading = false; });
    } on DioException catch (e) {
      setState(() { _error = e.response?.data?['error'] ?? 'Failed to send OTP. Try again.'; _loading = false; });
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length != 6) { setState(() => _error = 'Enter complete 6-digit OTP'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/auth/otp/verify/', data: {
        'phone_number': '+91$_phone',
        'otp': otp,
      });
      const storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: res.data['access']);
      await storage.write(key: 'refresh_token', value: res.data['refresh']);
      final user = res.data['user'];
      if (!mounted) return;
      // Route based on onboarding status
      final status = user['onboarding_status'] ?? 'new';
      if (status == 'new' || status == null) {
        context.go('/profile-setup');
      } else if (status == 'active') {
        context.go('/home');
      } else {
        context.go('/status');
      }
    } on DioException catch (e) {
      setState(() { _error = e.response?.data?['error'] ?? 'Invalid OTP. Try again.'; _loading = false; });
    }
  }

  Widget _buildOTPBox(int i) {
    return SizedBox(
      width: 44,
      child: TextFormField(
        controller: _otpCtrls[i],
        focusNode: _otpFocuses[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) _otpFocuses[i + 1].requestFocus();
          if (v.isEmpty && i > 0) _otpFocuses[i - 1].requestFocus();
          if (i == 5 && v.isNotEmpty) _verifyOTP();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Text('Yana Rider', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Drive. Earn. Grow.', style: TextStyle(color: Colors.white60, fontSize: 15)),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _otpSent ? 'Verify your number' : 'Enter mobile number',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent ? 'OTP sent to +91 $_phone' : 'We\'ll send a 6-digit OTP to verify',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      if (!_otpSent) ...[
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            prefixText: '+91  ',
                            prefixStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            counterText: '',
                            hintText: '98765 43210',
                          ),
                          onChanged: (v) => _phone = v,
                          onFieldSubmitted: (_) => _sendOTP(),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, _buildOTPBox),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() { _otpSent = false; _otpCtrls.forEach((c) => c.clear()); }),
                          child: const Text('Change number'),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFF922B21), size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFF922B21), fontSize: 13))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      YanaButton(
                        label: _otpSent ? 'Verify OTP' : 'Send OTP',
                        loading: _loading,
                        onPressed: _otpSent ? _verifyOTP : _sendOTP,
                        icon: _otpSent ? Icons.check_circle : Icons.sms,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'By continuing you agree to our Terms & Privacy Policy',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
