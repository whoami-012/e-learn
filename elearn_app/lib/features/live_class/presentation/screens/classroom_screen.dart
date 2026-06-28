import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../../data/live_class_repository.dart';
import '../../data/models/live_class.dart';
import '../../domain/agora_classroom_service.dart';
import 'attendance_screen.dart';

class ClassroomScreen extends StatefulWidget {
  final AgoraJoinCredentials credentials;
  const ClassroomScreen({super.key, required this.credentials});
  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  late final AgoraClassroomService service;
  Timer? clock;
  Duration elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    service = AgoraClassroomService()..addListener(_changed);
    service.initializeAndJoin(widget.credentials).catchError((_) {});
    clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => elapsed += const Duration(seconds: 1));
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _exit({bool end = false}) async {
    if (end) await LiveClassRepository().end(widget.credentials.liveClassId);
    await service.leave();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    clock?.cancel();
    service.removeListener(_changed);
    service.leave();
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final broadcaster = widget.credentials.isBroadcaster;
    final remote =
        service.remoteUsers.isEmpty ? null : service.remoteUsers.first;
    Widget video;
    if (service.engine == null) {
      video = Center(
          child: Text(service.error ?? 'Connecting...',
              style: const TextStyle(color: Colors.white)));
    } else if (broadcaster) {
      video = AgoraVideoView(
          controller: VideoViewController(
              rtcEngine: service.engine!, canvas: const VideoCanvas(uid: 0)));
    } else if (remote == null) {
      video = const Center(
          child: Text('Waiting for faculty video...',
              style: TextStyle(color: Colors.white)));
    } else {
      video = AgoraVideoView(
          controller: VideoViewController.remote(
        rtcEngine: service.engine!,
        canvas: VideoCanvas(uid: remote),
        connection: RtcConnection(channelId: widget.credentials.channelName),
      ));
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.credentials.title),
            Text(
                '${service.connection.name} - ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12)),
          ]),
          actions: [
            if (broadcaster)
              IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AttendanceScreen(
                            liveClassId: widget.credentials.liveClassId))),
                icon: const Icon(Icons.people),
              )
          ],
        ),
        body: Column(children: [
          Expanded(child: video),
          if (service.error != null)
            Text(service.error!,
                style: const TextStyle(color: Colors.redAccent)),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (broadcaster)
                    IconButton.filled(
                        onPressed: service.toggleMicrophone,
                        icon: Icon(service.microphoneEnabled
                            ? Icons.mic
                            : Icons.mic_off)),
                  if (broadcaster)
                    IconButton.filled(
                        onPressed: service.toggleCamera,
                        icon: Icon(service.cameraEnabled
                            ? Icons.videocam
                            : Icons.videocam_off)),
                  if (broadcaster)
                    IconButton.filled(
                        onPressed: service.switchCamera,
                        icon: const Icon(Icons.cameraswitch)),
                  IconButton.filled(
                      onPressed: service.toggleSpeaker,
                      icon: Icon(service.speakerEnabled
                          ? Icons.volume_up
                          : Icons.volume_off)),
                  IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _exit(end: broadcaster),
                      icon: Icon(
                          broadcaster ? Icons.stop_circle : Icons.call_end)),
                ]),
          )),
        ]),
      ),
    );
  }
}
