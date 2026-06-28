import 'package:flutter/material.dart';
import 'calendar_widgets.dart';

/// EventColorScheme resolves pastel backgrounds and dark line accents.
class EventColorScheme {
  final Color background;
  final Color accent;

  const EventColorScheme({required this.background, required this.accent});

  static const biology = EventColorScheme(
    background: Color(0xFFFFE5EC),
    accent: Color(0xFFFF4B72),
  );

  static const chemistry = EventColorScheme(
    background: Color(0xFFECE8FF),
    accent: Color(0xFF6C45D8),
  );

  static const physics = EventColorScheme(
    background: Color(0xFFE2F1FF),
    accent: Color(0xFF2D7CEB),
  );

  static const exam = EventColorScheme(
    background: Color(0xFFE2F7EF),
    accent: Color(0xFF219653),
  );

  static const general = EventColorScheme(
    background: Color(0xFFF3EFFF),
    accent: Color(0xFF6C45D8),
  );

  static EventColorScheme fromSubjectAndStatus(String? subject, String status) {
    if (status.toLowerCase() == 'exam' || status.toLowerCase() == 'test') {
      return exam;
    }
    if (subject == null) return general;
    final lower = subject.toLowerCase();
    if (lower.contains('biology')) return biology;
    if (lower.contains('chemistry')) return chemistry;
    if (lower.contains('physics')) return physics;
    return general;
  }
}

/// A premium, rounded horizontal class/exam schedule event card.
class CalendarEventCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String startTime;
  final String endTime;
  final String? instructorName;
  final bool isLive;
  final String subject;
  final EventColorScheme colorScheme;
  final VoidCallback onTap;

  const CalendarEventCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.startTime,
    required this.endTime,
    this.instructorName,
    this.isLive = false,
    required this.subject,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<CalendarEventCard> createState() => _CalendarEventCardState();
}

class _CalendarEventCardState extends State<CalendarEventCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semanticLabel = '${widget.isLive ? "Live class" : "Class"}, '
        '${widget.title}, subject ${widget.subject}, '
        '${widget.subtitle ?? ""}, from ${widget.startTime} to ${widget.endTime}'
        '${widget.instructorName != null ? ", instructor ${widget.instructorName!}" : ""}. Double tap to open details.';

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? widget.colorScheme.accent.withOpacity(0.15) : widget.colorScheme.background,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: (_) => setState(() => _scale = 0.985),
                  onTapUp: (_) => setState(() => _scale = 1.0),
                  onTapCancel: () => setState(() => _scale = 1.0),
                  splashColor: widget.colorScheme.accent.withOpacity(0.08),
                  highlightColor: widget.colorScheme.accent.withOpacity(0.02),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── 1. Time display block ──
                        EventTimeColumn(
                          startTime: widget.startTime,
                          endTime: widget.endTime,
                        ),
                        const SizedBox(width: 14),

                        // ── 2. Low-opacity vertical line divider ──
                        Container(
                          width: 1.5,
                          height: 60,
                          color: widget.colorScheme.accent.withOpacity(0.2),
                        ),
                        const SizedBox(width: 14),

                        // ── 3. Subject Icon Avatar ──
                        EventSubjectIcon(
                          subject: widget.subject,
                          tintColor: widget.colorScheme.accent,
                        ),
                        const SizedBox(width: 16),

                        // ── 4. Main event details column ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Live indicator pill above/beside title
                              if (widget.isLive) ...[
                                const LiveEventBadge(),
                                const SizedBox(height: 6),
                              ],
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
                              if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                              if (widget.instructorName != null && widget.instructorName!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 13,
                                      color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF8E95A5),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.instructorName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF8E95A5),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // ── 5. Chevron arrow indicator ──
                        Icon(
                          Icons.chevron_right_rounded,
                          color: widget.colorScheme.accent,
                          size: 24,
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
