import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/db/database.dart';
import '../../core/relay/relay_service.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/conversation_tile.dart';
import '../add_peer/add_peer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _ChatsTab(),
          AddPeerScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon:          Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon:  Icon(Icons.chat_bubble_rounded),
            label:         'Chats',
          ),
          NavigationDestination(
            icon:          Icon(Icons.person_add_outlined),
            selectedIcon:  Icon(Icons.person_add_rounded),
            label:         'Add',
          ),
        ],
      ),
    );
  }
}

// ── Chats Tab ─────────────────────────────────────────────────────────────────

class _ChatsTab extends StatefulWidget {
  const _ChatsTab();

  @override
  State<_ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<_ChatsTab> {
  final _relay = RelayService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor:     Colors.black,
            surfaceTintColor:    Colors.transparent,
            expandedHeight:      120,
            pinned:              true,
            flexibleSpace:       FlexibleSpaceBar(
              titlePadding:      const EdgeInsets.only(left: 20, bottom: 16),
              title:             const Text(
                'PeerX',
                style: TextStyle(
                  fontSize:     28,
                  fontWeight:   FontWeight.w800,
                  color:        Colors.white,
                  letterSpacing: -1,
                ),
              ),
              background:        Container(color: Colors.black),
            ),
            actions: [
              // Connection indicator
              StreamBuilder<bool>(
                stream:       _relay.onConnected,
                initialData:  _relay.isConnected,
                builder:      (context, snap) {
                  final connected = snap.data ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child:   AnimatedContainer(
                      duration:     const Duration(milliseconds: 500),
                      width:        8,
                      height:       8,
                      decoration:   BoxDecoration(
                        shape: BoxShape.circle,
                        color: connected ? AppTheme.online : AppTheme.textMuted,
                        boxShadow: connected ? [
                          BoxShadow(
                            color:       AppTheme.online.withOpacity(0.5),
                            blurRadius:  6,
                            spreadRadius: 1,
                          ),
                        ] : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Contacts list
          StreamBuilder<List<Contact>>(
            stream:  database.contactsDao.watchAllContacts(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final contacts = snap.data!;

              if (contacts.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver:  SliverList.separated(
                  itemCount:    contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder:  (context, i) => ConversationTile(
                    contact: contacts[i],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:      80,
            height:     80,
            decoration: BoxDecoration(
              color:        AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size:  36,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add someone to start chatting',
            style: TextStyle(
              fontSize: 14,
              color:    AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}