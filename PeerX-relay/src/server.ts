// ─────────────────────────────────────────────────────────────────────────────
// PeerX Relay Server — Entry Point (ws package)
// ─────────────────────────────────────────────────────────────────────────────

import http from "http";
import https from "https";
import fs from "fs";
import { WebSocketServer, WebSocket } from "ws";
import { purgeExpiredQueue, getStats, purgeDeliveredIds } from "./presence";
import { purgeStaleEntries, getRateLimitStats } from "./rateLimit";
import { ConnectedPeer } from "./types";
import { onOpen, onMessage, onClose } from "./router";

// ─── Config ───────────────────────────────────────────────────────────────────

const PORT         = parseInt(process.env.PORT ?? "9001", 10);
const USE_TLS      = process.env.USE_TLS === "true";
const TLS_CERT     = process.env.TLS_CERT_PATH ?? "./certs/cert.pem";
const TLS_KEY      = process.env.TLS_KEY_PATH  ?? "./certs/key.pem";
const STATS_SECRET = process.env.STATS_SECRET  ?? "changeme";

const CLEANUP_INTERVAL_MS   = 5 * 60 * 1000; // 5 minutes
const HEARTBEAT_INTERVAL_MS = 5_000; // 5 seconds

// ─── HTTP Server ──────────────────────────────────────────────────────────────

function createHttpServer() {
  if (USE_TLS) {
    return https.createServer({
      cert: fs.readFileSync(TLS_CERT),
      key:  fs.readFileSync(TLS_KEY),
    });
  }
  return http.createServer();
}

const server = createHttpServer();

// ─── HTTP Request Handler ─────────────────────────────────────────────────────

server.on("request", (req, res) => {
  const url = req.url ?? "/";

  // GET /health
  if (url === "/health" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ ok: true, ts: Date.now() }));
    return;
  }

  // GET /stats (protected)
  if (url === "/stats" && req.method === "GET") {
    const secret = req.headers["x-stats-secret"];
    if (secret !== STATS_SECRET) {
      res.writeHead(401);
      res.end("unauthorized");
      return;
    }
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      presence:  getStats(),
      rateLimit: getRateLimitStats(),
      ts:        Date.now(),
    }));
    return;
  }

  // 404
  res.writeHead(404);
  res.end("not found");
});

// ─── WebSocket Server ─────────────────────────────────────────────────────────

export const wss = new WebSocketServer({ server });

wss.on("connection", (ws: WebSocket) => {
  (ws as any).peerData = {
    deviceId:     "",
    connectedAt:  Date.now(),
    messageCount: 0,
    windowStart:  Date.now(),
    isAlive:      true,
  } as ConnectedPeer & { isAlive: boolean };

  onOpen(ws);

  ws.on("message", (data: Buffer) => {
    onMessage(ws, data);
  });

  ws.on("close", (code: number) => {
    onClose(ws, code);
  });

  ws.on("error", (err: Error) => {
    console.error("[server] socket error:", err.message);
  });

  ws.on("pong", () => {
    (ws as any).peerData.isAlive = true;
  });
});

// ─── Heartbeat ────────────────────────────────────────────────────────────────

const heartbeat = setInterval(() => {
  wss.clients.forEach((ws) => {
    const peer = (ws as any).peerData as ConnectedPeer & { isAlive: boolean };
    if (!peer) return;

    if (peer.isAlive === false) {
      console.log(`[heartbeat] terminating unresponsive: ${peer.deviceId || "unknown"}`);
      ws.terminate();
      return;
    }

    peer.isAlive = false;
    ws.ping();
  });
}, HEARTBEAT_INTERVAL_MS);

wss.on("close", () => clearInterval(heartbeat));

// ─── Listen ───────────────────────────────────────────────────────────────────

server.listen(PORT, () => {
  console.log(`\n[server] PeerX relay running`);
  console.log(`[server] port   : ${PORT}`);
  console.log(`[server] tls    : ${USE_TLS}`);
  console.log(`[server] ws     : ${USE_TLS ? "wss" : "ws"}://0.0.0.0:${PORT}`);
  console.log(`[server] health : http://0.0.0.0:${PORT}/health\n`);
});

// ─── Periodic Cleanup ─────────────────────────────────────────────────────────

setInterval(() => {
  purgeExpiredQueue();
  purgeStaleEntries();
  purgeDeliveredIds();
  const stats = getStats();
  console.log(
    `[cleanup] peers: ${stats.connectedPeers} | queued: ${stats.totalQueued} | watchers: ${stats.presenceWatchers}`
  );
}, CLEANUP_INTERVAL_MS);

// ─── Graceful Shutdown ────────────────────────────────────────────────────────

process.on("SIGINT",  () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

function shutdown(signal: string): void {
  console.log(`\n[server] received ${signal} — shutting down`);
  clearInterval(heartbeat);
  server.close(() => process.exit(0));
}
