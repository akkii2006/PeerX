// ─────────────────────────────────────────────────────────────────────────────
// PeerX Relay Server — Presence Manager
// ─────────────────────────────────────────────────────────────────────────────

import { WebSocket } from "ws";
import { ConnectedPeer, QueuedMessage, KeySyncEvent } from "./types";

// ─── Constants ────────────────────────────────────────────────────────────────

const QUEUE_TTL_MS        = 24 * 60 * 60 * 1000; // 24 hours
const MAX_QUEUE_PER_PEER  = 500;
const DELIVERED_TTL_MS    = 5 * 60 * 1000;
const MAX_DELIVERED_IDS   = 2000;

// ─── In-Memory Stores ─────────────────────────────────────────────────────────

const sockets               = new Map<string, WebSocket>();
const offlineQueue          = new Map<string, QueuedMessage[]>();
const presenceSubscriptions = new Map<string, Set<string>>();
const pushTokens            = new Map<string, string>();

// publicKeys: deviceId → base64 X25519 public key
// This is the source of truth. Re-sent by device on every handshake.
const publicKeys            = new Map<string, string>();

type DeliveredEntry = { deliveredAt: number };
const deliveredIds          = new Map<string, DeliveredEntry>();

// ─── Connection ───────────────────────────────────────────────────────────────

export function registerPeer(deviceId: string, ws: WebSocket): void {
  sockets.set(deviceId, ws);
  console.log(`[presence] + ${deviceId} (total: ${sockets.size})`);
}

export function unregisterPeer(deviceId: string): void {
  sockets.delete(deviceId);
  console.log(`[presence] - ${deviceId} (total: ${sockets.size})`);
}

// ─── Push Tokens ─────────────────────────────────────────────────────────────

export function registerPushToken(deviceId: string, token: string): void {
  pushTokens.set(deviceId, token);
}

export function getPushToken(deviceId: string): string | undefined {
  return pushTokens.get(deviceId);
}

export function removePushToken(deviceId: string): void {
  pushTokens.delete(deviceId);
}

// ─── Public Keys ──────────────────────────────────────────────────────────────

export function registerPublicKey(deviceId: string, publicKey: string): void {
  const existing = publicKeys.get(deviceId);
  publicKeys.set(deviceId, publicKey);

  // If the key changed, notify all subscribers so they can re-derive session keys
  if (existing && existing !== publicKey) {
    console.log(`[presence] key rotated for ${deviceId} — notifying subscribers`);
    broadcastKeySync(deviceId, publicKey);
  }
}

export function getPublicKey(deviceId: string): string | undefined {
  return publicKeys.get(deviceId);
}

export function hasPublicKey(deviceId: string): boolean {
  return publicKeys.has(deviceId);
}

// ─── Key Sync Broadcast ───────────────────────────────────────────────────────
// Push a peer's public key to all their subscribers.
// Called on key rotation and can be called on demand from the router.

export function broadcastKeySync(peerId: string, publicKey: string): void {
  const subscribers = presenceSubscriptions.get(peerId);
  if (!subscribers || subscribers.size === 0) return;

  const event: KeySyncEvent = {
    type:      "key_sync",
    peerId,
    publicKey,
    timestamp: Date.now(),
    messageId: `ks-${peerId}-${Date.now()}`,
    sentAt:    Date.now(),
    from:      "server",
  };

  const raw = JSON.stringify(event);

  for (const subscriberId of subscribers) {
    const ws = sockets.get(subscriberId);
    if (ws) {
      try { ws.send(raw); } catch {}
    }
  }
}

// ─── Send Key to a Single Peer ────────────────────────────────────────────────
// Used by the router to push a key directly to one socket without broadcasting.

export function sendKeySync(
  targetWs: WebSocket,
  peerId: string,
  publicKey: string,
): void {
  const event: KeySyncEvent = {
    type:      "key_sync",
    peerId,
    publicKey,
    timestamp: Date.now(),
    messageId: `ks-${peerId}-${Date.now()}`,
    sentAt:    Date.now(),
    from:      "server",
  };
  try {
    if (targetWs.readyState === targetWs.OPEN) {
      targetWs.send(JSON.stringify(event));
    }
  } catch {}
}

// ─── Lookup ───────────────────────────────────────────────────────────────────

export function getSocket(deviceId: string): WebSocket | undefined {
  return sockets.get(deviceId);
}

