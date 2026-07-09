import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/message_provider.dart';
import '../../theme/app_theme.dart';
import 'chat_detail_screen.dart';

class ContactSelectScreen extends StatefulWidget {
  const ContactSelectScreen({super.key});

  @override
  State<ContactSelectScreen> createState() => _ContactSelectScreenState();
}

class _ContactSelectScreenState extends State<ContactSelectScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
    });
    context.read<MessageProvider>().loadContacts(search: val);
  }

  Color _getPastelColor(String name) {
    final hash = name.hashCode;
    final List<Color> pastelColors = [
      const Color(0xFFFFE5EC),
      const Color(0xFFECE8FF),
      const Color(0xFFE2F1FF),
      const Color(0xFFE2F7EF),
      const Color(0xFFFFF2E2),
    ];
    return pastelColors[hash.abs() % pastelColors.length];
  }

  Color _getAccentColor(String name) {
    final hash = name.hashCode;
    final List<Color> accentColors = [
      const Color(0xFFFF4B72),
      const Color(0xFF6C45D8),
      const Color(0xFF2D7CEB),
      const Color(0xFF219653),
      const Color(0xFFD48D2A),
    ];
    return accentColors[hash.abs() % accentColors.length];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  Future<void> _startChat(Contact contact) async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    try {
      final provider = context.read<MessageProvider>();
      final conversationId = await provider.startOrGetConversation(contact.id);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            conversationId: conversationId,
            participantName: contact.name,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start chat: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final contacts = provider.contacts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Message',
          style: TextStyle(
            color: Color(0xFF101936),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1FD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8E95A5),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF101936),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search contacts...',
                            hintStyle: TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF8E95A5),
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Contacts List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (provider.isLoadingContacts) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (provider.contactsError != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            provider.contactsError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (contacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3EFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_outline_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No contacts found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101936),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 48.0),
                              child: Text(
                                'You can only message teachers or students sharing your courses.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF6F7588),
                                  height: 1.35,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xFFE9EBF2).withValues(alpha: 0.5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final initials = _getInitials(contact.name);
                        final bgColor = _getPastelColor(contact.name);
                        final textColor = _getAccentColor(contact.name);

                        return ListTile(
                          onTap: () => _startChat(contact),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(contact.avatarUrl!),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                          title: Row(
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  color: Color(0xFF101936),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: contact.role == 'faculty' || contact.role == 'teacher'
                                      ? const Color(0xFFF3EFFF)
                                      : const Color(0xFFE2F1FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contact.role.toUpperCase(),
                                  style: TextStyle(
                                    color: contact.role == 'faculty' || contact.role == 'teacher'
                                        ? AppColors.primary
                                        : const Color(0xFF2D7CEB),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              contact.sharedCourseName != null
                                  ? 'Course: ${contact.sharedCourseName}'
                                  : (contact.department ?? ''),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6F7588),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isStarting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
