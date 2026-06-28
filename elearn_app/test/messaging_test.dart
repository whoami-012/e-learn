import 'package:flutter_test/flutter_test.dart';
import 'package:elearn_app/providers/message_provider.dart';

void main() {
  group('Messaging Models Parsing Tests', () {
    test('Contact.fromJson parses student and faculty role details correctly', () {
      final json = {
        'id': 'contact-uuid-1',
        'name': 'Prof. Albus Dumbledore',
        'role': 'faculty',
        'avatar_url': 'https://example.com/avatar.jpg',
        'department': 'Transfiguration',
        'shared_course': {
          'id': 'course-uuid-1',
          'name': 'Defense Against the Dark Arts',
        }
      };

      final contact = Contact.fromJson(json);

      expect(contact.id, 'contact-uuid-1');
      expect(contact.name, 'Prof. Albus Dumbledore');
      expect(contact.role, 'faculty');
      expect(contact.avatarUrl, 'https://example.com/avatar.jpg');
      expect(contact.department, 'Transfiguration');
      expect(contact.sharedCourseName, 'Defense Against the Dark Arts');
    });

    test('Attachment.fromJson parses file information correctly', () {
      final json = {
        'id': 'attachment-uuid-1',
        'original_filename': 'lecture_notes.pdf',
        'mime_type': 'application/pdf',
        'file_extension': 'pdf',
        'file_size': 1048576,
        'checksum': 'md5-checksum-here',
      };

      final attachment = Attachment.fromJson(json);

      expect(attachment.id, 'attachment-uuid-1');
      expect(attachment.originalFilename, 'lecture_notes.pdf');
      expect(attachment.mimeType, 'application/pdf');
      expect(attachment.fileExtension, 'pdf');
      expect(attachment.fileSize, 1048576);
      expect(attachment.checksum, 'md5-checksum-here');
    });

    test('Message.fromJson parses text message correctly', () {
      final json = {
        'id': 'message-uuid-1',
        'conversation_id': 'conv-uuid-1',
        'sender_id': 'sender-uuid-1',
        'message_type': 'text',
        'content': 'Hello, Harry!',
        'created_at': '2026-06-27T12:00:00Z',
        'client_message_id': 'client-msg-id-1',
        'attachment': null,
      };

      final message = Message.fromJson(json);

      expect(message.id, 'message-uuid-1');
      expect(message.conversationId, 'conv-uuid-1');
      expect(message.senderId, 'sender-uuid-1');
      expect(message.type, 'text');
      expect(message.content, 'Hello, Harry!');
      expect(message.createdAt.isUtc, isFalse); // toLocal converts it to local timezone
      expect(message.clientMessageId, 'client-msg-id-1');
      expect(message.attachment, isNull);
    });

    test('Message.fromJson parses file message correctly', () {
      final json = {
        'id': 'message-uuid-2',
        'conversation_id': 'conv-uuid-1',
        'sender_id': 'sender-uuid-1',
        'message_type': 'file',
        'content': 'Check this assignment',
        'created_at': '2026-06-27T13:00:00Z',
        'client_message_id': 'client-msg-id-2',
        'attachment': {
          'id': 'attachment-uuid-2',
          'original_filename': 'assignment.docx',
          'mime_type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'file_extension': 'docx',
          'file_size': 20480,
          'checksum': 'another-checksum',
        },
      };

      final message = Message.fromJson(json);

      expect(message.id, 'message-uuid-2');
      expect(message.conversationId, 'conv-uuid-1');
      expect(message.senderId, 'sender-uuid-1');
      expect(message.type, 'file');
      expect(message.content, 'Check this assignment');
      expect(message.clientMessageId, 'client-msg-id-2');
      expect(message.attachment, isNotNull);
      expect(message.attachment!.originalFilename, 'assignment.docx');
    });
  });
}
