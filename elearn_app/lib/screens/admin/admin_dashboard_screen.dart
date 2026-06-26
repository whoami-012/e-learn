import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  void _showRoleDialog(UserProfile user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Role for ${user.name}'),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          items: const [
            DropdownMenuItem(value: 'student', child: Text('Student')),
            DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (val) {
            if (val != null) selectedRole = val;
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<AdminProvider>().updateUserRole(user.id, selectedRole);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role updated successfully')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Consumer<AdminProvider>(
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
                      onPressed: () => provider.fetchUsers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 52, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No users found',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: provider.users.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final user = provider.users[index];
              final role = user.role.toLowerCase();

              // Role chip decoration
              Color chipBg = AppColors.surfaceMuted;
              Color chipText = AppColors.textSecondary;
              if (role == 'admin') {
                chipBg = AppColors.pastelPurple;
                chipText = AppColors.primary;
              } else if (role == 'faculty') {
                chipBg = AppColors.pastelBlue;
                chipText = AppColors.blue;
              } else if (role == 'student') {
                chipBg = AppColors.pastelMint;
                chipText = Colors.green.shade700;
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.avatarGradient,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: chipBg,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(color: chipText, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary),
                        onPressed: () => _showRoleDialog(user),
                        tooltip: 'Change Role',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete User?'),
                              content: Text('This will permanently delete ${user.name} from the system.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            try {
                              await provider.deleteUser(user.id);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                              }
                            }
                          }
                        },
                        tooltip: 'Delete User',
                      ),
                    ],
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
