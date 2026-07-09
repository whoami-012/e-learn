import 'package:flutter/material.dart';

/// Redesigned premium screen header with back-action icon and notifications action.
class CourseScreenHeader extends StatelessWidget {
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const CourseScreenHeader({
    super.key,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Circle back button
          if (canPop)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181B23) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.045),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF303542)
                        : const Color(0xFFE9EBF2).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : const Color(0xFF101936),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48),

          // Center: Title
          Text(
            'Explore Courses',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),

          // Right: Circle action button
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181B23) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.045),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF303542)
                      : const Color(0xFFE9EBF2).withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  actionIcon ?? Icons.notifications_none_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF101936),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large, custom search field displaying purple icons and interactive clear triggers.
class CourseSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const CourseSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<CourseSearchField> createState() => _CourseSearchFieldState();
}

class _CourseSearchFieldState extends State<CourseSearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181B23) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isFocused
                ? theme.colorScheme.primary
                : (isDark
                    ? const Color(0xFF303542)
                    : const Color(0xFFE9EBF2).withValues(alpha: 0.5)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? theme.colorScheme.primary.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 26,
                minHeight: 26,
              ),
              hintText: 'Search by course name...',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Plus Jakarta Sans',
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? const Color(0xFFADB4C4)
                            : const Color(0xFF6F7588),
                        size: 20,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrolling course filters bar using rounded custom chips.
class CourseFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CourseFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Free', 'Paid'];

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CourseFilterChip(
              label: filter,
              isSelected: isSelected,
              onTap: () => onFilterChanged(filter),
            ),
          );
        },
      ),
    );
  }
}

/// Custom, animated rounded pill chip displaying a gradient when active.
class CourseFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CourseFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF181B23) : Colors.white),
          borderRadius: BorderRadius.circular(99),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF303542)
                      : const Color(0xFFE9EBF2),
                  width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFFADB4C4)
                          : const Color(0xFF101936)),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
