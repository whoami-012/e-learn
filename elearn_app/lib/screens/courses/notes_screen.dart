import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../models/note.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/note_provider.dart';
import 'pdf_viewer_screen.dart';

class NotesScreen extends StatefulWidget {
  final String courseId;

  const NotesScreen({super.key, required this.courseId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().fetchNotes(widget.courseId);
    });
  }

  bool _isPdf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.path.toLowerCase().endsWith('.pdf');
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    String finalUrl = urlString;
    // Prepend server base URL if it's a relative path
    if (finalUrl.startsWith('/')) {
       finalUrl = '${AppConstants.serverBase}$finalUrl';
    }

    final uri = Uri.tryParse(finalUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch document: $e')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid file URL.')),
        );
      }
    }
  }

  void _showNoteContent(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Text(note.content ?? 'No content available.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = context.watch<EnrollmentProvider>();
    final isEnrolled = enrollmentProvider.isEnrolled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Resources'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () =>
                        provider.fetchNotes(widget.courseId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notes.isEmpty) {
            return const Center(child: Text('No notes available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              final isLocked = !note.isFree && !isEnrolled;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isLocked
                        ? Colors.grey.shade100
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      isLocked
                          ? Icons.lock_rounded
                          : (note.fileUrl != null
                              ? Icons.picture_as_pdf_rounded
                              : Icons.text_snippet_rounded),
                      color: isLocked
                          ? Colors.grey.shade500
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    note.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    isLocked
                        ? 'Buy course to unlock'
                        : (note.isFree ? 'Free Preview' : 'Enrollment Access'),
                    style: TextStyle(
                      color: isLocked ? Colors.red.shade300 : Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isLocked
                      ? null
                      : Icon(Icons.chevron_right_rounded,
                          color: Colors.grey.shade400),
                  onTap: () {
                    if (isLocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please buy the course to view this note.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (note.fileUrl != null && note.fileUrl!.isNotEmpty) {
                      String finalUrl = note.fileUrl!;
                      if (finalUrl.startsWith('/')) {
                        finalUrl = '${AppConstants.serverBase}$finalUrl';
                      }

                      if (_isPdf(finalUrl)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(
                              title: note.title,
                              pdfUrl: finalUrl,
                            ),
                          ),
                        );
                      } else {
                        // Launch externally for non-PDFs, such as DOCX, Images, etc.
                        _launchUrl(context, note.fileUrl!); // Passing raw fileUrl, _launchUrl adds prefixes
                      }
                    } else {
                      _showNoteContent(context, note);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
