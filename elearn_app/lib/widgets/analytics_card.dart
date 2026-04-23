import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardStat {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final LinearGradient gradient;
  final Color bgColor;
  final Color shadowColor;

  DashboardStat({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.gradient,
    required this.bgColor,
    required this.shadowColor,
  });
}

class AnalyticsCard extends StatelessWidget {
  final DashboardStat stat;

  const AnalyticsCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: stat.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: stat.gradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: stat.shadowColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(stat.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            stat.label,
            style: AppTheme.bodySmall.copyWith(color: const Color(0xFF4B5563)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.value,
                style: AppTheme.h2.copyWith(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5), // emerald-100
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 10, color: Color(0xFF059669)),
                    const SizedBox(width: 2),
                    Text(
                      stat.change,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857), // emerald-700
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
