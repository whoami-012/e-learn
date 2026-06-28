import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/teacher_dashboard_provider.dart';
import '../../../../providers/user_provider.dart';
import '../controllers/live_class_controller.dart';

class CreateLiveClassScreen extends StatefulWidget {
  const CreateLiveClassScreen({super.key});
  @override
  State<CreateLiveClassScreen> createState() => _CreateLiveClassScreenState();
}

class _CreateLiveClassScreenState extends State<CreateLiveClassScreen> {
  final title = TextEditingController(), description = TextEditingController();
  String? courseId;
  DateTime start = DateTime.now().add(const Duration(hours: 1));
  DateTime end = DateTime.now().add(const Duration(hours: 2));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courses = context.read<TeacherDashboardProvider>();
      if (courses.courses.isEmpty && !courses.isLoading) {
        final user = context.read<UserProvider>();
        courses.fetchCourses(user.isAdmin ? null : user.user?.id);
      }
    });
  }

  Future<void> pick(bool isStart) async {
    final base = isStart ? start : end;
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: base);
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (time != null)
      setState(() {
        final value =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        if (isStart)
          start = value;
        else
          end = value;
      });
  }

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<TeacherDashboardProvider>();
    final courses = courseState.courses;
    final state = context.watch<LiveClassController>();
    return Scaffold(
        appBar: AppBar(title: const Text('Schedule live class')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<String>(
              initialValue: courseId,
              decoration: InputDecoration(
                  labelText: 'Course',
                  helperText: courseState.isLoading
                      ? 'Loading your courses...'
                      : courses.isEmpty
                          ? 'No courses are assigned to this faculty account.'
                          : 'Select one of your courses'),
              items: courses
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.title)))
                  .toList(),
              onChanged: courseState.isLoading || courses.isEmpty
                  ? null
                  : (v) => setState(() => courseId = v)),
          if (courseState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(courseState.error!,
                  style: const TextStyle(color: Colors.red)),
            ),
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title')),
          TextField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description')),
          ListTile(
              title: const Text('Starts'),
              subtitle: Text(start.toString()),
              onTap: () => pick(true)),
          ListTile(
              title: const Text('Ends'),
              subtitle: Text(end.toString()),
              onTap: () => pick(false)),
          if (state.error != null)
            Text(state.error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (courseId == null ||
                          title.text.trim().isEmpty ||
                          !end.isAfter(start)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Select a course and valid times.')));
                        return;
                      }
                      final ok = await context
                          .read<LiveClassController>()
                          .create(
                              courseId: courseId!,
                              title: title.text.trim(),
                              description: description.text.trim(),
                              startsAt: start,
                              endsAt: end);
                      if (ok && mounted) Navigator.pop(context);
                    },
              child: state.isLoading
                  ? const SizedBox.square(
                      dimension: 20, child: CircularProgressIndicator())
                  : const Text('Schedule'))
        ]));
  }
}
