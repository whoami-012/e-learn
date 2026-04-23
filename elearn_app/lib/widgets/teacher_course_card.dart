import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/constants/app_constants.dart';

String _fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${AppConstants.serverBase}$path';
}

class TeacherCourseCard extends StatelessWidget {
  final Course course;

  const TeacherCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail / Top Section
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                child: course.thumbnailUrl != null
                    ? Image.network(
                        _fullImageUrl(course.thumbnailUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.menu_book, size: 40, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.menu_book, size: 40, color: Colors.grey),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.isFree ? Colors.blue.shade500 : Colors.green.shade500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.isFree ? 'Free' : '₹${course.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '12', // Mocked as backend doesn't provide it yet
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8', // Mocked as backend doesn't provide it yet
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
