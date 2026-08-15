import 'dart:async';

import 'package:flutter/material.dart';

import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';

/// شاشة المكالمة الفعلية — هنا فعليًا بيتم فتح المايك، وإنشاء اتصال
/// WebRTC حقيقي (صادر أو وارد)، وعرض مؤشر جودة الاتصال بشكل حي.
class CallScreen extends StatefulWidget {
  final String contactName;
  final String contactInitial;
  final String remoteUserId;
  final bool isOutgoing;
  final WebRTCService webrtcService;
  final SignalingService signalingService;

  const CallScreen({
    super.key,
    required this.contactName,
    required this.contactInitial,
    required this.remoteUserId,
    required this.isOutgoing,
    required this.webrtcService,
    required this.signalingService,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  Timer? _qualityTimer;
  Duration _elapsed = Duration.zero;
  bool _muted = false;
  CallQualityLevel _quality = CallQualityLevel.unknown;

  @override
  void initState() {
    super.initState();
    widget.webrtcService.onCallEnded = _handleRemoteEnded;
    _setup();
  }

  Future<void> _setup() async {
    await widget.webrtcService.init();
    if (widget.isOutgoing) {
      await widget.webrtcService.startCall(widget.remoteUserId);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });

    _qualityTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final quality = await widget.webrtcService.checkQuality();
      if (mounted) setState(() => _quality = quality);
    });
  }

  void _handleRemoteEnded() {
    _timer?.cancel();
    _qualityTimer?.cancel();
    if (mounted) Navigator.of(context).maybePop();
  }

  String get _timerLabel {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get _qualityColor {
    switch (_quality) {
      case CallQualityLevel.excellent:
      case CallQualityLevel.good:
        return AppColors.statusGood;
      case CallQualityLevel.fair:
        return AppColors.statusWarning;
      case CallQualityLevel.poor:
        return AppColors.statusCritical;
      case CallQualityLevel.unknown:
        return AppColors.textMuted;
    }
  }

  String get _qualityLabel {
    switch (_quality) {
      case CallQualityLevel.excellent:
        return 'ممتازة';
      case CallQualityLevel.good:
        return 'جيدة';
      case CallQualityLevel.fair:
        return 'متذبذبة';
      case CallQualityLevel.poor:
        return 'ضعيفة';
      case CallQualityLevel.unknown:
        return 'جارٍ القياس…';
    }
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    widget.webrtcService.toggleMute(_muted);
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    _qualityTimer?.cancel();
    await widget.webrtcService.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _qualityTimer?.cancel();
    widget.webrtcService.onCallEnded = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _qualityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _qualityColor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.satellite_alt_rounded, size: 14, color: _qualityColor),
                    const SizedBox(width: 6),
                    Text(
                      'جودة الاتصال: $_qualityLabel',
                      style: TextStyle(color: _qualityColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.seriesViolet,
                child: Text(
                  widget.contactInitial,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Text(widget.contactName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_timerLabel, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              const Text('🛰 متصل عبر الإنترنت الفضائي', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallControlButton(
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: 'كتم',
                    onTap: _toggleMute,
                  ),
                  const _CallControlButton(icon: Icons.volume_up_rounded, label: 'سماعة'),
                  const _CallControlButton(icon: Icons.person_add_alt_rounded, label: 'إضافة'),
                ],
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.statusCritical, shape: BoxShape.circle),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CallControlButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gridline),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 22),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
      ],
    );
  }
}
