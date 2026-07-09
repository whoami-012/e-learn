import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/message_provider.dart';
import '../dashboard/shimmer_skeletons.dart';

/// Top Header with Page Title and Compose Button
class MessagesHeader extends StatelessWidget {
  final VoidCallback onComposeTap;
  final bool showBackButton;

  const MessagesHeader({
    super.key,
    required this.onComposeTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : const Color(0xFF101936),
                    size: 22,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF101936),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
          // Compose Button: Rounded square, white background, subtle shadow, purple icon
          Semantics(
            label: 'New message',
            button: true,
            onTap: onComposeTap,
            child: GestureDetector(
              onTap: onComposeTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE9EBF2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Bar in a rounded container with soft background
class MessageSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const MessageSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF3F1FD), // Soft gray/lavender
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF8E95A5),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF101936),
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E95A5),
                    fontSize: 15,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: () => onChanged(''),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF8E95A5),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling pill filter chips
class MessageFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const MessageFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Mentors', 'Announcements', 'Groups'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF3EFFF)),
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : AppColors.primary),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Avatar component resolving profile URL or pastel fallbacks
class MessageAvatar extends StatelessWidget {
  final String name;
  final MessageType type;
  final String? imageUrl;
  final double size;

  const MessageAvatar({
    super.key,
    required this.name,
    required this.type,
    this.imageUrl,
    this.size = 54,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  Color _getPastelColor(String name) {
    final hash = name.hashCode;
    final List<Color> pastelColors = [
      const Color(0xFFFFE5EC), // Pink
      const Color(0xFFECE8FF), // Purple
      const Color(0xFFE2F1FF), // Blue
      const Color(0xFFE2F7EF), // Green
      const Color(0xFFFFF2E2), // Yellow/Orange
    ];
    return pastelColors[hash.abs() % pastelColors.length];
  }

  Color _getAccentColor(String name) {
    final hash = name.hashCode;
    final List<Color> accentColors = [
      const Color(0xFFFF4B72),
      const Color(0xFF6C45D8),
      const Color(0xFF2D7CEB),
      const Color(0xFF219653),
      const Color(0xFFD48D2A),
    ];
    return accentColors[hash.abs() % accentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    // 1. Group Icon Fallback
    if (type == MessageType.group) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFECE8FF), // Pastel purple
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.groups_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      );
    }

    // 2. Announcement Icon Fallback
    if (type == MessageType.announcement) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7E5), // Pastel yellow
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_rounded,
          color: Color(0xFFFFB020), // Gold bell color
          size: 24,
        ),
      );
    }

    // 3. User Real Image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 4. User Initials Fallback
    final initials = _getInitials(name);
    final bgColor = _getPastelColor(name);
    final textColor = _getAccentColor(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}

/// Optional tag/role badge (Mentor, Group, Official)
class MessageTypeBadge extends StatelessWidget {
  final MessageType type;

  const MessageTypeBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label = '';
    Color bgColor = Colors.transparent;
    Color textColor = Colors.transparent;

    switch (type) {
      case MessageType.mentor:
        label = 'Mentor';
        bgColor = isDark
            ? const Color(0xFF3B0764).withValues(alpha: 0.4)
            : const Color(0xFFF3EFFF);
        textColor = isDark ? const Color(0xFFD8B4FE) : AppColors.primary;
        break;
      case MessageType.group:
        label = 'Group';
        bgColor = isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
            : const Color(0xFFE2F1FF);
        textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2D7CEB);
        break;
      case MessageType.announcement:
        label = 'Official';
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFE2F7EF);
        textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF219653);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Unread Message Badge Indicator
class UnreadBadge extends StatelessWidget {
  final int count;

  const UnreadBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}

/// Individual Message Row Tile
class MessageTile extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const MessageTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  double _scale = 1.0;

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = widget.conversation.unreadCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label:
          '${widget.conversation.name}, ${widget.conversation.lastMessage}, ${_formatTime(widget.conversation.timestamp)}'
          '${isUnread ? ", ${widget.conversation.unreadCount} unread messages" : ""}. Double tap to open.',
      button: true,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _scale = 0.985),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                MessageAvatar(
                  name: widget.conversation.name,
                  type: widget.conversation.type,
                  imageUrl: widget.conversation.avatarUrl,
                ),
                const SizedBox(width: 14),

                // Main Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name + Role Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.conversation.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF101936),
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MessageTypeBadge(type: widget.conversation.type),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Last message preview
                      Text(
                        widget.conversation.lastMessage,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: isUnread
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF101936))
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF6F7588)),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Time + Unread Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(widget.conversation.timestamp),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.w500,
                        color: isUnread
                            ? AppColors.primary
                            : (isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF8E95A5)),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 6),
                    UnreadBadge(count: widget.conversation.unreadCount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Message List Card wrapping the list inside a rounded container
class MessageListCard extends StatelessWidget {
  final List<Conversation> conversations;
  final ValueChanged<Conversation> onTileTap;

  const MessageListCard({
    super.key,
    required this.conversations,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE9EBF2).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE9EBF2).withValues(alpha: 0.4),
              height: 1,
              indent: 84,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return MessageTile(
                conversation: conversation,
                onTap: () => onTileTap(conversation),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state shown when no messages occur
class MessagesEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const MessagesEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3EFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6F7588),
              height: 1.35,
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Full screen block error page with retry action
class MessagesErrorState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRetry;

  const MessagesErrorState({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                    : const Color(0xFFFFECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Color(0xFFFF5757),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF101936),
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13.5,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF6F7588),
                height: 1.4,
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5757),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton loader for message tiles
class MessagesLoadingSkeleton extends StatelessWidget {
  const MessagesLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header search placeholder
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: const ShimmerBox(height: 52, borderRadius: 16),
          ),
          // Chips switcher shimmers
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: ShimmerBox(width: 80, height: 38, borderRadius: 19),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // White list card container shimmers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE9EBF2).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: List.generate(
                  4,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Row(
                      children: [
                        const ShimmerBox(
                            width: 54, height: 54, borderRadius: 27),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const ShimmerBox(
                                      width: 120, height: 16, borderRadius: 4),
                                  const SizedBox(width: 8),
                                  const ShimmerBox(
                                      width: 50, height: 16, borderRadius: 6),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const ShimmerBox(
                                  width: double.infinity,
                                  height: 13,
                                  borderRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShimmerBox(width: 40, height: 11, borderRadius: 3),
                            SizedBox(height: 8),
                            ShimmerBox(width: 18, height: 18, borderRadius: 9),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
