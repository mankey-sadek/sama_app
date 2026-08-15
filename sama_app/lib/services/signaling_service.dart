import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// عميل بسيط لسيرفر الإشارات (Signaling Server) عن طريق WebSocket.
///
/// دوره الوحيد إنه ينقل رسائل التفاوض بين طرفين قبل ما يبدأ الاتصال المباشر
/// (offer / answer / ice-candidate)، بالإضافة لرسالة hangup لإنهاء المكالمة.
/// لا ينقل أي صوت أو فيديو — ده شغل WebRTC نفسه بعد ما يتفق الطرفين.
///
/// السيرفر المطابق موجود في مجلد signaling-server/ بجانب هذا المشروع.
class SignalingService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  String? _userId;
  bool _connected = false;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _connected;
  String? get userId => _userId;

  /// يوصّل (أو يعيد الاتصال لو كان متصل قبل كده) بسيرفر الإشارات.
  /// آمن إنه يتنادى أكتر من مرة — بيقفل أي اتصال قديم الأول.
  Future<void> connect({required String serverUrl, required String userId}) async {
    _userId = userId;
    _connected = false;

    await _channel?.sink.close();
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          if (data['type'] == 'registered') {
            _connected = true;
          }
          _messageController.add(data);
        } catch (_) {
          // رسالة غير صالحة — يتم تجاهلها بدل ما توقف التطبيق
        }
      },
      onError: (Object error) => _messageController.addError(error),
      onDone: () => _connected = false,
    );

    _send({'type': 'register', 'userId': userId});
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  void sendOffer({required String to, required Map<String, dynamic> sdp}) {
    _send({'type': 'offer', 'from': _userId, 'to': to, 'sdp': sdp});
  }

  void sendAnswer({required String to, required Map<String, dynamic> sdp}) {
    _send({'type': 'answer', 'from': _userId, 'to': to, 'sdp': sdp});
  }

  void sendIceCandidate({required String to, required Map<String, dynamic> candidate}) {
    _send({'type': 'ice-candidate', 'from': _userId, 'to': to, 'candidate': candidate});
  }

  void sendHangup({required String to}) {
    _send({'type': 'hangup', 'from': _userId, 'to': to});
  }

  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}
