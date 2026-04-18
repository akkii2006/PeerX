import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/identity/identity_service.dart';
import '../../core/relay/relay_service.dart';
import '../../data/db/database.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/incoming_request_sheet.dart';
import 'package:drift/drift.dart' show Value;

class AddPeerScreen extends StatefulWidget {
  const AddPeerScreen({super.key});

  @override
  State<AddPeerScreen> createState() => _AddPeerScreenState();
}

class _AddPeerScreenState extends State<AddPeerScreen> {
  final _identity    = IdentityService();
  final _relay       = RelayService();
  final _controller  = TextEditingController();
  bool  _sending     = false;

  String get _myId => _identity.deviceId;
  String get _shortId => _myId.substring(0, 8).toUpperCase();

  @override
  void initState() {
    super.initState();
    _listenForRequests();
  }

  void _listenForRequests() {
    _relay.onAddRequest.listen((event) async {
      // Check if blocked
      final blocked = await database.requestsDao.isBlocked(event.fromDeviceId);
      if (blocked) return;

      // Save to DB
      await database.requestsDao.insertRequest(PeerRequestsCompanion(
        id:           Value(event.requestId),
        fromDeviceId: Value(event.fromDeviceId),
        receivedAt:   Value(DateTime.now().millisecondsSinceEpoch),
      ));

      // Show bottom sheet
      if (mounted) {
        showModalBottomSheet(
          context:           context,
          backgroundColor:   Colors.transparent,
          isScrollControlled: true,
          builder:           (_) => IncomingRequestSheet(
            requestId:    event.requestId,
            fromDeviceId: event.fromDeviceId,
          ),
        );
      }
    });

    _relay.onAddResponse.listen((event) async {
      if (!event.accepted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         const Text('Request declined'),
              backgroundColor: const Color(0xFF1A1A1A),
              behavior:        SnackBarBehavior.floating,
              shape:           RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      // Add as contact
      await database.contactsDao.upsertContact(ContactsCompanion(
        deviceId:  Value(event.fromDeviceId),
        publicKey: Value(event.fromDeviceId), // will be updated via key_sync
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         const Text('Connection established!'),
            backgroundColor: AppTheme.primary,
            behavior:        SnackBarBehavior.floating,
            shape:           RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  Future<void> _sendRequest() async {
    final peerId = _controller.text.trim().toLowerCase();

    if (peerId.isEmpty) return;
    if (peerId == _myId) {
      _showError('You cannot add yourself');
      return;
    }
    if (peerId.length != 32) {
      _showError('Invalid peer ID — must be 32 characters');
      return;
    }

    setState(() => _sending = true);

    try {
      await _relay.sendAddRequest(peerId);
      _controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         const Text('Request sent!'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior:        SnackBarBehavior.floating,
            shape:           RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to send request');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: Colors.redAccent,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _copyMyId() {
    Clipboard.setData(ClipboardData(text: _myId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         const Text('Your ID copied!'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor:       Colors.black,
            surfaceTintColor:      Colors.transparent,
            expandedHeight:        120,
            pinned:                true,
            automaticallyImplyLeading: false,
            flexibleSpace:         FlexibleSpaceBar(
              titlePadding:        const EdgeInsets.only(left: 20, bottom: 16),
              title:               const Text(
                'Add Peer',
                style: TextStyle(
                  fontSize:     28,
                  fontWeight:   FontWeight.w800,
                  color:        Colors.white,
                  letterSpacing: -1,
                ),
              ),
              background: Container(color: Colors.black),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver:  SliverList(
              delegate: SliverChildListDelegate([

                // ── Your ID card ─────────────────────────────────────────

                Container(
                  padding:    const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:        AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding:    const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:        AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.fingerprint_rounded,
                              color: AppTheme.primary,
                              size:  20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your ID',
                            style: TextStyle(
                              fontSize:   15,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Short ID display
                      Text(
                        _shortId,
                        style: const TextStyle(
                          fontSize:   32,
                          fontWeight: FontWeight.w800,
                          color:      Colors.white,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Full ID
                      Text(
                        _myId,
                        style: const TextStyle(
                          fontSize:   11,
                          color:      AppTheme.textMuted,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Copy button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _copyMyId,
                          icon:      const Icon(Icons.copy_rounded, size: 16),
                          label:     const Text('Copy my ID'),
                          style:     FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding:         const EdgeInsets.symmetric(vertical: 14),
                            shape:           RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Add someone ──────────────────────────────────────────

                const Text(
                  'Add someone',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller:    _controller,
                  style:         const TextStyle(
                    color:      Colors.white,
                    fontSize:   14,
                    fontFamily: 'monospace',
                  ),
                  decoration:    const InputDecoration(
                    hintText:    'Paste peer ID here',
                    prefixIcon:  Icon(Icons.person_search_rounded, color: AppTheme.textMuted),
                  ),
                  maxLength:     32,
                  buildCounter:  (_, {required currentLength, required isFocused, maxLength}) => null,
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _sendRequest,
                    style:     FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: AppTheme.primaryDim,
                      padding:         const EdgeInsets.symmetric(vertical: 16),
                      shape:           RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                      height: 20,
                      width:  20,
                      child:  CircularProgressIndicator(
                        strokeWidth: 2,
                        color:       Colors.white,
                      ),
                    )
                        : const Text(
                      'Send request',
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Pending requests ─────────────────────────────────────

                StreamBuilder<List<PeerRequest>>(
                  stream:  database.requestsDao.watchPendingRequests(),
                  builder: (context, snap) {
                    final requests = snap.data ?? [];
                    if (requests.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Pending requests',
                              style: TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.w600,
                                color:      Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:        AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${requests.length}',
                                style: const TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w700,
                                  color:      Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...requests.map((r) => _RequestTile(request: r)),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Request Tile ──────────────────────────────────────────────────────────────

class _RequestTile extends StatelessWidget {
  final PeerRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:     const EdgeInsets.only(bottom: 8),
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width:      40,
            height:     40,
            decoration: BoxDecoration(
              color:        AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.fromDeviceId.substring(0, 8).toUpperCase(),
              style: const TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w600,
                color:      Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context:            context,
                backgroundColor:    Colors.transparent,
                isScrollControlled: true,
                builder:            (_) => IncomingRequestSheet(
                  requestId:    request.id,
                  fromDeviceId: request.fromDeviceId,
                ),
              );
            },
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}