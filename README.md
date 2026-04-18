# PeerX

A device-to-device encrypted messaging application for iOS and Android. No accounts, no phone numbers, no server-side message storage.

## Overview

PeerX uses device identifiers instead of personal information to establish identity. Users share their device ID out-of-band to connect with each other. All messages are end-to-end encrypted on the device before transmission and can only be decrypted by the intended recipient.

## Cryptography

- **Key exchange:** X25519 Diffie-Hellman
- **Encryption:** AES-256-GCM with a unique nonce per message
- **Key storage:** Private keys stored in iOS Keychain / Android Keystore
- **Server visibility:** The relay server handles only ciphertext. Plaintext is never transmitted or stored outside the device.

## Architecture

The relay server acts as a message broker, not a message store. When a recipient is online, messages are delivered directly over WebSocket. When offline, messages are queued server-side for up to 24 hours and delivered on reconnection. Push notifications are sent via Firebase Cloud Messaging to alert offline recipients.

The relay server has no access to message content, user identities, or contact relationships beyond the device IDs required for routing.

## Stack

**Mobile**
- Flutter (iOS and Android)
- Drift (local SQLite database)
- flutter_secure_storage (key persistence)
- firebase_messaging (push notifications)

**Server**
- Node.js with TypeScript
- WebSocket (ws package)
- Firebase Cloud Messaging HTTP v1 API
- Deployed on Render

## Limitations

- No key verification mechanism. A compromised relay server could theoretically perform a man-in-the-middle attack by substituting public keys.
- Message queue is in-memory on the server. A server restart clears undelivered messages for offline recipients.
- Device identity is tied to app installation. Reinstalling the app on Android generates a new device ID.
- No message backup or restore.

## Privacy

- No user accounts or registration
- No phone numbers or email addresses collected
- No analytics or tracking
- Messages stored locally on device only
- Server logs contain only device IDs and connection metadata
