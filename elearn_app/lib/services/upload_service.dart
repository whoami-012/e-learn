/// upload_service.dart — Handles image picking and multipart upload to the backend.
library;

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';


import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/storage/token_storage.dart';

class UploadService {
  static final _picker = ImagePicker();

  // ── Pick image from gallery ─────────────────────────────────────────────────

  /// Opens the device image gallery. Returns the selected [XFile] or null
  /// if the user cancelled.
  static Future<XFile?> pickImageFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 800,
    );
  }

  /// Opens the device camera. Returns the selected [XFile] or null.
  static Future<XFile?> pickImageFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 800,
    );
  }

  // ── Upload to backend ───────────────────────────────────────────────────────

  /// Uploads [imageFile] as a multipart POST to /api/v1/upload/thumbnail.
  ///
  /// Returns the public URL string (e.g. '/static/thumbnails/abc.jpg').
  ///
  /// Requires a valid JWT access token (faculty/admin only).
  static Future<String> uploadThumbnail(XFile imageFile) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw const InvalidCredentialsException();

    try {
      final uri     = Uri.parse(AppConstants.uploadThumbnailEndpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(_mimeType(imageFile.path)),
      ));


      final streamed = await request.send();
      final body     = await streamed.stream.bytesToString();
      final json     = jsonDecode(body) as Map<String, dynamic>;

      switch (streamed.statusCode) {
        case 200:
        case 201:
          return json['url'] as String;
        case 401:
          throw const InvalidCredentialsException();
        case 403:
          throw ServerException(403, 'Only faculty/admin can upload thumbnails.');
        case 400:
          throw ServerException(
              400, (json['detail'] as String?) ?? 'Invalid file.');
        default:
          throw ServerException(
              streamed.statusCode,
              (json['detail'] as String?) ?? 'Upload failed.');
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Maps a file path extension to the correct MIME type string.
  /// Ensures Android .jpg files send 'image/jpeg' not 'application/octet-stream'.
  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // safe fallback
    }
  }
}
