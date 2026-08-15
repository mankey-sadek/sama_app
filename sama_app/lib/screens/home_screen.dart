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
  late final TextEditingController _serverController;
  final TextEditingController _dialController = TextEditingController();

  @override
  void initState() {
    super.initState();

    const defaultServer = String.fromEnvironment(
      'SIGNALING_SERVER_URL',
      defaultValue: 'ws://10.0.2.2:4000',
    );
    _serverController = TextEditingController(text: defaultServer);

    // الاتصال بسيرفر الإشارات باستخدام رقم الهاتف كمعرّف مبدئي للمستخدم.
    widget.signalingService.connect(serverUrl: defaultServer, userId: widget.phoneNumber);

    // مبنردش تلقائي على المكالمة الواردة — بنعرض شاشة "مكالمة واردة"
    // فيها قبول/رفض، وده بيتحكم فيه WebRTCService عن طريق onIncomingCall.
    widget.webrtcService.onIncomingCall = (fromUserId) {
      if (mounted) _openIncomingCall(fromUserId);
    };
  }

  @override
  void dispose() {
    _serverController.dispose();
    _dialController.dispose();
    widget.webrtcService.onIncomingCall = null;
    super.dispose();
  }

  void _updateServer() {
    final url = _serverController.text.trim();
    if (url.isEmpty) return;
    widget.signalingService.connect(serverUrl: url, userId: widget.phoneNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('بيتصل بـ $url …')),
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

  void _startCall(String remoteUserId, {String? displayName}) {
    final name = displayName ?? remoteUserId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          contactName: name,
          contactInitial: name.isNotEmpty ? name.substring(0, 1) : '؟',
          remoteUserId: remoteUserId,
          isOutgoing: true,
          webrtcService: widget.webrtcService,
          signalingService: widget.signalingService,
        ),
      ),
    );
  }

  void _callNumber() {
    final number = _dialController.text.trim();
    if (number.isEmpty) return;
    _startCall(number);
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
              const SizedBox(height: 6),
              Text('رقمك: ${widget.phoneNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 14),

              // سيرفر الإشارات — غيّره لو مش شغال على العنوان الافتراضي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gridline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('سيرفر الإشارات', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _serverController,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'ws://192.168.1.x:4000',
                              hintStyle: TextStyle(color: AppColors.textMuted),
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
                          child: const Text('اتصال', style: TextStyle(fontSize: 12.5, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // اتصال مباشر برقم حقيقي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gridline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اتصل برقم مباشرة', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dialController,
                            textDirection: TextDirection.ltr,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'اكتب رقم الجهاز التاني بالظبط',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _callNumber,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: AppColors.statusGood, shape: BoxShape.circle),
                            child: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('جهات اتصال تجريبية (Demo)', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.separated(
                  itemCount: mockContacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gridline),
                  itemBuilder: (context, index) {
                    final contact = mockContacts[index];
                    return _ContactRow(
                      contact: contact,
                      onTap: () => _startCall(contact.id, displayName: contact.name),
                    );
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
