import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/video_player_widget.dart';

class LessonPlayerScreen extends StatefulWidget {
  final List<Lesson> lessons;
  final int initialIndex;
  final bool isEnrolled;

  const LessonPlayerScreen({
    required this.lessons,
    this.initialIndex = 0,
    this.isEnrolled = false,
    super.key,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onLessonSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = widget.lessons[_currentIndex];
    final bool isLocked = !widget.isEnrolled && !currentLesson.isPreview;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Course Player",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Video Player Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: VideoPlayerWidget(
              // ValueKey forces Flutter to fully dispose → recreate the widget
              // (and its controller) when the lesson changes, instead of the
              // didUpdateWidget path which can leave stale WebView references.
              key: ValueKey(currentLesson.videoId),
              videoId: currentLesson.videoId,
              isLocked: isLocked,
            ),
          ),

          // 2. Lesson Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentLesson.isPreview 
                            ? const Color(0xFFDCFCE7) 
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentLesson.isPreview ? "FREE PREVIEW" : "LESSON ${currentLesson.orderIndex + 1}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: currentLesson.isPreview 
                              ? const Color(0xFF166534) 
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentLesson.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Pre-recorded session",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 3. Playlist / Navigation
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.separated(
                itemCount: widget.lessons.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final lesson = widget.lessons[index];
                  final isCurrent = index == _currentIndex;
                  final isLessonLocked = !widget.isEnrolled && !lesson.isPreview;

                  return ListTile(
                    selected: isCurrent,
                    selectedTileColor: const Color(0xFFEFF6FF),
                    onTap: () => _onLessonSelected(index),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isCurrent ? Icons.play_arrow_rounded : Icons.play_arrow_outlined,
                          size: 18,
                          color: isCurrent ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    title: Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      "Lesson ${lesson.orderIndex + 1}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    trailing: isLessonLocked 
                        ? const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFCBD5E1))
                        : (lesson.isPreview 
                            ? const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF22C55E))
                            : null),
                  );
                },
              ),
            ),
          ),
          
          // 4. Bottom Controls (Previous / Next)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentIndex > 0 
                        ? () => _onLessonSelected(_currentIndex - 1) 
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Previous", style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentIndex < widget.lessons.length - 1 
                        ? () => _onLessonSelected(_currentIndex + 1) 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Next Lesson", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
