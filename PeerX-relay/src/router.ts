// ─────────────────────────────────────────────────────────────────────────────
// PeerX Relay Server — Message Router
// ─────────────────────────────────────────────────────────────────────────────

import { WebSocket } from "ws";
import {
  Envelope,
  ErrorCode,
  ErrorEnvelope,
  ConnectedPeer,
  QueuedMessage,
} from "./types";
import {
  getSocket,
  enqueue,
  drainQueue,
  broadcastPresence,
  registerPeer,
  unregisterPeer,
  subscribeToPresence,
  unsubscribeAll,
  isOnline,
  registerPushToken,
  getPushToken,
  registerPublicKey,
  getPublicKey,
  markDelivered,
  sendKeySync,
} from "./presence";
import { checkRateLimit, checkPayloadSize, clearDevice } from "./rateLimit";

// ─── FCM V1 API ───────────────────────────────────────────────────────────────

let _fcmAccessToken: string | null = null;
let _fcmTokenExpiry: number        = 0;

async function getFcmAccessToken(): Promise<string | null> {
  const now = Date.now();
  if (_fcmAccessToken && now < _fcmTokenExpiry - 60_000) {
    return _fcmAccessToken;
  }

  const clientEmail = process.env.FCM_CLIENT_EMAIL;
  const privateKey  = process.env.FCM_PRIVATE_KEY?.replace(/\\n/g, "\n");

  if (!clientEmail || !privateKey) {
    console.warn("[push] FCM_CLIENT_EMAIL or FCM_PRIVATE_KEY not set");
    return null;
  }

  try {
    const now_s   = Math.floor(Date.now() / 1000);
    const payload = {
      iss:   clientEmail,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud:   "https://oauth2.googleapis.com/token",
      iat:   now_s,
      exp:   now_s + 3600,
    };

    const header = { alg: "RS256", typ: "JWT" };

    const base64url = (obj: object) =>
      Buffer.from(JSON.stringify(obj))
        .toString("base64")
        .replace(/=/g, "")
        .replace(/\+/g, "-")
        .replace(/\//g, "_");

    const signingInput = `${base64url(header)}.${base64url(payload)}`;

    const { createSign } = await import("crypto");
    const signer = createSign("RSA-SHA256");
    signer.update(signingInput);
    const signature = signer
      .sign(privateKey, "base64")
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

    const jwt = `${signingInput}.${signature}`;

    const res = await fetch("https://oauth2.googleapis.com/token", {
      method:  "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion:  jwt,
      }),
    });

    const data = await res.json() as any;

    if (!res.ok || !data.access_token) {
      console.warn("[push] failed to get FCM access token:", data);
      return null;
    }

    _fcmAccessToken = data.access_token;
    _fcmTokenExpiry = Date.now() + (data.expires_in ?? 3600) * 1000;
    console.log("[push] FCM access token refreshed");
    return _fcmAccessToken;

  } catch (err) {
    console.error("[push] JWT/token error:", err);
    return null;
  }
}

