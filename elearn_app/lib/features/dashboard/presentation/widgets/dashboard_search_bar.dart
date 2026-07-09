import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// DashboardSearchBar — a styled search field that drives the existing
/// [TeacherDashboardProvider.searchCourses] callback.
class DashboardSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const DashboardSearchBar({super.key, required this.onChanged});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.navy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.miniShadow,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(Icons.search_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: TextStyle(fontSize: 14, color: textColor),
                decoration: const InputDecoration(
                  hintText: 'Search courses, students, classes…',
                  hintStyle:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  filled: false,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 18),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
