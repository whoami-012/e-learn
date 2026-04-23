/// note.dart — Dart model for Notes.
library;

class Note {
  final String id;
  final String title;
  final String? content;
  final String? fileUrl;
  final bool isFree;

  const Note({
    required this.id,
    required this.title,
    this.content,
    this.fileUrl,
    required this.isFree,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String?,
        fileUrl: json['file_url'] as String?,
        isFree: json['is_free'] as bool? ?? false,
      );
}
