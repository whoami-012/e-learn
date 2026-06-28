import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../dashboard/shimmer_skeletons.dart';

/// Style class containing color configurations for specific course categories.
class CourseCategoryStyle {
  final Color backgroundColor;
  final Color textColor;

  const CourseCategoryStyle({
    required this.backgroundColor,
    required this.textColor,
  });

  static const programming = CourseCategoryStyle(
    backgroundColor: Color(0xFFE8F2FF),
    textColor: Color(0xFF2D7CEB),
  );

  static const webDevelopment = CourseCategoryStyle(
    backgroundColor: Color(0xFFE8F2FF),
    textColor: Color(0xFF246CCE),
  );

  static const cybersecurity = CourseCategoryStyle(
    backgroundColor: Color(0xFFFFE7E7),
    textColor: Color(0xFFFF5757),
  );

  static const design = CourseCategoryStyle(
    backgroundColor: Color(0xFFF0E9FF),
    textColor: Color(0xFF8255E8),
  );

  static const dataScience = CourseCategoryStyle(
    backgroundColor: Color(0xFFE2F7EF),
    textColor: Color(0xFF249D72),
  );

  static const general = CourseCategoryStyle(
    backgroundColor: Color(0xFFECEEF6),
    textColor: Color(0xFF686F89),
  );

  static CourseCategoryStyle fromCategory(String? category) {
    if (category == null) return general;
    final lower = category.toLowerCase();
    if (lower.contains('programming') || lower.contains('python') || lower.contains('coding')) {
      return programming;
    } else if (lower.contains('web') || lower.contains('html') || lower.contains('css') || lower.contains('js') || lower.contains('flask')) {
      return webDevelopment;
    } else if (lower.contains('cyber') || lower.contains('security') || lower.contains('hack')) {
      return cybersecurity;
    } else if (lower.contains('design') || lower.contains('ui') || lower.contains('ux')) {
      return design;
    } else if (lower.contains('data') || lower.contains('analytics') || lower.contains('science')) {
      return dataScience;
    }
    return general;
  }
}

/// A premium, polished horizontal card displaying course information.
class CourseListCard extends StatefulWidget {
  const CourseListCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.studentCountLabel,
    required this.durationLabel,
    required this.categoryLabel,
    required this.categoryStyle,
    required this.onTap,
  });

  final String title;
  final String? imageUrl;
  final String? studentCountLabel;
  final String? durationLabel;
  final String? categoryLabel;
  final CourseCategoryStyle categoryStyle;
  final VoidCallback onTap;

  @override
  State<CourseListCard> createState() => _CourseListCardState();
}

