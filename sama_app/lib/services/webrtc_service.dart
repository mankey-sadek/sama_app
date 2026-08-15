import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling_service.dart';

enum CallQualityLevel { excellent, good, fair, poor, unknown }

/// الطبقة اللي بتشغّل مكالمة WebRTC فعلية: بتفتح المايك، تنشئ اتصال
/// نظير-لنظير (Peer Connection)، وتتبادل بيانات التفاوض عن طريق
/// [SignalingService]، وتقيس جودة الاتصال بشكل دوري.
///
/// مهم: المكالمة الواردة معمولها هنا "انتظار قبول" — لما يوصل offer،
/// التطبيق مبيردش تلقائي؛ بيستنى المستخدم يضغط قبول (acceptIncomingCall)
/// أو رفض (declineIncomingCall) عن طريق شاشة "مكالمة واردة".
///
/// ملاحظة مهمة للإنتاج: قائمة iceServers هنا فيها STUN عام من جوجل بس،
/// وده كافي للتجربة المحلية على نفس الواي فاي. في نسخة حقيقية على شبكات
/// الأقمار الصناعية (اللي غالبًا بتستخدم NAT معقد) لازم تضيف سيرفر TURN
/// خاص بيك (زي coturn) زي ما اتفقنا في وثيقة المعمارية.
class WebRTCService {
  final SignalingService signaling;

  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  String? _remoteUserId;

  // حالة المكالمة الواردة قبل ما تتقبل
  String? _pendingCallerId;
  Map<String, dynamic>? _pendingOfferSdp;

  void Function(MediaStream stream)? onRemoteStream;

  /// بينادَى لما يوصل عرض مكالمة جديد (offer) — من غير ما نرد تلقائيًا.
  /// الوسيطة هي معرّف المتصل (رقم الهاتف).
  void Function(String fromUserId)? onIncomingCall;

  /// بينادَى لما الطرف التاني يقفل المكالمة (hangup) وإحنا في مكالمة فعلية.
  void Function()? onCallEnded;

  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  bool _initialized = false;

  WebRTCService(this.signaling) {
    signaling.messages.listen(_handleSignalingMessage);
  }

