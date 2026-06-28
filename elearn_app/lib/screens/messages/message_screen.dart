import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../../widgets/messages/message_widgets.dart';
import '../../screens/courses/course_list_screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/profile/profile_screen.dart';
import 'contact_select_screen.dart';
import 'chat_detail_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == 3) return; // Already on messages
    
    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    if (index == 1) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CourseListScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      );
      return;
    }

    if (index == 4) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final conversations = provider.filteredConversations;
    final user = context.watch<UserProvider>().user;
    final isStudent = user?.role == 'student';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8FC),
      bottomNavigationBar: isStudent
          ? SafeArea(
              child: AppBottomNavigation(
                currentIndex: 3,
                onTap: _onBottomNavTapped,
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          color: const Color(0xFF5B35F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Offline Warning Banner ──
              if (provider.isOffline)
                Container(
                  color: const Color(0xFFFFECEC),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: const [
                      Icon(Icons.wifi_off_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You're offline. Showing cached messages.",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Top Header ──
              MessagesHeader(
                showBackButton: !isStudent,
                onComposeTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactSelectScreen()),
                  );
                },
              ),

              // ── Search bar ──
              MessageSearchBar(
                query: provider.searchQuery,
                onChanged: (val) => provider.setSearchQuery(val),
              ),

              // ── Filter Chips ──
              MessageFilterChips(
                selectedFilter: provider.selectedFilter,
                onSelected: (val) => provider.setFilter(val),
              ),

              // ── Main Content Area ──
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (provider.isLoading) {
                      return const MessagesLoadingSkeleton();
                    }

                    if (provider.error != null) {
                      return MessagesErrorState(
                        title: 'Failed to load messages',
                        description: provider.error!,
                        onRetry: provider.refresh,
                      );
                    }

                    if (conversations.isEmpty) {
                      final hasSearch = provider.searchQuery.isNotEmpty;
                      return MessagesEmptyState(
                        title: hasSearch ? 'No search results' : 'No messages yet',
                        description: hasSearch
                            ? "We couldn't find any chats matching '${provider.searchQuery}'"
                            : "Start a conversation with mentors or study groups.",
                        icon: hasSearch ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
                      );
                    }

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          MessageListCard(
                            conversations: conversations,
                            onTileTap: (conv) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    conversationId: conv.id,
                                    participantName: conv.name,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
