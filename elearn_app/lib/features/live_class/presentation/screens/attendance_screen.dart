import 'package:flutter/material.dart';
import '../../data/live_class_repository.dart';
import '../../data/models/live_class.dart';

class AttendanceScreen extends StatefulWidget {
  final String liveClassId;
  const AttendanceScreen({super.key, required this.liveClassId});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<LiveClassAttendance>> future;
  @override
  void initState() {
    super.initState();
    future = LiveClassRepository().attendance(widget.liveClassId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: FutureBuilder<List<LiveClassAttendance>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final rows = snapshot.data!;
            if (rows.isEmpty) {
              return const Center(child: Text('No students have joined.'));
            }
            return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final row = rows[i];
                  return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(row.studentName ?? row.studentId),
                      subtitle: Text('${row.durationSeconds ~/ 60} minutes'),
                      trailing: Chip(label: Text(row.status)));
                });
          }));
}
