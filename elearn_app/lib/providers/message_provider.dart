import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../core/storage/token_storage.dart';
import '../services/message_service.dart';

enum MessageType { mentor, group, announcement, student }

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final MessageType type;
  final String? avatarUrl;
  final String? otherParticipantId;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.type,
    this.avatarUrl,
    this.otherParticipantId,
  });

  Conversation copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    MessageType? type,
    String? avatarUrl,
    String? otherParticipantId,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      otherParticipantId: otherParticipantId ?? this.otherParticipantId,
    );
  }
}

class Attachment {
  final String id;
  final String originalFilename;
  final String mimeType;
  final String fileExtension;
  final int fileSize;
  final String checksum;

  Attachment({
    required this.id,
    required this.originalFilename,
    required this.mimeType,
    required this.fileExtension,
    required this.fileSize,
    required this.checksum,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      originalFilename: json['original_filename'] as String,
      mimeType: json['mime_type'] as String,
      fileExtension: json['file_extension'] as String,
      fileSize: json['file_size'] as int,
      checksum: json['checksum'] as String,
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String type; // 'text', 'file', 'text_with_file'
  final String? content;
  final DateTime createdAt;
  final String? clientMessageId;
  final Attachment? attachment;
  final bool isPending;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    required this.createdAt,
    this.clientMessageId,
    this.attachment,
    this.isPending = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      type: json['message_type'] as String,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      clientMessageId: json['client_message_id'] as String?,
      attachment: json['attachment'] != null
          ? Attachment.fromJson(json['attachment'] as Map<String, dynamic>)
          : null,
      isPending: false,
    );
  }
}

class Contact {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? department;
  final String? sharedCourseName;

  Contact({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.department,
    this.sharedCourseName,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    final sharedCourse = json['shared_course'];
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      department: json['department'] as String?,
      sharedCourseName: sharedCourse != null ? sharedCourse['name'] as String? : null,
    );
  }
}

class MessageProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _totalUnreadCount = 0;

  // Contacts
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  String? _contactsError;

  // Active chat state
  String? _activeConversationId;
  List<Message> _activeMessages = [];
  bool _isLoadingMessages = false;
  String? _messagesError;
  String? _nextCursor;
  bool _hasMoreMessages = true;

  // WebSocket
  WebSocket? _webSocket;
  bool _isWebSocketConnected = false;
  Timer? _reconnectTimer;
  bool _disposed = false;

  // Getters
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get totalUnreadCount => _totalUnreadCount;

  List<Contact> get contacts => _contacts;
  bool get isLoadingContacts => _isLoadingContacts;
  String? get contactsError => _contactsError;

  String? get activeConversationId => _activeConversationId;
  List<Message> get activeMessages => _activeMessages;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get messagesError => _messagesError;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isWebSocketConnected => _isWebSocketConnected;

  MessageProvider() {
    refresh();
    initializeWebSocket();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    disconnectWebSocket();
    super.dispose();
  }

  // ── WebSocket Management ───────────────────────────────────────────────────

  Future<void> initializeWebSocket() async {
    if (_webSocket != null || _disposed) return;

    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      _scheduleReconnect();
      return;
    }

    try {
      final wsUrl = '${AppConstants.wsUrl}?token=$token';
      _webSocket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));
      _isWebSocketConnected = true;
      _isOffline = false;
      notifyListeners();

      // Subscribe to all currently loaded conversations
      for (final conv in _conversations) {
        _subscribeToConversation(conv.id);
      }

      // If there is an active conversation, subscribe to it too
      if (_activeConversationId != null) {
        _subscribeToConversation(_activeConversationId!);
      }

      _webSocket!.listen(
        (data) {
          if (data is String) {
            _handleWebSocketMessage(data);
          }
        },
        onDone: () {
          _handleWSDisconnect();
        },
        onError: (err) {
          _handleWSDisconnect();
        },
      );
    } catch (_) {
      _handleWSDisconnect();
    }
  }

  void _handleWSDisconnect() {
    _webSocket = null;
    _isWebSocketConnected = false;
    _scheduleReconnect();
    notifyListeners();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_disposed) return;
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      initializeWebSocket();
    });
  }

  void disconnectWebSocket() {
    _webSocket?.close();
    _webSocket = null;
    _isWebSocketConnected = false;
  }

  void _subscribeToConversation(String conversationId) {
    if (_webSocket == null || !_isWebSocketConnected) return;
    final event = {
      'event': 'subscribe',
      'conversation_id': conversationId,
    };
    _webSocket!.add(jsonEncode(event));
  }

  void _handleWebSocketMessage(String rawJson) {
    try {
      final eventData = jsonDecode(rawJson) as Map<String, dynamic>;
      final event = eventData['event'] as String?;

      if (event == 'message.created') {
        final messageJson = eventData['data'] as Map<String, dynamic>;
        final message = Message.fromJson(messageJson);

        // Append to active message history if match
        if (message.conversationId == _activeConversationId) {
          // Prevent duplicates (e.g. if we sent via WS/REST and received the broadcast)
          final index = _activeMessages.indexWhere(
              (m) => m.id == message.id || (m.clientMessageId != null && m.clientMessageId == message.clientMessageId));
          if (index != -1) {
            _activeMessages[index] = message;
          } else {
            _activeMessages.add(message);
          }
          // Mark as read in real-time
          markAsRead(message.conversationId);
        }

        // Update the conversations summary list
        final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
        if (convIndex != -1) {
          final conv = _conversations[convIndex];
          final isFromMe = message.senderId != conv.otherParticipantId;
          final updatedUnread = (message.conversationId == _activeConversationId || isFromMe)
              ? conv.unreadCount
              : conv.unreadCount + 1;

          _conversations[convIndex] = conv.copyWith(
            lastMessage: message.content ?? (message.attachment != null ? 'Attachment' : ''),
            timestamp: message.createdAt,
            unreadCount: updatedUnread,
          );
        } else {
          // If conversation is not in the list, fetch the updated list
          refresh();
        }
        notifyListeners();
      } else if (event == 'message.read') {
        final convId = eventData['conversation_id'] as String?;
        final userId = eventData['user_id'] as String?;
        if (convId != null) {
          final convIndex = _conversations.indexWhere((c) => c.id == convId);
          if (convIndex != -1) {
            _conversations[convIndex] = _conversations[convIndex].copyWith(unreadCount: 0);
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  // ── Conversation Actions ───────────────────────────────────────────────────

  List<Conversation> get filteredConversations {
    return _conversations.where((conv) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = conv.name.toLowerCase().contains(query);
        final msgMatch = conv.lastMessage.toLowerCase().contains(query);
        if (!nameMatch && !msgMatch) return false;
      }

      if (_selectedFilter == 'Mentors') {
        return conv.type == MessageType.mentor;
      } else if (_selectedFilter == 'Announcements') {
        return conv.type == MessageType.announcement;
      } else if (_selectedFilter == 'Groups') {
        return conv.type == MessageType.group;
      }

      return true;
    }).toList();
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await MessageService.listConversations();
      final items = res['items'] as List?;
      final nextCursor = res['next_cursor'] as String?;

      if (items != null) {
        _conversations = items.map((json) {
          final p = json['participant'] as Map<String, dynamic>;
          final lastMsg = json['last_message'] as Map<String, dynamic>?;
          final role = p['role'] as String? ?? 'student';

          final type = (role == 'faculty' || role == 'teacher')
              ? MessageType.mentor
              : MessageType.student;

          return Conversation(
            id: json['id'] as String,
            name: p['name'] as String,
            lastMessage: lastMsg != null ? lastMsg['preview'] as String : '',
            timestamp: DateTime.parse(json['updated_at'] as String).toLocal(),
            unreadCount: json['unread_count'] as int? ?? 0,
            type: type,
            avatarUrl: p['avatar_url'] as String?,
            otherParticipantId: p['id'] as String?,
          );
        }).toList();

        // Subscribe to conversations on WS
        for (final conv in _conversations) {
          _subscribeToConversation(conv.id);
        }
      }

      _totalUnreadCount = await MessageService.getUnreadCount();
      _isOffline = false;
    } catch (e) {
      _error = e.toString();
      _isOffline = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _conversations.indexWhere((c) => c.id == id);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      notifyListeners();
    }

    try {
      // Find last message to mark read
      if (_activeConversationId == id && _activeMessages.isNotEmpty) {
        final lastMsg = _activeMessages.last;
        
        // WS read event is faster & preferred
        if (_webSocket != null && _isWebSocketConnected) {
          final event = {
            'event': 'mark_read',
            'conversation_id': id,
            'last_read_message_id': lastMsg.id,
          };
          _webSocket!.add(jsonEncode(event));
        } else {
          await MessageService.markRead(id, lastMsg.id);
        }
      }
    } catch (_) {}
  }

  // ── Contacts Actions ───────────────────────────────────────────────────────

  Future<void> loadContacts({String? search}) async {
    _isLoadingContacts = true;
    _contactsError = null;
    notifyListeners();

    try {
      final res = await MessageService.getContacts(search: search);
      final items = res['items'] as List?;
      if (items != null) {
        _contacts = items.map((json) => Contact.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _contactsError = e.toString();
    } finally {
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  Future<String> startOrGetConversation(String receiverId) async {
    try {
      final res = await MessageService.startConversation(receiverId);
      final conversationId = res['id'] as String;
      await refresh();
      return conversationId;
    } catch (_) {
      rethrow;
    }
  }

  // ── Chat Detail Actions ────────────────────────────────────────────────────

  Future<void> openConversation(String conversationId) async {
    _activeConversationId = conversationId;
    _activeMessages = [];
    _isLoadingMessages = true;
    _messagesError = null;
    _nextCursor = null;
    _hasMoreMessages = true;
    notifyListeners();

    _subscribeToConversation(conversationId);

    try {
      final res = await MessageService.listMessages(conversationId);
      final items = res['items'] as List?;
      _nextCursor = res['next_cursor'] as String?;

      if (items != null) {
        _activeMessages = items.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
      }
      _hasMoreMessages = _nextCursor != null;

      // Mark read
      await markAsRead(conversationId);
    } catch (e) {
      _messagesError = e.toString();
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMessages() async {
    if (_activeConversationId == null || _isLoadingMessages || !_hasMoreMessages || _nextCursor == null) {
      return;
    }

    try {
      final res = await MessageService.listMessages(_activeConversationId!, cursor: _nextCursor);
      final items = res['items'] as List?;
      _nextCursor = res['next_cursor'] as String?;

      if (items != null && items.isNotEmpty) {
        final newMsgs = items.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
        _activeMessages.insertAll(0, newMsgs);
      }
      _hasMoreMessages = _nextCursor != null;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> sendTextMessage(String content, String currentUserId) async {
    if (_activeConversationId == null || content.trim().isEmpty) return;

    final clientMessageId = DateTime.now().microsecondsSinceEpoch.toString();
    final tempMsg = Message(
      id: clientMessageId,
      conversationId: _activeConversationId!,
      senderId: currentUserId,
      type: 'text',
      content: content,
      createdAt: DateTime.now(),
      clientMessageId: clientMessageId,
      isPending: true,
    );

    _activeMessages.add(tempMsg);
    notifyListeners();

    try {
      Map<String, dynamic> res;
      // Send via WS if connected, else fallback to REST API
      if (_webSocket != null && _isWebSocketConnected) {
        final event = {
          'event': 'send_message',
          'conversation_id': _activeConversationId!,
          'content': content,
          'client_message_id': clientMessageId,
        };
        _webSocket!.add(jsonEncode(event));
        // We will replace the tempMsg when the WS message.created broadcast arrives.
        return;
      } else {
        res = await MessageService.sendMessage(_activeConversationId!, content, clientMessageId);
      }

      final confirmedMsg = Message.fromJson(res);
      final index = _activeMessages.indexWhere((m) => m.clientMessageId == clientMessageId);
      if (index != -1) {
        _activeMessages[index] = confirmedMsg;
      }

      // Update local conversation summary
      final convIndex = _conversations.indexWhere((c) => c.id == _activeConversationId);
      if (convIndex != -1) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          lastMessage: content,
          timestamp: confirmedMsg.createdAt,
        );
      }
      notifyListeners();
    } catch (_) {
      // Mark failed
      final index = _activeMessages.indexWhere((m) => m.clientMessageId == clientMessageId);
      if (index != -1) {
        _activeMessages.removeAt(index);
        notifyListeners();
      }
    }
  }

  Future<void> sendFileMessage(File file, String currentUserId, {String? content}) async {
    if (_activeConversationId == null) return;

    final clientMessageId = DateTime.now().microsecondsSinceEpoch.toString();
    final filename = file.path.split(Platform.pathSeparator).last;
    final tempMsg = Message(
      id: clientMessageId,
      conversationId: _activeConversationId!,
      senderId: currentUserId,
      type: 'file',
      content: content ?? filename,
      createdAt: DateTime.now(),
      clientMessageId: clientMessageId,
      isPending: true,
    );

    _activeMessages.add(tempMsg);
    notifyListeners();

    try {
      final res = await MessageService.sendMessageUpload(
        conversationId: _activeConversationId!,
        file: file,
        content: content,
        clientMessageId: clientMessageId,
      );

      final confirmedMsg = Message.fromJson(res);
      final index = _activeMessages.indexWhere((m) => m.clientMessageId == clientMessageId);
      if (index != -1) {
        _activeMessages[index] = confirmedMsg;
      }

      // Update local conversation summary
      final convIndex = _conversations.indexWhere((c) => c.id == _activeConversationId);
      if (convIndex != -1) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          lastMessage: confirmedMsg.content ?? 'Attachment',
          timestamp: confirmedMsg.createdAt,
        );
      }
      notifyListeners();
    } catch (_) {
      final index = _activeMessages.indexWhere((m) => m.clientMessageId == clientMessageId);
      if (index != -1) {
        _activeMessages.removeAt(index);
        notifyListeners();
      }
    }
  }

  // ── Attachment Downloads ───────────────────────────────────────────────────

  Future<String> downloadAttachmentFile(Attachment attachment) async {
    try {
      final res = await MessageService.downloadAttachment(attachment.id);
      if (res.statusCode != 200) {
        throw Exception('Download failed with status: ${res.statusCode}');
      }

      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/${attachment.originalFilename}';
      final file = File(localPath);
      await file.writeAsBytes(res.bodyBytes);
      return localPath;
    } catch (e) {
      throw Exception('Could not save attachment: ${e.toString()}');
    }
  }
}
