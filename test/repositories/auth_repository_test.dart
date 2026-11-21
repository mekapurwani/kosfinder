import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  bool sessionActive = false;
  bool restored = false;
  final _sessionChanges = StreamController<bool>.broadcast();

  @override
  bool get hasActiveSession => sessionActive;

  @override
  Stream<bool> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> restoreSession() async {
    restored = true;
  }

  void emitSession(bool active) {
    sessionActive = active;
    _sessionChanges.add(active);
  }

  Future<void> close() => _sessionChanges.close();
}

void main() {
  test('MissingAuthRepository tidak memiliki sesi aktif', () {
    const repository = MissingAuthRepository();

    expect(repository.hasActiveSession, isFalse);
  });

  test('restoreSession menandai pemulihan sesi', () async {
    final repository = _FakeAuthRepository();

    await repository.restoreSession();

    expect(repository.restored, isTrue);
  });

  test('sessionChanges membedakan sesi aktif dan berakhir', () async {
    final repository = _FakeAuthRepository();
    final states = <bool>[];
    final subscription = repository.sessionChanges.listen(states.add);

    repository.emitSession(true);
    repository.emitSession(false);
    await pumpEventQueue();

    expect(states, [true, false]);
    expect(repository.hasActiveSession, isFalse);

    await subscription.cancel();
    await repository.close();
  });
}
