/**
 * اختبار حقيقي لسيرفر الإشارات: بيشغّل سيرفر فعلي على منفذ تجريبي،
 * بيوصّل عميلين (أليس وبوب) عن طريق WebSocket، وبيتأكد إن رسائل
 * offer / answer / ice-candidate / hangup فعلاً بتوصل من طرف للتاني
 * بالظبط زي ما هيحصل بين موبايلين حقيقيين بيستخدموا تطبيق سَما.
 */
const WebSocket = require('ws');
const { createSignalingServer } = require('../server');

const PORT = 4500;
const server = createSignalingServer(PORT);

function connect(userId) {
  return new Promise((resolve) => {
    const ws = new WebSocket(`ws://localhost:${PORT}`);
    ws.on('open', () => {
      ws.send(JSON.stringify({ type: 'register', userId }));
    });
    ws.on('message', (raw) => {
      const msg = JSON.parse(raw.toString());
      if (msg.type === 'registered') resolve(ws);
    });
  });
}

(async () => {
  console.log('▶ بدء اختبار سيرفر الإشارات...\n');

  const alice = await connect('alice');
  const bob = await connect('bob');

  const received = { offer: false, answer: false, iceCandidate: false, hangup: false };

  bob.on('message', (raw) => {
    const msg = JSON.parse(raw.toString());

    if (msg.type === 'offer') {
      received.offer = true;
      console.log(`✔ بوب استقبل offer من "${msg.from}"`);
      bob.send(JSON.stringify({ type: 'answer', from: 'bob', to: 'alice', sdp: { type: 'answer', sdp: 'fake-sdp' } }));
    }

    if (msg.type === 'ice-candidate') {
      received.iceCandidate = true;
      console.log(`✔ بوب استقبل ice-candidate من "${msg.from}"`);
      bob.send(JSON.stringify({ type: 'hangup', from: 'bob', to: 'alice' }));
    }
  });

  alice.on('message', (raw) => {
    const msg = JSON.parse(raw.toString());

    if (msg.type === 'answer') {
      received.answer = true;
      console.log(`✔ أليس استقبلت answer من "${msg.from}"`);
      alice.send(JSON.stringify({ type: 'ice-candidate', from: 'alice', to: 'bob', candidate: { candidate: 'fake-ice' } }));
    }

    if (msg.type === 'hangup') {
      received.hangup = true;
      console.log(`✔ أليس استقبلت hangup من "${msg.from}"`);
    }

    if (msg.type === 'error') {
      console.log(`✘ خطأ: ${msg.reason}`);
    }
  });

  // أليس بتبدأ مكالمة لبوب — نفس أول رسالة بيبعتها webrtc_service.dart
  alice.send(JSON.stringify({ type: 'offer', from: 'alice', to: 'bob', sdp: { type: 'offer', sdp: 'fake-sdp' } }));

  setTimeout(() => {
    const allPassed = Object.values(received).every(Boolean);
    console.log('\n' + JSON.stringify(received, null, 2));
    console.log(
      allPassed
        ? '\n✅ كل رسائل التفاوض اتبادلت بنجاح بين طرفين — منطق سيرفر الإشارات شغال صح.'
        : '\n❌ فيه رسائل ماوصلتش — راجع الكود.'
    );

    alice.close();
    bob.close();
    server.close();
    process.exit(allPassed ? 0 : 1);
  }, 1200);
})();
