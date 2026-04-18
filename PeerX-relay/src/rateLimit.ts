// ─────────────────────────────────────────────────────────────────────────────
// PeerX Relay Server — Rate Limiter
// ─────────────────────────────────────────────────────────────────────────────

// ─── Config ───────────────────────────────────────────────────────────────────

const WINDOW_MS       = 60_000; // 1 minute rolling window
const MAX_PER_WINDOW  = 60;     // max messages per device per window
const MAX_PAYLOAD_BYTES = 64 * 1024; // 64 KB max payload

// ─── In-Memory Store ──────────────────────────────────────────────────────────

type RateLimitEntry = {
  count: number;
  windowStart: number;
};

const store = new Map<string, RateLimitEntry>();

// ─── Core Check ───────────────────────────────────────────────────────────────

/**
 * Returns true if the device is allowed to send, false if rate limited.
 * Call this before routing every message.
 */
export function checkRateLimit(deviceId: string): boolean {
  const now = Date.now();
  const entry = store.get(deviceId);

  if (!entry || now - entry.windowStart > WINDOW_MS) {
    // New window
    store.set(deviceId, { count: 1, windowStart: now });
    return true;
  }

  if (entry.count >= MAX_PER_WINDOW) {
    return false; // rate limited
  }

  entry.count++;
  return true;
}

/**
 * Returns remaining messages allowed in the current window.
 */
export function getRemainingQuota(deviceId: string): number {
  const now = Date.now();
  const entry = store.get(deviceId);

  if (!entry || now - entry.windowStart > WINDOW_MS) {
    return MAX_PER_WINDOW;
  }

  return Math.max(0, MAX_PER_WINDOW - entry.count);
}

/**
 * Returns ms until the current rate limit window resets.
 */
export function getWindowResetMs(deviceId: string): number {
  const entry = store.get(deviceId);
  if (!entry) return 0;

  const elapsed = Date.now() - entry.windowStart;
  return Math.max(0, WINDOW_MS - elapsed);
}

// ─── Payload Size Check ───────────────────────────────────────────────────────

/**
 * Returns true if the payload is within the allowed size.
 */
export function checkPayloadSize(raw: string): boolean {
  // Each JS string char is at most 2 bytes (UTF-16),
  // but we measure by byte length for accuracy.
  const bytes = Buffer.byteLength(raw, "utf8");
  return bytes <= MAX_PAYLOAD_BYTES;
}

export function getMaxPayloadBytes(): number {
  return MAX_PAYLOAD_BYTES;
}

// ─── Cleanup ──────────────────────────────────────────────────────────────────
// Removes stale entries for disconnected devices.
// Call this periodically or on disconnect.

export function clearDevice(deviceId: string): void {
  store.delete(deviceId);
}

export function purgeStaleEntries(): void {
  const now = Date.now();
  let purged = 0;

  for (const [id, entry] of store.entries()) {
    if (now - entry.windowStart > WINDOW_MS * 2) {
      store.delete(id);
      purged++;
    }
  }

  if (purged > 0) {
    console.log(`[rateLimit] purged ${purged} stale entries`);
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

export function getRateLimitStats() {
  return {
    trackedDevices: store.size,
    windowMs:       WINDOW_MS,
    maxPerWindow:   MAX_PER_WINDOW,
    maxPayloadBytes: MAX_PAYLOAD_BYTES,
  };
}