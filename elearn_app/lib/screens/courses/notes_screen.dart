import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../models/note.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/note_provider.dart';
import 'pdf_viewer_screen.dart';
import '../../theme/app_theme.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Course Materials'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(provider.error!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => provider.fetchNotes(widget.courseId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_open_rounded, size: 52, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No resources available',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'No notes or documents have been added to this course yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: provider.notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              final isLocked = !note.isFree && !isEnrolled;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
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
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Left Icon indicator
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isLocked ? AppColors.surfaceMuted : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: Icon(
                            isLocked
                                ? Icons.lock_rounded
                                : (note.fileUrl != null
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.text_snippet_rounded),
                            color: isLocked ? AppColors.textSecondary : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Note Title & Lock description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLocked
                                    ? 'Purchase course to unlock'
                                    : (note.isFree ? 'Free Preview' : 'Enrollment Access'),
                                style: TextStyle(
                                  color: isLocked ? AppColors.error : Colors.green.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLocked)
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
