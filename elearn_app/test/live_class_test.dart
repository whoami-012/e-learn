import 'dart:async';
import 'package:elearn_app/features/live_class/data/live_class_repository.dart';
import 'package:elearn_app/features/live_class/data/models/live_class.dart';
import 'package:elearn_app/features/live_class/presentation/controllers/live_class_controller.dart';
import 'package:flutter_test/flutter_test.dart';

AgoraJoinCredentials credential() => AgoraJoinCredentials(
      liveClassId: 'class-id',
      appId: 'public-id',
      channelName: 'channel',
      token: 'token',
      uid: 12,
      role: 'audience',
      tokenExpiresAt: DateTime.utc(2026, 6, 27, 12),
      title: 'Physics',
      facultyName: 'Teacher',
    );

class FakeRepository extends LiveClassRepository {
  final completer = Completer<AgoraJoinCredentials>();
  int joins = 0;
  @override
  Future<AgoraJoinCredentials> join(String id, {bool start = false}) {
    joins++;
    return completer.future;
  }
}

void main() {
  test('join response parses camelCase credentials and UTC expiry', () {
    final parsed = AgoraJoinCredentials.fromJson({
      'liveClassId': '42',
      'appId': 'public-id',
      'channelName': 'server-channel',
      'token': 'secret-token',
      'uid': 5839201,
      'role': 'audience',
      'tokenExpiresAt': '2026-06-27T12:00:00Z',
      'class': {'title': 'Physics', 'facultyName': 'Teacher'},
    });
    expect(parsed.liveClassId, '42');
    expect(parsed.uid, 5839201);
    expect(parsed.isBroadcaster, isFalse);
    expect(parsed.tokenExpiresAt.isUtc, isTrue);
  });

  test('controller prevents duplicate join requests', () async {
    final repository = FakeRepository();
    final controller = LiveClassController(repository: repository);
    final first = controller.join('class-id');
    final second = await controller.join('class-id');
    expect(second, isNull);
    expect(repository.joins, 1);
    repository.completer.complete(credential());
    expect(await first, isNotNull);
    expect(controller.isJoining, isFalse);
  });
}
