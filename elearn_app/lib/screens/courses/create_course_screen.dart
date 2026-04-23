import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../services/upload_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');

  bool    _isFree        = false;
  XFile?  _pickedImage;         // local file
  String? _uploadedUrl;         // URL returned by backend
  bool    _isUploading   = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose image source',
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
            if (_pickedImage != null)
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red.shade400),
                title: Text('Remove thumbnail',
                    style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _pickedImage = null;
                    _uploadedUrl = null;
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
    if (v == null || v.isEmpty) return 'Enter a price';
    final p = double.tryParse(v);
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

    final data = CourseCreate(
      title:        _titleCtrl.text.trim(),
      description:  _descCtrl.text.trim(),
      price:        _isFree ? 0 : double.parse(_priceCtrl.text.trim()),
      isFree:       _isFree,
      thumbnailUrl: _uploadedUrl,       // null if not uploaded
    );

    final provider = context.read<CourseProvider>();
    final success  = await provider.createCourse(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Course created successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Failed to create course'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color      = Theme.of(context).colorScheme;
    final isCreating = context.watch<CourseProvider>().isCreating;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Course',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Thumbnail picker ───────────────────────────────────────
                _ThumbnailPicker(
                  pickedImage: _pickedImage,
                  isUploading: _isUploading,
                  uploadedUrl: _uploadedUrl,
                  onTap: _showImageSourceSheet,
                  color: color.primary,
                ),

                const SizedBox(height: 20),

                // ── Title ──────────────────────────────────────────────────
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    hintText: 'e.g. Flutter for Beginners',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Description ────────────────────────────────────────────
                TextFormField(
                  controller: _descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.next,
                  validator: _validateDescription,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what students will learn...',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Free toggle ────────────────────────────────────────────
                SwitchListTile(
                  value: _isFree,
                  onChanged: (v) => setState(() => _isFree = v),
                  title: const Text('Free Course',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_isFree
                      ? 'Free for all students'
                      : 'Students must pay to access'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.grey.shade50,
                ),

                const SizedBox(height: 16),

                // ── Price ──────────────────────────────────────────────────
                if (!_isFree)
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: _validatePrice,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      hintText: '499',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                    ),
                  ),

                const SizedBox(height: 32),

                // ── Submit ─────────────────────────────────────────────────
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: (isCreating || _isUploading) ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: (isCreating || _isUploading)
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Create Course'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  Reusable Thumbnail Picker Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailPicker extends StatelessWidget {
  final XFile?  pickedImage;
  final bool    isUploading;
  final String? uploadedUrl;
  final VoidCallback onTap;
  final Color   color;

  const _ThumbnailPicker({
    required this.pickedImage,
    required this.isUploading,
    required this.uploadedUrl,
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
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploadedUrl != null
                ? Colors.green.shade300
                : color.withOpacity(0.3),
            width: uploadedUrl != null ? 2 : 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: isUploading
            // ── Uploading ────────────────────────────────────────────────
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: color),
                  const SizedBox(height: 12),
                  Text('Uploading thumbnail...',
                      style: TextStyle(color: color, fontSize: 13)),
                ],
              )
            : pickedImage != null
                // ── Preview ──────────────────────────────────────────────
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                      // Success overlay
                      if (uploadedUrl != null)
                        Positioned(
                          top: 8, right: 8,
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
                      // Edit icon overlay
                      Positioned(
                        bottom: 8, right: 8,
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
                // ── Empty placeholder ─────────────────────────────────────
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded,
                          size: 40, color: color.withOpacity(0.7)),
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
