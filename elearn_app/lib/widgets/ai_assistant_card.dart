import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AIAssistantCard extends StatelessWidget {
  const AIAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDBEAFE).withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── AI Icon Container ──────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBFDBFE).withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),

            // ── Text Content ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your AI assistant',
                    style: AppTheme.bodySmall.copyWith(
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "You're teaching great today!",
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ── Sparkle Emoji Decoration ──────────────────────────────────
            const Text(
              '✨',
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
