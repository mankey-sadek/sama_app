import 'package:flutter/material.dart';

import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';
import 'account_type_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final AccountType accountType;
  final SignalingService signalingService;
  final WebRTCService webrtcService;

  const LoginScreen({
    super.key,
    required this.accountType,
    required this.signalingService,
    required this.webrtcService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+20 10 1234 5678');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // ملاحظة للإنتاج: هنا المفروض يحصل تحقق فعلي بكود OTP عن طريق خدمة
    // هوية حقيقية (Auth0 / Firebase Auth)، ودعم SSO لحسابات الشركات —
    // في هذا الـ MVP بنكتفي برقم الهاتف كمعرّف للدخول على سيرفر الإشارات.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          phoneNumber: phone,
          signalingService: widget.signalingService,
          webrtcService: widget.webrtcService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('تسجيل الدخول', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('هنبعتلك كود تحقق برسالة نصية', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              const Text('رقم الموبايل', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gridline)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gridline)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.seriesBlue)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.seriesBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _continue,
                  child: const Text('إرسال الكود', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.gridline)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('أو', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  ),
                  Expanded(child: Divider(color: AppColors.gridline)),
                ],
              ),
              const SizedBox(height: 18),
              if (widget.accountType == AccountType.business)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.gridline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _continue,
                    child: const Text('تسجيل دخول الشركة (SSO)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
