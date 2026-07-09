import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onCreateCourse;
  final VoidCallback? onUploadContent;
  final VoidCallback? onScheduleClass;

  const QuickActionsWidget({
    super.key,
    this.onCreateCourse,
    this.onUploadContent,
    this.onScheduleClass,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding since it's shifted upwards due to SearchBar
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
      child: Column(
        children: [
          _buildActionCard(
            title: 'Create Course',
            icon: Icons.add,
            gradient: AppTheme.actionCreateGradient,
            onTap: onCreateCourse ?? () {},
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Upload Content',
            icon: Icons.upload_rounded,
            gradient: AppTheme.actionUploadGradient,
            onTap: onUploadContent ?? () {},
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: 'Schedule Class',
            icon: Icons.calendar_month,
            gradient: AppTheme.actionScheduleGradient,
            onTap: onScheduleClass ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
