// ─────────────────────────────────────────────────────────────────────────────
// PeerX Relay Server — Shared Types
// ─────────────────────────────────────────────────────────────────────────────

export type EnvelopeType =
  | "handshake"
  | "message"
  | "ack"
  | "ping"
  | "pong"
  | "presence"
  | "add_request"
  | "add_response"
  | "key_sync"       // server → client: here is a peer's public key
  | "key_request"    // client → server: give me this peer's public key
  | "error";

export type Envelope = {
  type:        EnvelopeType;
  from:        string;
  to?:         string;
  payload?:    string;
  messageId:   string;
  sentAt:      number;
  requestId?:  string;
  note?:       string;
  accepted?:   boolean;
  queued?:     boolean;
  pushToken?:  string;
  publicKey?:  string;  // sender's X25519 public key (base64)
  peerId?:     string;  // used in key_sync: whose key this is
};

export type PresenceEvent = {
  type:      "presence";
  peerId:    string;
  online:    boolean;
  publicKey?: string;
  timestamp: number;
};

// Sent server → client whenever a peer's key is available/updated
export type KeySyncEvent = {
  type:      "key_sync";
  peerId:    string;
  publicKey: string;
  timestamp: number;
  messageId: string;
  sentAt:    number;
  from:      "server";
};

export type QueuedMessage = {
  envelope: Envelope;
  queuedAt: number;
};

export type ConnectedPeer = {
  deviceId:     string;
  connectedAt:  number;
  messageCount: number;
  windowStart:  number;
};

export type ErrorCode =
  | "INVALID_ENVELOPE"
  | "RATE_LIMITED"
  | "RECIPIENT_UNKNOWN"
  | "PAYLOAD_TOO_LARGE"
  | "MISSING_DEVICE_ID"
  | "KEY_NOT_FOUND"
  | "INTERNAL_ERROR";

export type ErrorEnvelope = {
  type:       "error";
  code:       ErrorCode;
  message:    string;
  messageId?: string;
};