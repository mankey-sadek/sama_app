import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';
import 'call_screen.dart';
import 'incoming_call_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  final SignalingService signalingService;
  final WebRTCService webrtcService;

  const HomeScreen({
    super.key,
    required this.phoneNumber,
    required this.signalingService,
    required this.webrtcService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _defaultServerUrl = String.fromEnvironment(
    'SIGNALING_SERVER_URL',
    defaultValue: 'ws://10.0.2.2:4000',
  );

  late final TextEditingController _serverController =
      TextEditingController(text: _defaultServerUrl);
  final TextEditingController _dialController = TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.signalingService.connect(
      serverUrl: _defaultServerUrl,
      userId: widget.phoneNumber,
    );

    widget.webrtcService.onIncomingCall = (fromUserId) {
      if (mounted) _openIncomingCall(fromUserId);
    };
  }

  @override
  void dispose() {
    _serverController.dispose();
    _dialController.dispose();
    super.dispose();
  }

  void _updateServer() {
    final url = _serverController.text.trim();
    if (url.isEmpty) return;
    widget.signalingService.connect(serverUrl: url, userId: widget.phoneNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري الاتصال بسيرفر الإشارات: $url')),
    );
  }

  void _callNumber() {
    final number = _dialController.text.trim();
    if (number.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          contactName: number,
          contactInitial: number.substring(0, 1),
          remoteUserId: number,
          isOutgoing: true,
          webrtcService: widget.webrtcService,
          signalingService: widget.signalingService,
        ),
      ),
    );
  }

  void _openIncomingCall(String fromUserId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerId: fromUserId,
          webrtcService: widget.webrtcService,
          signalingService: widget.signalingService,
        ),
      ),
    );
  }

  void _startCall(Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          contactName: contact.name,
          contactInitial: contact.initial,
          remoteUserId: contact.id,
          isOutgoing: true,
          webrtcService: widget.webrtcService,
          signalingService: widget.signalingService,
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المكالمات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SettingsScreen(phoneNumber: widget.phoneNumber)),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.seriesViolet,
                      child: Text('م', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gridline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('سيرفر الإشارات (Signaling Server)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _serverController,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.surface1,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gridline)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.seriesBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: _updateServer,
                          child: const Text('اتصال', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('اتصل برقم مباشرة', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dialController,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.surface1,
                              hintText: '+20...',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gridline)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusGood,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: _callNumber,
                          child: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.gridline),
                ),
                child: const Text('بحث عن جهة اتصال…', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              const Text('جهات اتصال تجريبية (Demo)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.separated(
                  itemCount: mockContacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gridline),
                  itemBuilder: (context, index) {
                    final contact = mockContacts[index];
                    return _ContactRow(contact: contact, onTap: () => _startCall(contact));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const _ContactRow({required this.contact, required this.onTap});

  Color get _qualityColor {
    switch (contact.quality) {
      case CallQualityLabel.excellent:
        return AppColors.statusGood;
      case CallQualityLabel.fair:
        return AppColors.statusWarning;
      case CallQualityLabel.poor:
        return AppColors.statusCritical;
    }
  }

  String get _connectionLabel {
    switch (contact.connectionType) {
      case ConnectionType.satellite:
        return 'فضائي';
      case ConnectionType.wifi:
        return 'واي فاي';
      case ConnectionType.cellular:
        return 'شبكة محمول';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: contact.avatarColor,
              child: Text(contact.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _qualityColor, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('$_connectionLabel — ${contact.lastCallLabel}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.call_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
