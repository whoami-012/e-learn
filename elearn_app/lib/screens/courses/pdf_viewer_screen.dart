import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/storage/token_storage.dart';

import '../../theme/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    final token = await TokenStorage.getAccessToken();
    if (mounted) {
      setState(() {
        _token = token;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfPdfViewer.network(
              widget.pdfUrl,
              key: _pdfViewerKey,
              headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                debugPrint('PDF Loaded. Total pages: ${details.document.pages.count}');
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load PDF: ${details.error}')),
                  );
                }
              },
            ),
    );
  }
}
