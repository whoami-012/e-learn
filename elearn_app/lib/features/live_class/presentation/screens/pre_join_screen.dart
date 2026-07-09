import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../data/models/live_class.dart';
import '../../domain/agora_classroom_service.dart';
import '../controllers/live_class_controller.dart';
import 'classroom_screen.dart';

class PreJoinScreen extends StatefulWidget {
  final LiveClass liveClass;
  const PreJoinScreen({super.key, required this.liveClass});
  @override
  State<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends State<PreJoinScreen> {
  bool permissions = false, checking = false;
  Future<void> prepare() async {
    if (checking) return;
    setState(() => checking = true);
    final faculty = context.read<UserProvider>().isFaculty;
    if (faculty) {
      final service = AgoraClassroomService();
      permissions = await service.requestBroadcasterPermissions();
      service.dispose();
    } else {
      permissions = true;
    }
    if (mounted) setState(() => checking = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => prepare());
  }

  @override
  Widget build(BuildContext context) {
    final faculty = context.watch<UserProvider>().isFaculty;
    final controller = context.watch<LiveClassController>();
    return Scaffold(
        appBar: AppBar(title: const Text('Ready to join?')),
        body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Icon(Icons.video_camera_front, size: 72),
              Text(widget.liveClass.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(widget.liveClass.facultyName ?? 'Faculty'),
              Text('${widget.liveClass.scheduledStartTime}'),
              const SizedBox(height: 24),
              if (faculty)
                Text(permissions
                    ? 'Camera and microphone ready'
                    : 'Camera and microphone permission is required')
              else
                const Text(
                    'You will join as audience. Camera and microphone remain off.'),
              if (controller.error != null)
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(controller.error!,
                        style: const TextStyle(color: Colors.red))),
              const Spacer(),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: (!permissions || controller.isJoining)
                          ? null
                          : () async {
                              final value = await context
                                  .read<LiveClassController>()
                                  .join(widget.liveClass.id,
                                      start: faculty &&
                                          widget.liveClass.status ==
                                              'scheduled');
                              if (value != null) {
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ClassroomScreen(
                                            credentials: value)));
                              }
                            },
                      child: controller.isJoining
                          ? const SizedBox.square(
                              dimension: 20, child: CircularProgressIndicator())
                          : Text(faculty ? 'Enter classroom' : 'Join class')))
            ])));
  }
}
