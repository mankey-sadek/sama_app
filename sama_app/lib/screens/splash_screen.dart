import 'dart:async';

import 'package:flutter/material.dart';

import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';
import 'account_type_screen.dart';

class SplashScreen extends StatefulWidget {
  final SignalingService signalingService;
  final WebRTCService webrtcService;

  const SplashScreen({
    super.key,
    required this.signalingService,
    required this.webrtcService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AccountTypeScreen(
            signalingService: widget.signalingService,
            webrtcService: widget.webrtcService,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [AppColors.seriesBlue, AppColors.seriesViolet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.satellite_alt_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'سَما',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'مكالمات صوت وفيديو تشتغل بكفاءة حتى على إنترنت الأقمار الصناعية',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),
            ),
            const SizedBox(height: 26),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.seriesBlue),
            ),
          ],
        ),
      ),
    );
  }
}
