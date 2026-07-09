import 'package:flutter/material.dart';

class DashboardCategory {
  final String title;
  final int courses;
  final IconData icon;
  final Color baseColor;

  DashboardCategory({
    required this.title,
    required this.courses,
    required this.icon,
    required this.baseColor,
  });
}

class CategoryCard extends StatelessWidget {
  final DashboardCategory category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: category.baseColor.withValues(alpha: 0.1), // e.g. from-blue-50 to blue-100 equivalent
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.baseColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                )
              ],
            ),
            child: Icon(category.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            category.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.courses} Courses',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
