import 'package:flutter/material.dart';

import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;
  final WebRTCService webrtcService;
  final SignalingService signalingService;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.webrtcService,
    required this.signalingService,
  });

  Future<void> _accept(BuildContext context) async {
    await webrtcService.acceptIncomingCall();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          contactName: callerId,
          contactInitial: callerId.isNotEmpty ? callerId.substring(0, 1) : '؟',
          remoteUserId: callerId,
          isOutgoing: false,
          webrtcService: webrtcService,
          signalingService: signalingService,
        ),
      ),
    );
  }

  void _decline(BuildContext context) {
    webrtcService.declineIncomingCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            children: [
              const Text('مكالمة واردة', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const Spacer(),
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.seriesViolet,
                child: Text(
                  callerId.isNotEmpty ? callerId.substring(0, 1) : '؟',
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(callerId, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('🛰 عبر الإنترنت الفضائي', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _decline(context),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(color: AppColors.statusCritical, shape: BoxShape.circle),
                          child: const Icon(Icons.call_end_rounded, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('رفض', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _accept(context),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(color: AppColors.statusGood, shape: BoxShape.circle),
                          child: const Icon(Icons.call_rounded, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('قبول', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
