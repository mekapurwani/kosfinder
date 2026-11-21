import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  bool get hasActiveSession;

  Stream<bool> get sessionChanges;

  Future<void> restoreSession();
}

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this.client);

  final SupabaseClient client;

  @override
  bool get hasActiveSession => client.auth.currentSession != null;

  @override
  Stream<bool> get sessionChanges {
    return client.auth.onAuthStateChange.map((event) {
      return event.session != null;
    });
  }

  @override
  Future<void> restoreSession() async {
    client.auth.currentSession;
  }
}

class MissingAuthRepository implements AuthRepository {
  const MissingAuthRepository();

  @override
  bool get hasActiveSession => false;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> restoreSession() async {}
}