async function sendPushNotification(opts: {
  token:    string;
  title:    string;
  body:     string;
  data?:    Record<string, string>;
  channel?: string;
}): Promise<void> {
  const projectId = process.env.FCM_PROJECT_ID;
  if (!projectId) {
    console.warn("[push] FCM_PROJECT_ID not set");
    return;
  }

  const accessToken = await getFcmAccessToken();
  if (!accessToken) return;

  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  try {
    const res = await fetch(url, {
      method:  "POST",
      headers: {
        "Content-Type":  "application/json",
        "Authorization": `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: opts.token,
          notification: {
            title: opts.title,
            body:  opts.body,
          },
          data: opts.data ?? {},
          android: {
            priority: "high",
            notification: {
              channel_id: opts.channel ?? "peerx_messages",
              sound:      "default",
            },
          },
          apns: {
            headers: { "apns-priority": "10" },
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        },
      }),
    });

    const json = await res.json() as any;

    if (!res.ok) {
      if (res.status === 401) _fcmAccessToken = null;
      console.warn(`[push] FCM V1 error ${res.status}:`, json);
    } else {
      console.log(`[push] sent → ${opts.token.slice(0, 20)}...`);
    }
  } catch (err) {
    console.error("[push] request failed:", err);
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function getPeerData(ws: WebSocket): ConnectedPeer {
  return (ws as any).peerData as ConnectedPeer;
}

function send(ws: WebSocket, data: object): void {
  try {
    if (ws.readyState === ws.OPEN) ws.send(JSON.stringify(data));
  } catch {}
}

function sendError(
  ws: WebSocket,
  code: ErrorCode,
  message: string,
  messageId?: string,
): void {
  const err: ErrorEnvelope = { type: "error", code, message, messageId };
  send(ws, err);
}

function parseEnvelope(raw: string): Envelope | null {
  try {
    const parsed = JSON.parse(raw);
    if (
      typeof parsed.type      !== "string" ||
      typeof parsed.from      !== "string" ||
      typeof parsed.messageId !== "string" ||
      typeof parsed.sentAt    !== "number"
    ) return null;
    return parsed as Envelope;
  } catch {
    return null;
  }
}

// ─── Key Exchange Helper ──────────────────────────────────────────────────────

function ensureKeysExchanged(
  senderWs: WebSocket,
  senderId: string,
  recipientId: string,
): void {
  const senderKey    = getPublicKey(senderId);
  const recipientKey = getPublicKey(recipientId);

  if (recipientKey) sendKeySync(senderWs, recipientId, recipientKey);

  if (senderKey) {
    const recipientWs = getSocket(recipientId);
    if (recipientWs) sendKeySync(recipientWs, senderId, senderKey);
  }
}

// ─── On Open ──────────────────────────────────────────────────────────────────

export function onOpen(ws: WebSocket): void {
  console.log("[router] new connection");
}

// ─── On Close ─────────────────────────────────────────────────────────────────

export function onClose(ws: WebSocket, code: number): void {
  const peer = getPeerData(ws);
  if (!peer?.deviceId) return;

  unregisterPeer(peer.deviceId);
  unsubscribeAll(peer.deviceId);
  clearDevice(peer.deviceId);
  broadcastPresence(peer.deviceId, false);

  console.log(`[router] ${peer.deviceId} disconnected (${code})`);
}

// ─── On Message ───────────────────────────────────────────────────────────────

export function onMessage(ws: WebSocket, data: Buffer): void {
  const raw = data.toString("utf8");

  if (!checkPayloadSize(raw)) {
    sendError(ws, "PAYLOAD_TOO_LARGE", "payload exceeds 64 KB");
    return;
  }

  const envelope = parseEnvelope(raw);
  if (!envelope) {
    sendError(ws, "INVALID_ENVELOPE", "malformed envelope");
    return;
  }

  switch (envelope.type) {
    case "handshake":    return handleHandshake(ws, envelope);
    case "message":      return handleMessage(ws, envelope);
    case "add_request":  return handleRoute(ws, envelope);
    case "add_response": return handleRoute(ws, envelope);
    case "key_request":  return handleKeyRequest(ws, envelope);
    case "ping":         return handlePing(ws, envelope);
    case "ack":          return;
    default:
      sendError(ws, "INVALID_ENVELOPE", `unknown type: ${envelope.type}`, envelope.messageId);
  }
}

// ─── Handshake ────────────────────────────────────────────────────────────────

function handleHandshake(ws: WebSocket, envelope: Envelope): void {
  const deviceId = envelope.from;

  if (!deviceId || deviceId.length < 8) {
    sendError(ws, "MISSING_DEVICE_ID", "deviceId too short", envelope.messageId);
    return;
  }

  const peer         = getPeerData(ws);
  const isFirstShake = !peer.deviceId || peer.deviceId !== deviceId;

  peer.deviceId     = deviceId;
  peer.connectedAt  = isFirstShake ? Date.now() : peer.connectedAt;
  peer.messageCount = 0;
  peer.windowStart  = Date.now();

  if (envelope.pushToken) {
    registerPushToken(deviceId, envelope.pushToken);
    console.log(`[router] FCM token registered for ${deviceId}`);
  }

  if (envelope.publicKey) {
    registerPublicKey(deviceId, envelope.publicKey);
  }

  registerPeer(deviceId, ws);

  if (envelope.payload) {
    try {
      const contactIds: string[] = JSON.parse(envelope.payload);
      if (Array.isArray(contactIds)) {
        unsubscribeAll(deviceId);
        subscribeToPresence(deviceId, contactIds);

        for (const contactId of contactIds) {
          const contactOnline = isOnline(contactId);
          const contactKey    = getPublicKey(contactId);

          send(ws, {
            type:      "presence",
            peerId:    contactId,
            online:    contactOnline,
            publicKey: contactKey,
            timestamp: Date.now(),
            messageId: `presence-${contactId}-${Date.now()}`,
            sentAt:    Date.now(),
            from:      "server",
          });

          if (contactKey) sendKeySync(ws, contactId, contactKey);

          if (contactOnline && envelope.publicKey) {
            const contactWs = getSocket(contactId);
            if (contactWs) sendKeySync(contactWs, deviceId, envelope.publicKey);
          }
        }
      }
    } catch {}
  }

  const queued = drainQueue(deviceId);
  for (const qm of queued) {
    const qSenderKey = getPublicKey(qm.envelope.from);
    if (qSenderKey) sendKeySync(ws, qm.envelope.from, qSenderKey);
    send(ws, { ...qm.envelope, queued: true });
  }

  if (isFirstShake) {
    broadcastPresence(deviceId, true);
    console.log(`[router] handshake OK — ${deviceId} (${queued.length} drained)`);
  } else if (queued.length > 0) {
    console.log(`[router] re-handshake — ${deviceId} (${queued.length} drained)`);
  }

  send(ws, {
    type:      "ack",
    messageId: envelope.messageId,
    queued:    queued.length,
    sentAt:    Date.now(),
  });
}

// ─── Message Routing ──────────────────────────────────────────────────────────

function handleMessage(ws: WebSocket, envelope: Envelope): void {
  const { from, to, messageId } = envelope;

  const peer = getPeerData(ws);
  if (!peer.deviceId) {
    sendError(ws, "MISSING_DEVICE_ID", "send handshake first", messageId);
    return;
  }
  if (!to) {
    sendError(ws, "INVALID_ENVELOPE", "missing 'to' field", messageId);
    return;
  }
  if (!checkRateLimit(from)) {
    sendError(ws, "RATE_LIMITED", "max 60 messages/min", messageId);
    return;
  }

  ensureKeysExchanged(ws, from, to);

  const recipientSocket = getSocket(to);

  if (recipientSocket) {
    send(recipientSocket, envelope);
    markDelivered(messageId);
    send(ws, { type: "ack", messageId, delivered: true, sentAt: Date.now() });
    console.log(`[router] msg ${from} → ${to}`);
  } else {
    enqueue(to, { envelope, queuedAt: Date.now() });
    send(ws, { type: "ack", messageId, delivered: false, queued: true, sentAt: Date.now() });
    console.log(`[router] msg queued ${from} → ${to}`);

    const token = getPushToken(to);
    if (token) {
      sendPushNotification({
        token,
        title:   "New message",
        body:    "You have a new encrypted message",
        channel: "peerx_messages",
        data:    { msgType: "message", sender: from },
      });
    } else {
      console.log(`[router] no push token for ${to}`);
    }
  }
}

// ─── Generic Route (add_request / add_response) ───────────────────────────────

function handleRoute(ws: WebSocket, envelope: Envelope): void {
  const { from, to, messageId } = envelope;

  const peer = getPeerData(ws);
  if (!peer.deviceId) {
    sendError(ws, "MISSING_DEVICE_ID", "send handshake first", messageId);
    return;
  }
  if (!to) {
    sendError(ws, "INVALID_ENVELOPE", "missing 'to' field", messageId);
    return;
  }

  if (envelope.type === "add_response") {
    ensureKeysExchanged(ws, from, to);
  }

  const recipientSocket = getSocket(to);

  if (recipientSocket) {
    send(recipientSocket, envelope);
    send(ws, { type: "ack", messageId, delivered: true, sentAt: Date.now() });
    console.log(`[router] ${envelope.type} ${from} → ${to}`);
  } else {
    enqueue(to, { envelope, queuedAt: Date.now() });
    send(ws, { type: "ack", messageId, delivered: false, queued: true, sentAt: Date.now() });
    console.log(`[router] ${envelope.type} queued ${from} → ${to}`);

    if (envelope.type === "add_request") {
      const token = getPushToken(to);
      if (token) {
        sendPushNotification({
          token,
          title:   "New peer request",
          body:    `${from.slice(0, 8).toUpperCase()} wants to connect`,
          channel: "peerx_messages",
          data:    { msgType: "add_request", sender: from, requestId: envelope.requestId ?? "" },
        });
      }
    }
  }
}

// ─── Key Request ──────────────────────────────────────────────────────────────

function handleKeyRequest(ws: WebSocket, envelope: Envelope): void {
  const { from, messageId } = envelope;
  const targetPeerId = envelope.to ?? envelope.peerId;

  const peer = getPeerData(ws);
  if (!peer.deviceId) {
    sendError(ws, "MISSING_DEVICE_ID", "send handshake first", messageId);
    return;
  }
  if (!targetPeerId) {
    sendError(ws, "INVALID_ENVELOPE", "missing 'to' or 'peerId' field", messageId);
    return;
  }

  const publicKey = getPublicKey(targetPeerId);

  if (!publicKey) {
    sendError(ws, "KEY_NOT_FOUND", `no public key for ${targetPeerId}`, messageId);
    return;
  }

  sendKeySync(ws, targetPeerId, publicKey);
  send(ws, { type: "ack", messageId, sentAt: Date.now() });
  console.log(`[router] key_request ${from} → key for ${targetPeerId}`);
}

// ─── Ping ─────────────────────────────────────────────────────────────────────

function handlePing(ws: WebSocket, envelope: Envelope): void {
  send(ws, { type: "pong", messageId: envelope.messageId, sentAt: Date.now() });
}
