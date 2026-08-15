const WebSocket = require('ws');

function createSignalingServer(port) {
  const wss = new WebSocket.Server({ port });
  const clients = new Map();

  function send(ws, payload) {
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(payload));
    }
  }

  wss.on('connection', (ws) => {
    let userId = null;

    ws.on('message', (raw) => {
      let message;
      try {
        message = JSON.parse(raw.toString());
      } catch (err) {
        return;
      }

      switch (message.type) {
        case 'register': {
          userId = message.userId;
          clients.set(userId, ws);
          console.log(`[سَما] المستخدم "${userId}" اتسجل — عدد المتصلين الآن: ${clients.size}`);
          send(ws, { type: 'registered', userId });
          break;
        }
        case 'offer':
        case 'answer':
        case 'ice-candidate':
        case 'hangup': {
          const target = clients.get(message.to);
          console.log(`[سَما] رسالة "${message.type}" من "${message.from}" إلى "${message.to}" — ${target ? 'هتتوصل الآن ✅' : 'المستقبل مش موجود في القائمة ❌'}`);
          if (target) {
            send(target, message);
          } else {
            send(ws, { type: 'error', reason: 'user-not-connected', to: message.to });
          }
          break;
        }
        default:
          console.log('[سَما] رسالة غير معروفة:', message.type);
      }
    });

    ws.on('close', () => {
      if (userId) {
        clients.delete(userId);
        console.log(`[سَما] المستخدم "${userId}" قطع الاتصال — عدد المتصلين الآن: ${clients.size}`);
      }
    });
  });

  return wss;
}

if (require.main === module) {
  const PORT = process.env.PORT || 4000;
  createSignalingServer(PORT);
  console.log(`[سَما] سيرفر الإشارات شغال على المنفذ ${PORT}`);
}

module.exports = { createSignalingServer };