  Future<void> init() async {
    if (_initialized) return;
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _initialized = true;
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceConfig);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      final remote = _remoteUserId;
      if (remote != null) {
        signaling.sendIceCandidate(to: remote, candidate: candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        remoteRenderer.srcObject = remoteStream;
        onRemoteStream?.call(remoteStream!);
      }
    };
  }

  Future<void> _openUserMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      // ابدأ بمكالمات صوتية بس في الـ MVP — تفعيل الفيديو لاحقًا سهل
      // (بس خد بالك إنه بيستهلك بيانات أكتر بكتير على شبكة فضائية محدودة).
      'video': false,
    });
    localStream = stream;
    localRenderer.srcObject = stream;
  }

  /// بدء مكالمة صادرة لمستخدم تاني (يفترض إن الطرفين مسجلين على نفس سيرفر الإشارات)
  Future<void> startCall(String remoteUserId) async {
    _remoteUserId = remoteUserId;
    await _openUserMedia();
    await _createPeerConnection();

    for (final track in localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, localStream!);
    }

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    signaling.sendOffer(to: remoteUserId, sdp: offer.toMap());
  }

  /// ينفَّذ فعليًا لما المستخدم يضغط "قبول" في شاشة المكالمة الواردة.
  Future<void> acceptIncomingCall() async {
    final from = _pendingCallerId;
    final sdpMap = _pendingOfferSdp;
    if (from == null || sdpMap == null) return;

    _pendingCallerId = null;
    _pendingOfferSdp = null;

    _remoteUserId = from;
    await _openUserMedia();
    await _createPeerConnection();

    for (final track in localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, localStream!);
    }

    final offer = RTCSessionDescription(sdpMap['sdp'] as String, sdpMap['type'] as String);
    await _peerConnection!.setRemoteDescription(offer);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    signaling.sendAnswer(to: from, sdp: answer.toMap());
  }

  /// ينفَّذ لما المستخدم يضغط "رفض" في شاشة المكالمة الواردة.
  void declineIncomingCall() {
    final from = _pendingCallerId;
    if (from != null) {
      signaling.sendHangup(to: from);
    }
    _pendingCallerId = null;
    _pendingOfferSdp = null;
  }

  Future<void> _handleAnswer(Map<String, dynamic> sdpMap) async {
    final answer = RTCSessionDescription(sdpMap['sdp'] as String, sdpMap['type'] as String);
    await _peerConnection?.setRemoteDescription(answer);
  }

  Future<void> _handleRemoteIceCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'] as String?,
      candidateMap['sdpMid'] as String?,
      candidateMap['sdpMLineIndex'] as int?,
    );
    await _peerConnection?.addCandidate(candidate);
  }

  void _handleSignalingMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'offer':
        // مبنردش تلقائي — بنسجّل العرض وننادي onIncomingCall عشان
        // الواجهة تعرض شاشة "مكالمة واردة" فيها قبول/رفض.
        _pendingCallerId = message['from'] as String;
        _pendingOfferSdp = Map<String, dynamic>.from(message['sdp'] as Map);
        onIncomingCall?.call(_pendingCallerId!);
        break;
      case 'answer':
        _handleAnswer(Map<String, dynamic>.from(message['sdp'] as Map));
        break;
      case 'ice-candidate':
        _handleRemoteIceCandidate(Map<String, dynamic>.from(message['candidate'] as Map));
        break;
      case 'hangup':
        _pendingCallerId = null;
        _pendingOfferSdp = null;
        endCall(notifyRemote: false);
        onCallEnded?.call();
        break;
    }
  }

  Future<void> toggleMute(bool muted) async {
    final tracks = localStream?.getAudioTracks() ?? [];
    for (final track in tracks) {
      track.enabled = !muted;
    }
  }

  /// تقدير مبسّط لجودة المكالمة من إحصاءات RTCPeerConnection (فقد الحزم
  /// وزمن الرحلة ذهابًا وإيابًا). ده هو نفس المؤشر اللي بيظهر في واجهة
  /// المستخدم أثناء المكالمة، ومهم جدًا على شبكات الأقمار الصناعية
  /// غير المستقرة زي ما ناقشنا في وثيقة المعمارية.
  Future<CallQualityLevel> checkQuality() async {
    if (_peerConnection == null) return CallQualityLevel.unknown;
    try {
      final reports = await _peerConnection!.getStats();
      num packetsLost = 0;
      num packetsReceived = 0;
      num roundTripTime = 0;

      for (final report in reports) {
        if (report.type == 'inbound-rtp') {
          packetsLost += (report.values['packetsLost'] as num?) ?? 0;
          packetsReceived += (report.values['packetsReceived'] as num?) ?? 0;
        }
        if (report.type == 'candidate-pair' && report.values['currentRoundTripTime'] != null) {
          roundTripTime = report.values['currentRoundTripTime'] as num;
        }
      }

      final total = packetsLost + packetsReceived;
      final lossRatio = total > 0 ? packetsLost / total : 0;

      if (lossRatio < 0.02 && roundTripTime < 0.4) return CallQualityLevel.excellent;
      if (lossRatio < 0.05 && roundTripTime < 0.8) return CallQualityLevel.good;
      if (lossRatio < 0.10) return CallQualityLevel.fair;
      return CallQualityLevel.poor;
    } catch (_) {
      return CallQualityLevel.unknown;
    }
  }

  Future<void> endCall({bool notifyRemote = true}) async {
    final remote = _remoteUserId;
    if (notifyRemote && remote != null) {
      signaling.sendHangup(to: remote);
    }
    await _peerConnection?.close();
    _peerConnection = null;

    for (final track in localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    localStream = null;
    remoteStream = null;
    remoteRenderer.srcObject = null;
    localRenderer.srcObject = null;
    _remoteUserId = null;
  }

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _peerConnection?.close();
  }
}