class _CourseListCardState extends State<CourseListCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final semanticLabel = '${widget.title}, ${widget.categoryLabel ?? 'Course'}, '
        '${widget.studentCountLabel ?? ''}, ${widget.durationLabel ?? ''}. Double tap to open course details.';

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181B23) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.045),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: (_) => setState(() => _scale = 0.985),
                  onTapUp: (_) => setState(() => _scale = 1.0),
                  onTapCancel: () => setState(() => _scale = 1.0),
                  splashColor: theme.colorScheme.primary.withOpacity(0.04),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.01),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── 1. Thumbnail / Image ──
                        CourseThumbnail(
                          imageUrl: widget.imageUrl,
                          title: widget.title,
                          category: widget.categoryLabel,
                        ),
                        const SizedBox(width: 16),
 
                        // ── 2. Information Area ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Course Title (Supports wraps of 2 lines)
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF101936),
                                  height: 1.25,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              const SizedBox(height: 8),
 
                              // Course Metadata Row
                              CourseMetadataRow(
                                studentCountLabel: widget.studentCountLabel,
                                durationLabel: widget.durationLabel,
                              ),
                              const SizedBox(height: 10),
 
                              // Category Tag
                              if (widget.categoryLabel != null && widget.categoryLabel!.isNotEmpty)
                                CourseCategoryTag(
                                  label: widget.categoryLabel!,
                                  style: widget.categoryStyle,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
 
                        // ── 3. Navigation Arrow Action Indicator ──
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF222631) : const Color(0xFFF3EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CourseThumbnail displays the course artwork or renders a subject-specific fallback.
class CourseThumbnail extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? category;

  const CourseThumbnail({
    super.key,
    required this.imageUrl,
    required this.title,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 120,
        height: 115,
        child: hasValidImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const ShimmerBox(
                    width: 120,
                    height: 115,
                    borderRadius: 18,
                  );
                },
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    final cleanCategory = category?.toLowerCase() ?? '';
    final cleanTitle = title.toLowerCase();

    Gradient gradient;
    IconData icon;
    Color iconColor;

    if (cleanCategory.contains('programming') ||
        cleanCategory.contains('python') ||
        cleanTitle.contains('python') ||
        cleanTitle.contains('programming') ||
        cleanTitle.contains('coding')) {
      gradient = const LinearGradient(
        colors: [Color(0xFFE8F2FF), Color(0xFFADCFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.terminal_rounded;
      iconColor = const Color(0xFF2D7CEB);
    } else if (cleanCategory.contains('web') ||
        cleanTitle.contains('web') ||
        cleanTitle.contains('html') ||
        cleanTitle.contains('flask') ||
        cleanTitle.contains('development')) {
      gradient = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.web_rounded;
      iconColor = const Color(0xFFE8F2FF);
    } else if (cleanCategory.contains('cyber') ||
        cleanCategory.contains('security') ||
        cleanTitle.contains('security') ||
        cleanTitle.contains('cyber')) {
      gradient = const LinearGradient(
        colors: [Color(0xFFFFE7E7), Color(0xFFFF8E8E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.security_rounded;
      iconColor = const Color(0xFFFF5757);
    } else if (cleanCategory.contains('design') ||
        cleanCategory.contains('ui') ||
        cleanCategory.contains('ux') ||
        cleanTitle.contains('ui') ||
        cleanTitle.contains('design') ||
        cleanTitle.contains('ux') ||
        cleanTitle.contains('adobe') ||
        cleanTitle.contains('figma')) {
      gradient = const LinearGradient(
        colors: [Color(0xFFF0E9FF), Color(0xFFC7B3FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.palette_rounded;
      iconColor = const Color(0xFF8255E8);
    } else if (cleanCategory.contains('data') ||
        cleanCategory.contains('analytics') ||
        cleanTitle.contains('data') ||
        cleanTitle.contains('analytics') ||
        cleanTitle.contains('business')) {
      gradient = const LinearGradient(
        colors: [Color(0xFFE2F7EF), Color(0xFF9FF1D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.bar_chart_rounded;
      iconColor = const Color(0xFF249D72);
    } else {
      gradient = const LinearGradient(
        colors: [Color(0xFFECEEF6), Color(0xFFD5DAEA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.school_rounded;
      iconColor = const Color(0xFF686F89);
    }

    final initials = _getInitials(title);

    return Container(
      width: 120,
      height: 115,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background graphic watermark decoration
          Positioned(
            right: -12,
            bottom: -12,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                icon,
                size: 76,
                color: iconColor,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
              const SizedBox(height: 6),
              if (initials.isNotEmpty)
                Text(
                  initials,
                  style: TextStyle(
                    color: iconColor.withOpacity(0.85),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String title) {
    final parts = title.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
    }
    return title.isNotEmpty ? title[0].toUpperCase() : '';
  }
}

/// CourseMetadataRow displays horizontal student counts and course duration with a vertical divider.
class CourseMetadataRow extends StatelessWidget {
  final String? studentCountLabel;
  final String? durationLabel;

  const CourseMetadataRow({
    super.key,
    this.studentCountLabel,
    this.durationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasStudents = studentCountLabel != null && studentCountLabel!.isNotEmpty;
    final hasDuration = durationLabel != null && durationLabel!.isNotEmpty;

    if (!hasStudents && !hasDuration) {
      return const SizedBox.shrink();
    }

    const mutedColor = Color(0xFF8E95A5);

    return Row(
      children: [
        if (hasStudents) ...[
          const Icon(
            Icons.people_alt_outlined,
            color: mutedColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              studentCountLabel!,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (hasStudents && hasDuration) ...[
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 14,
            color: const Color(0xFFE9EBF2),
          ),
          const SizedBox(width: 10),
        ],
        if (hasDuration) ...[
          const Icon(
            Icons.schedule_outlined,
            color: mutedColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              durationLabel!,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// CourseCategoryTag displays the category label in a beautifully tinted bubble.
class CourseCategoryTag extends StatelessWidget {
  final String label;
  final CourseCategoryStyle style;

  const CourseCategoryTag({
    super.key,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: style.textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}
