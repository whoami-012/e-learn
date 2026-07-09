import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../services/upload_service.dart';
import '../../core/constants/app_constants.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;

  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;

  bool _isFree = false;
  bool _initialized = false;
  XFile? _pickedImage; // newly picked local file
  String? _currentThumbnailUrl; // existing URL from backend
  String? _uploadedUrl; // URL after new upload
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _priceCtrl = TextEditingController();

    debugPrint('[EditCourseScreen] courseId received: ${widget.courseId}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourseById(widget.courseId);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _prefillForm(Course course) {
    if (_initialized) return;
    _initialized = true;
    _titleCtrl.text = course.title;
    _descCtrl.text = course.description;
    _priceCtrl.text = course.price.toStringAsFixed(0);
    _currentThumbnailUrl = course.thumbnailUrl;
    setState(() => _isFree = course.isFree);
    debugPrint(
        '[EditCourseScreen] Pre-filled, thumbnailUrl: $_currentThumbnailUrl');
  }

  // ── Thumbnail picker ────────────────────────────────────────────────────────

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = source == ImageSource.gallery
        ? await UploadService.pickImageFromGallery()
        : await UploadService.pickImageFromCamera();

    if (picked == null || !mounted) return;

    setState(() {
      _pickedImage = picked;
      _isUploading = true;
    });

    try {
      final url = await UploadService.uploadThumbnail(picked);
      if (!mounted) return;
      setState(() => _uploadedUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Upload failed: ${e.toString()}'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ));
      setState(() => _pickedImage = null);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change thumbnail',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            if (_pickedImage != null || _currentThumbnailUrl != null)
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red.shade400),
                title: Text('Remove thumbnail',
                    style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _pickedImage = null;
                    _uploadedUrl = null;
                    _currentThumbnailUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validateTitle(String? v) {
    if (v == null || v.trim().length < 3) return 'Min. 3 characters';
    return null;
  }

  String? _validateDescription(String? v) {
    if (v == null || v.trim().length < 10) return 'Min. 10 characters';
    return null;
  }

  String? _validatePrice(String? v) {
    if (_isFree) return null;
    final p = double.tryParse(v ?? '');
    if (p == null || p < 0) return 'Enter a valid price (≥ 0)';
    return null;
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please wait, thumbnail is still uploading...')));
      return;
    }

    // Use newly uploaded URL, or the existing one, or null (removed)
    final thumbnailUrl = _uploadedUrl ?? _currentThumbnailUrl;

    final data = CourseUpdate(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: _isFree ? 0 : double.parse(_priceCtrl.text.trim()),
      isFree: _isFree,
      thumbnailUrl: thumbnailUrl,
    );

    final provider = context.read<CourseProvider>();
    final success = await provider.updateCourse(widget.courseId, data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Course updated successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Failed to update course'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Course',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedCourse == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Could not load course data.'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => provider.fetchCourseById(widget.courseId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          _prefillForm(provider.selectedCourse!);

          final isSubmitting = provider.isCreating;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Thumbnail picker ─────────────────────────────────
                    _EditThumbnailPicker(
                      pickedImage: _pickedImage,
                      isUploading: _isUploading,
                      uploadedUrl: _uploadedUrl,
                      currentThumbnailUrl: _currentThumbnailUrl,
                      onTap: _showImageSourceSheet,
                      color: color.primary,
                    ),

                    const SizedBox(height: 20),

                    // ── Title ────────────────────────────────────────────
                    TextFormField(
                      controller: _titleCtrl,
                      textInputAction: TextInputAction.next,
                      validator: _validateTitle,
                      decoration: const InputDecoration(
                        labelText: 'Course Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Description ──────────────────────────────────────
                    TextFormField(
                      controller: _descCtrl,
                      minLines: 3,
                      maxLines: 6,
                      textInputAction: TextInputAction.next,
                      validator: _validateDescription,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Free toggle ──────────────────────────────────────
                    SwitchListTile(
                      value: _isFree,
                      onChanged: (v) => setState(() => _isFree = v),
                      title: const Text('Free Course',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(_isFree
                          ? 'Free for all students'
                          : 'Paid access required'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.grey.shade50,
                    ),

                    const SizedBox(height: 16),

                    if (!_isFree)
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: _validatePrice,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // ── Save ─────────────────────────────────────────────
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed:
                            (isSubmitting || _isUploading) ? null : _submit,
                        icon: (isSubmitting || _isUploading)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(isSubmitting
                            ? 'Saving...'
                            : _isUploading
                                ? 'Uploading...'
                                : 'Save Changes'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Edit Thumbnail Picker — shows existing URL or new picked image
// ─────────────────────────────────────────────────────────────────────────────

class _EditThumbnailPicker extends StatelessWidget {
  final XFile? pickedImage;
  final bool isUploading;
  final String? uploadedUrl;
  final String? currentThumbnailUrl;
  final VoidCallback onTap;
  final Color color;

  const _EditThumbnailPicker({
    required this.pickedImage,
    required this.isUploading,
    required this.uploadedUrl,
    required this.currentThumbnailUrl,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploadedUrl != null
                ? Colors.green.shade300
                : color.withValues(alpha: 0.3),
            width: uploadedUrl != null ? 2 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: isUploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: color),
                  const SizedBox(height: 12),
                  Text('Uploading...', style: TextStyle(color: color)),
                ],
              )
            : pickedImage != null
                // Newly picked local image
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                      if (uploadedUrl != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Uploaded',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  )
                : currentThumbnailUrl != null
                    // Existing network thumbnail
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            // Strip the relative path prefix if needed
                            currentThumbnailUrl!.startsWith('http')
                                ? currentThumbnailUrl!
                                : '${AppConstants.serverBase}$currentThumbnailUrl',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.grey.shade300,
                              size: 40,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      )
                    // No image
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              size: 40, color: color.withValues(alpha: 0.7)),
                          const SizedBox(height: 8),
                          Text('Add Thumbnail',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('JPEG · PNG · WebP · Max 5 MB',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
      ),
    );
  }
}
