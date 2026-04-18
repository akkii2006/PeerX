import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/relay/relay_service.dart';
import '../../../data/db/database.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:drift/drift.dart' show Value;

class IncomingRequestSheet extends StatelessWidget {
  final String requestId;
  final String fromDeviceId;

  const IncomingRequestSheet({
    super.key,
    required this.requestId,
    required this.fromDeviceId,
  });

  String get _shortId => fromDeviceId.substring(0, 8).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width:      40,
            height:     4,
            decoration: BoxDecoration(
              color:        AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Icon
          Container(
            width:      72,
            height:     72,
            decoration: BoxDecoration(
              color:        AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppTheme.primary,
              size:  32,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Peer request',
            style: TextStyle(
              fontSize:   22,
              fontWeight: FontWeight.w700,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Someone wants to connect with you',
            style: TextStyle(
              fontSize: 14,
              color:    AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ID card
          Container(
            width:      double.infinity,
            padding:    const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Their ID',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _shortId,
                      style: const TextStyle(
                        fontSize:   22,
                        fontWeight: FontWeight.w700,
                        color:      Colors.white,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:      const Icon(Icons.copy_rounded, size: 16),
                      color:     AppTheme.textSecondary,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: fromDeviceId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:         const Text('ID copied'),
                            backgroundColor: const Color(0xFF1A1A1A),
                            behavior:        SnackBarBehavior.floating,
                            shape:           RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  fromDeviceId,
                  style: const TextStyle(
                    fontSize:   10,
                    color:      AppTheme.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Accept button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _respond(context, true),
              style:     FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding:         const EdgeInsets.symmetric(vertical: 16),
                shape:           RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Accept',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Reject button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _respond(context, false),
              style:     OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side:            const BorderSide(color: AppTheme.border),
                padding:         const EdgeInsets.symmetric(vertical: 16),
                shape:           RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Block button
          TextButton(
            onPressed: () => _block(context),
            style:     TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Block this ID'),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(BuildContext context, bool accepted) async {
    Navigator.pop(context);

    await RelayService().sendAddResponse(
      toDeviceId: fromDeviceId,
      requestId:  requestId,
      accepted:   accepted,
    );

    await database.requestsDao.updateStatus(
      requestId,
      accepted ? 'accepted' : 'rejected',
    );

    if (accepted) {
      await database.contactsDao.upsertContact(ContactsCompanion(
        deviceId:  Value(fromDeviceId),
        publicKey: Value(fromDeviceId), // updated via key_sync
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    }
  }

  Future<void> _block(BuildContext context) async {
    Navigator.pop(context);
    await database.requestsDao.blockDevice(fromDeviceId);
    await database.contactsDao.blockContact(fromDeviceId);
    await database.requestsDao.updateStatus(requestId, 'blocked');
  }
}