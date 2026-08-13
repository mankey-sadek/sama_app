import 'package:flutter/material.dart';

import 'services/signaling_service.dart';
import 'services/webrtc_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  final signalingService = SignalingService();
  final webrtcService = WebRTCService(signalingService);
  runApp(SamaApp(signalingService: signalingService, webrtcService: webrtcService));
}

class SamaApp extends StatelessWidget {
  final SignalingService signalingService;
  final WebRTCService webrtcService;

  const SamaApp({
    super.key,
    required this.signalingService,
    required this.webrtcService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سَما',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // التطبيق عربي بالكامل في هذا الـ MVP، فبنفرض اتجاه RTL على كل الشاشات.
      // لو حبيت تضيف دعم لغات تانية لاحقًا، ده المكان اللي هتضيف فيه
      // flutter_localizations وLocale ديناميكي.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: SplashScreen(signalingService: signalingService, webrtcService: webrtcService),
    );
  }
}
