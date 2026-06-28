import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../data/models/live_class.dart';
import 'attendance_screen.dart';
import 'pre_join_screen.dart';

class LiveClassDetailScreen extends StatelessWidget {
  final LiveClass liveClass;
  const LiveClassDetailScreen({super.key, required this.liveClass});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final canEnter = liveClass.status == 'live' ||
        (user.isFaculty && liveClass.status == 'scheduled');
    return Scaffold(
        appBar: AppBar(title: const Text('Class details')),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(liveClass.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(liveClass.description ?? 'No description'),
              const SizedBox(height: 16),
              Text('Faculty: ${liveClass.facultyName ?? 'Faculty'}'),
              Text('Starts: ${liveClass.scheduledStartTime}'),
              Text('Ends: ${liveClass.scheduledEndTime}'),
              Text('Status: ${liveClass.status}'),
              const Spacer(),
              if (user.isFaculty)
                OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AttendanceScreen(liveClassId: liveClass.id))),
                    icon: const Icon(Icons.fact_check),
                    label: const Text('Attendance')),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                      onPressed: canEnter
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PreJoinScreen(liveClass: liveClass)))
                          : null,
                      icon: const Icon(Icons.video_call),
                      label: Text(
                          user.isFaculty && liveClass.status == 'scheduled'
                              ? 'Start class'
                              : 'Join class')))
            ])));
  }
}
