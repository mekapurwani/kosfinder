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
