import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Redesigned CourseCard with thumbnail-based layout and premium Soft UI styling.
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final int students;
  final String duration;
  final LinearGradient gradient;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.students = 0,
    this.duration = '4 weeks',
    this.gradient = AppTheme.primaryGradient,
  });

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConstants.serverBase}/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _fullImageUrl(course.thumbnailUrl);
    final baseColor = gradient.colors.first;
    final softBg = baseColor.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            splashColor: baseColor.withValues(alpha: 0.05),
            highlightColor: baseColor.withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // ── 1. Course Thumbnail ────────────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: softBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(baseColor),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(baseColor.withValues(alpha: 0.2)),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(baseColor),
                  ),
                  const SizedBox(width: 16),

                  // ── 2. Course Info ─────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _MetaItem(
                              icon: Icons.group_outlined,
                              label: _formatCount(students),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD1D5DB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _MetaItem(
                              icon: Icons.access_time_rounded,
                              label: duration,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── 3. Action Hint ─────────────────────────────────────────
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFD1D5DB),
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        color: color.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textSecondary.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
