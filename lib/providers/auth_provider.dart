import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository});

  final AuthRepository repository;

  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasActiveSession => repository.hasActiveSession;

  Future<void> restoreSession() async {
    await repository.restoreSession();
    _profile = repository.currentProfile;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.login(email: email, password: password);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Gagal login: $error');
      debugPrintStack(label: 'Stack trace login', stackTrace: stackTrace);
      _errorMessage = 'Email atau password salah.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.logout();
      _profile = null;
    } catch (error, stackTrace) {
      debugPrint('Gagal logout: $error');
      debugPrintStack(label: 'Stack trace logout', stackTrace: stackTrace);
      _errorMessage = 'Logout gagal. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('Gagal registrasi: $error');
      debugPrintStack(label: 'Stack trace registrasi', stackTrace: stackTrace);
      _errorMessage = 'Registrasi gagal. Periksa data atau koneksi Anda.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