export function isOnline(deviceId: string): boolean {
  return sockets.has(deviceId);
}

export function getOnlineCount(): number {
  return sockets.size;
}

// ─── Presence Subscriptions ───────────────────────────────────────────────────

export function subscribeToPresence(
  subscriberId: string,
  watchedPeerIds: string[]
): void {
  for (const peerId of watchedPeerIds) {
    if (!presenceSubscriptions.has(peerId)) {
      presenceSubscriptions.set(peerId, new Set());
    }
    presenceSubscriptions.get(peerId)!.add(subscriberId);
  }
}

export function unsubscribeAll(subscriberId: string): void {
  for (const subscribers of presenceSubscriptions.values()) {
    subscribers.delete(subscriberId);
  }
}

export function broadcastPresence(peerId: string, online: boolean): void {
  const subscribers = presenceSubscriptions.get(peerId);
  if (!subscribers || subscribers.size === 0) return;

  const pubKey = publicKeys.get(peerId);

  const event = {
    type:      "presence",
    peerId,
    online,
    publicKey: pubKey,
    timestamp: Date.now(),
  };

  const raw = JSON.stringify(event);

  for (const subscriberId of subscribers) {
    const ws = sockets.get(subscriberId);
    if (ws) {
      try { ws.send(raw); } catch {}
    }
  }
}

// ─── Offline Queue ────────────────────────────────────────────────────────────

export function enqueue(recipientId: string, message: QueuedMessage): void {
  if (!offlineQueue.has(recipientId)) {
    offlineQueue.set(recipientId, []);
  }
  const queue = offlineQueue.get(recipientId)!;
  if (queue.length >= MAX_QUEUE_PER_PEER) {
    queue.shift();
    console.warn(`[queue] ${recipientId} full — dropped oldest`);
  }
  queue.push(message);
}

export function drainQueue(recipientId: string): QueuedMessage[] {
  const queue = offlineQueue.get(recipientId);
  if (!queue || queue.length === 0) return [];

  const now   = Date.now();
  const valid = queue.filter((m) =>
    now - m.queuedAt < QUEUE_TTL_MS &&
    !deliveredIds.has(m.envelope.messageId)
  );
  offlineQueue.delete(recipientId);

  if (valid.length > 0) {
    console.log(`[queue] draining ${valid.length} for ${recipientId}`);
  }
  return valid;
}

// ─── Delivered ID Tracking ────────────────────────────────────────────────────

export function markDelivered(messageId: string): void {
  if (deliveredIds.size >= MAX_DELIVERED_IDS) {
    const oldest = [...deliveredIds.entries()]
      .sort((a, b) => a[1].deliveredAt - b[1].deliveredAt)
      .slice(0, 200);
    for (const [id] of oldest) deliveredIds.delete(id);
  }
  deliveredIds.set(messageId, { deliveredAt: Date.now() });
}

export function purgeDeliveredIds(): void {
  const now = Date.now();
  let purged = 0;
  for (const [id, entry] of deliveredIds.entries()) {
    if (now - entry.deliveredAt > DELIVERED_TTL_MS) {
      deliveredIds.delete(id);
      purged++;
    }
  }
  if (purged > 0) console.log(`[delivered] purged ${purged} stale IDs`);
}

export function getQueueSize(recipientId: string): number {
  return offlineQueue.get(recipientId)?.length ?? 0;
}

export function purgeExpiredQueue(): void {
  const now = Date.now();
  let purged = 0;
  for (const [deviceId, queue] of offlineQueue.entries()) {
    const before = queue.length;
    const valid  = queue.filter((m) => now - m.queuedAt < QUEUE_TTL_MS);
    if (valid.length !== before) {
      purged += before - valid.length;
      valid.length === 0
        ? offlineQueue.delete(deviceId)
        : offlineQueue.set(deviceId, valid);
    }
  }
  if (purged > 0) console.log(`[queue] purged ${purged} expired`);
}

// ─── Stats ────────────────────────────────────────────────────────────────────

export function getStats() {
  return {
    connectedPeers:   sockets.size,
    queuedDevices:    offlineQueue.size,
    totalQueued:      [...offlineQueue.values()].reduce((s, q) => s + q.length, 0),
    presenceWatchers: presenceSubscriptions.size,
    pushTokens:       pushTokens.size,
    publicKeys:       publicKeys.size,
  };
}