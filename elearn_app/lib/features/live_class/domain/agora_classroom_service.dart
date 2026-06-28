import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/live_class_repository.dart';
import '../data/models/live_class.dart';

enum ClassroomConnection { idle, connecting, connected, interrupted, failed }

class AgoraClassroomService extends ChangeNotifier {
  final LiveClassRepository repository;
  AgoraClassroomService({LiveClassRepository? repository})
      : repository = repository ?? LiveClassRepository();
  RtcEngine? engine;
  AgoraJoinCredentials? credentials;
  ClassroomConnection connection = ClassroomConnection.idle;
  final Set<int> remoteUsers = {};
  bool microphoneEnabled = true;
  bool cameraEnabled = true;
  bool speakerEnabled = true;
  String? error;
  Timer? _heartbeat;
  Timer? _refresh;
  bool _disposed = false;

  Future<bool> requestBroadcasterPermissions() async {
    final result = await [Permission.camera, Permission.microphone].request();
    return result.values.every((status) => status.isGranted);
  }

  Future<void> initializeAndJoin(AgoraJoinCredentials value) async {
    if (engine != null) return;
    credentials = value;
    connection = ClassroomConnection.connecting;
    notifyListeners();
    try {
      final rtc = createAgoraRtcEngine();
      engine = rtc;
      await rtc.initialize(RtcEngineContext(
          appId: value.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
      rtc.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) {
          connection = ClassroomConnection.connected;
          _notify();
          // setEnableSpeakerphone is a current-channel API. Calling it before
          // joinChannel completes returns Agora ERR_NOT_READY (-3).
          unawaited(
            rtc.setEnableSpeakerphone(speakerEnabled).catchError((Object e) {
              error = 'Connected, but speaker routing failed: $e';
              _notify();
            }),
          );
        },
        onUserJoined: (_, uid, __) {
          remoteUsers.add(uid);
          _notify();
        },
        onUserOffline: (_, uid, __) {
          remoteUsers.remove(uid);
          _notify();
        },
        onConnectionStateChanged: (_, state, __) {
          connection = state == ConnectionStateType.connectionStateConnected
              ? ClassroomConnection.connected
              : state == ConnectionStateType.connectionStateReconnecting
                  ? ClassroomConnection.interrupted
                  : connection;
          _notify();
        },
        onTokenPrivilegeWillExpire: (_, __) => _renewToken(),
        onError: (code, message) {
          error = '$code: $message';
          connection = ClassroomConnection.failed;
          _notify();
        },
      ));
      final broadcaster = value.isBroadcaster;
      await rtc.setClientRole(
          role: broadcaster
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience);
      if (broadcaster) {
        await rtc.enableVideo();
        await rtc.startPreview();
      }
      await rtc.joinChannel(
          token: value.token,
          channelId: value.channelName,
          uid: value.uid,
          options: ChannelMediaOptions(
              channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
              clientRoleType: broadcaster
                  ? ClientRoleType.clientRoleBroadcaster
                  : ClientRoleType.clientRoleAudience,
              publishCameraTrack: broadcaster,
              publishMicrophoneTrack: broadcaster));
      if (!broadcaster)
        _heartbeat = Timer.periodic(const Duration(seconds: 45),
            (_) => repository.heartbeat(value.liveClassId));
      _scheduleRefresh(value.tokenExpiresAt);
    } catch (e) {
      error = e.toString();
      connection = ClassroomConnection.failed;
      await disposeEngine();
      rethrow;
    }
  }

  void _scheduleRefresh(DateTime expiresAt) {
    _refresh?.cancel();
    final delay = expiresAt.difference(DateTime.now().toUtc()) -
        const Duration(minutes: 3);
    _refresh = Timer(
        delay.isNegative ? const Duration(seconds: 1) : delay, _renewToken);
  }

  Future<void> _renewToken() async {
    final current = credentials;
    if (current == null || engine == null) return;
    try {
      final fresh = await repository.refreshToken(current.liveClassId);
      credentials = fresh;
      await engine!.renewToken(fresh.token);
      _scheduleRefresh(fresh.tokenExpiresAt);
    } catch (e) {
      error = 'Token refresh failed: $e';
      _notify();
    }
  }

  Future<void> toggleMicrophone() async {
    microphoneEnabled = !microphoneEnabled;
    await engine?.muteLocalAudioStream(!microphoneEnabled);
    _notify();
  }

  Future<void> toggleCamera() async {
    cameraEnabled = !cameraEnabled;
    await engine?.muteLocalVideoStream(!cameraEnabled);
    _notify();
  }

  Future<void> switchCamera() async => engine?.switchCamera();
  Future<void> toggleSpeaker() async {
    speakerEnabled = !speakerEnabled;
    await engine?.setEnableSpeakerphone(speakerEnabled);
    _notify();
  }

  Future<void> leave({bool report = true}) async {
    final current = credentials;
    if (report && current != null && !current.isBroadcaster) {
      try {
        await repository.leave(current.liveClassId);
      } catch (_) {}
    }
    await disposeEngine();
  }

  Future<void> disposeEngine() async {
    _heartbeat?.cancel();
    _refresh?.cancel();
    final rtc = engine;
    engine = null;
    if (rtc != null) {
      await rtc.leaveChannel();
      await rtc.release();
    }
    remoteUsers.clear();
    connection = ClassroomConnection.idle;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _heartbeat?.cancel();
    _refresh?.cancel();
    final rtc = engine;
    engine = null;
    if (rtc != null) {
      rtc.leaveChannel().then((_) => rtc.release());
    }
    super.dispose();
  }
}
