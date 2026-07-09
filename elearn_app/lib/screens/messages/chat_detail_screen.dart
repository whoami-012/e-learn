import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/message_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/token_storage.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String participantName;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isSendingFile = false;
  final Set<String> _downloadingIds = {};
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    TokenStorage.getAccessToken().then((token) {
      if (mounted) setState(() => _accessToken = token);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().openConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      context.read<MessageProvider>().loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    // Use postFrameCallback so the scroll always happens AFTER the ListView
    // has rebuilt with the new message — fixing the "last message not shown" race.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // ListView is reversed: 0 is the bottom (newest messages)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id;

    if (currentUserId != null) {
      final send =
          context.read<MessageProvider>().sendTextMessage(text, currentUserId);
      _scrollToBottom();
      await send;
    }
  }

  Future<void> _pickAndSendFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
            const Text(
              'Send Attachment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (picked != null) _uploadFile(File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await _picker.pickImage(source: ImageSource.camera);
                if (picked != null) _uploadFile(File(picked.path));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam_rounded, color: AppColors.primary),
              title: const Text('Video'),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await _picker.pickVideo(source: ImageSource.gallery);
                if (picked != null) _uploadFile(File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_rounded,
                  color: AppColors.primary),
              title: const Text('Document'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: const [
                    'pdf',
                    'doc',
                    'docx',
                    'xls',
                    'xlsx',
                    'txt',
                    'zip'
                  ],
                );
                final path = result?.files.single.path;
                if (path != null) _uploadFile(File(path));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(File file) async {
    setState(() => _isSendingFile = true);
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id;

    try {
      if (currentUserId != null) {
        final send = context
            .read<MessageProvider>()
            .sendFileMessage(file, currentUserId);
        _scrollToBottom();
        await send;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File send failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingFile = false);
    }
  }

  Future<void> _downloadAttachment(Attachment attachment) async {
    if (_downloadingIds.contains(attachment.id)) return;

    setState(() {
      _downloadingIds.add(attachment.id);
    });

    try {
      final localPath = await context
          .read<MessageProvider>()
          .downloadAttachmentFile(attachment);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Downloaded successfully!\nPath: $localPath'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(attachment.id);
        });
      }
    }
  }

  Future<void> _openVideoAttachment(Attachment attachment) async {
    final localPath = await context
        .read<MessageProvider>()
        .downloadAttachmentFile(attachment);
    final opened = await launchUrl(
      Uri.file(localPath),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video player is available.')),
      );
    }
  }

  String _absoluteMediaUrl(String? value, String attachmentId) {
    final raw =
        value ?? '${AppConstants.messagesAttachmentEndpoint}/$attachmentId';
    final uri = Uri.parse(raw);
    return uri.hasScheme ? raw : '${AppConstants.serverBase}$raw';
  }

  void _openImagePreview(Attachment attachment) {
    final imageUrl = _absoluteMediaUrl(attachment.attachmentUrl, attachment.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                headers: _authHeaders(),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUserId = userProvider.user?.id;

    final messages = provider.activeMessages;
    final isWSConnected = provider.isWebSocketConnected;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF101936),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.participantName,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101936),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isWSConnected ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isWSConnected ? 'Connected' : 'Connecting...',
                  style: TextStyle(
                    color: isWSConnected
                        ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                        : (isDark
                            ? Colors.orangeAccent
                            : Colors.orange.shade800),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Message History List
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoadingMessages) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.messagesError != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        provider.messagesError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF3EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF101936),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send a message to start this conversation.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF6F7588),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Show newest at the bottom
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  itemCount:
                      messages.length + (provider.hasMoreMessages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }

                    // Since list is reversed, index 0 is the newest message
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == currentUserId;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          if (_isSendingFile)
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Uploading attachment...',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickAndSendFile,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF3F1FD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(
                            fontSize: 14.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF101936)),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF8E95A5),
                              fontSize: 14.5),
                          border: InputBorder.none,
                          isDense: true,
                          fillColor: Colors.transparent,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns true for MIME types that should be shown as an inline image.
  bool _isImage(String? mime) {
    if (mime == null) return false;
    return mime.startsWith('image/');
  }

  /// Returns true for MIME types that should be shown as a video thumbnail.
  bool _isVideo(String? mime) {
    if (mime == null) return false;
    return mime.startsWith('video/');
  }

  // ── Detect local-file type by extension (for pending messages) ──────────────
  bool _isImagePath(String? path) {
    if (path == null) return false;
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
  }

  bool _isVideoPath(String? path) {
    if (path == null) return false;
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext);
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAttachment = message.attachment != null;
    final isDownloading =
        hasAttachment && _downloadingIds.contains(message.attachment!.id);

    // Determine media type
    final attachMime = message.attachment?.mimeType;
    final isImageAttach =
        message.attachment?.attachmentType == 'image' || _isImage(attachMime);
    final isVideoAttach =
        message.attachment?.attachmentType == 'video' || _isVideo(attachMime);
    final isPendingImage =
        message.isPending && _isImagePath(message.localFilePath);
    final isPendingVideo =
        message.isPending && _isVideoPath(message.localFilePath);

    // Build the attachment widget
    Widget? attachWidget;
    if (hasAttachment) {
      if (isImageAttach) {
        // ── Image preview from network ────────────────────────────────────
        final downloadUrl = _absoluteMediaUrl(
          message.attachment!.attachmentUrl,
          message.attachment!.id,
        );
        attachWidget = GestureDetector(
          onTap: () => _openImagePreview(message.attachment!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              downloadUrl,
              width: 220,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      width: 220,
                      height: 160,
                      color: isMe
                          ? const Color(0xFF5331B2)
                          : (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF3F1FD)),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => _fileDownloadTile(
                message: message,
                isMe: isMe,
                isDark: isDark,
                isDownloading: isDownloading,
              ),
              headers: _authHeaders(),
            ),
          ),
        );
      } else if (isVideoAttach) {
        // ── Video — show a play-button thumbnail ──────────────────────────
        attachWidget = GestureDetector(
          onTap: () => _openVideoAttachment(message.attachment!),
          child: Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFF5331B2)
                  : (isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF3F1FD)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (message.attachment!.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _absoluteMediaUrl(
                        message.attachment!.thumbnailUrl,
                        message.attachment!.id,
                      ),
                      width: 220,
                      height: 140,
                      fit: BoxFit.cover,
                      headers: _authHeaders(),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  )
                else
                  Icon(
                    Icons.videocam_rounded,
                    size: 36,
                    color: isMe
                        ? Colors.white54
                        : AppColors.primary.withValues(alpha: 0.5),
                  ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 30),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Text(
                    message.attachment!.originalFilename,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // ── Generic file download ─────────────────────────────────────────
        attachWidget = _fileDownloadTile(
          message: message,
          isMe: isMe,
          isDark: isDark,
          isDownloading: isDownloading,
        );
      }
    } else if (isPendingImage) {
      // ── Pending: show local image preview ──────────────────────────────
      attachWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(message.localFilePath!),
              width: 220,
              fit: BoxFit.cover,
            ),
            Container(
              width: 220,
              color: Colors.black.withValues(alpha: 0.25),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (isPendingVideo) {
      // ── Pending: show video upload placeholder ────────────────────────
      attachWidget = Container(
        width: 220,
        height: 140,
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF5331B2)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F1FD)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.videocam_rounded, size: 36, color: Colors.white54),
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) const SizedBox(width: 4),
            Flexible(
              child: Container(
                // Remove horizontal padding when showing a media preview
                padding: attachWidget != null &&
                        (isImageAttach ||
                            isVideoAttach ||
                            isPendingImage ||
                            isPendingVideo)
                    ? const EdgeInsets.all(4)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Attachment / media widget
                    if (attachWidget != null) attachWidget,
                    // Caption / text content
                    if (message.content != null &&
                        message.content!.isNotEmpty &&
                        (hasAttachment ||
                            isPendingImage ||
                            isPendingVideo)) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          message.content!,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF101936)),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ] else if (attachWidget == null)
                      // Plain text
                      Text(
                        message.content ?? '',
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF101936)),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Timestamp + tick
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              color: isMe
                                  ? const Color(0xFFB09AFF)
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF8E95A5)),
                              fontSize: 10,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            if (message.isPending)
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white70,
                                ),
                              )
                            else if (message.status == 'failed')
                              GestureDetector(
                                onTap: () => context
                                    .read<MessageProvider>()
                                    .retryMessage(message),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              )
                            else
                              const Icon(
                                Icons.done_all_rounded,
                                color: Colors.white70,
                                size: 13,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Generic file download tile ─────────────────────────────────────────────
  Widget _fileDownloadTile({
    required Message message,
    required bool isMe,
    required bool isDark,
    required bool isDownloading,
  }) {
    final attach = message.attachment;
    return GestureDetector(
      onTap: attach != null ? () => _downloadAttachment(attach) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF5331B2)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F1FD)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDownloading
                  ? Icons.hourglass_empty_rounded
                  : Icons.insert_drive_file_rounded,
              color: isMe ? Colors.white : AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attach?.originalFilename ?? message.fileName ?? 'File',
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF101936)),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attach != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatFileSize(attach.fileSize),
                      style: TextStyle(
                        color: isMe
                            ? const Color(0xFFB09AFF)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF6F7588)),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isDownloading && attach != null)
              Icon(
                Icons.file_download_rounded,
                color: isMe ? Colors.white70 : const Color(0xFF8E95A5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Build headers needed to authenticate image loads.
  Map<String, String> _authHeaders() {
    // Auth token is managed by TokenStorage; we use a FutureBuilder-free approach
    // by returning empty headers here — the Image.network will use the cookie/session.
    // For authenticated image loads add Bearer token via a custom HttpClient if required.
    return _accessToken == null
        ? const {}
        : {'Authorization': 'Bearer $_accessToken'};
  }
}
