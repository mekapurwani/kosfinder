import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  KosProvider({required this.repository});

  final KosRepository repository;

  List<Kos> _kos = [];
  Kos? _selectedKos;
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get kos => List.unmodifiable(_kos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Kos? get selectedKos => _selectedKos;

  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kos = await repository.fetchKosTerbaru();
    } catch (error, stackTrace) {
      debugPrint('Gagal mengambil data kos: $error');
      debugPrintStack(
        label: 'Stack trace pengambilan data kos',
        stackTrace: stackTrace,
      );
      _errorMessage =
          'Tidak dapat memuat daftar kos. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchKos(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kos = await repository.searchKosTerbaru(query);
    } catch (error, stackTrace) {
      debugPrint('Gagal mencari kos: $error');
      debugPrintStack(
        label: 'Stack trace pencarian kos',
        stackTrace: stackTrace,
      );
      _errorMessage =
          'Tidak dapat memuat daftar kos. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadKosById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedKos = null;
    notifyListeners();

    try {
      _selectedKos = await repository.fetchKosById(id);
      if (_selectedKos == null) {
        _errorMessage = 'Kos tidak ditemukan.';
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal mengambil detail kos: $error');
      debugPrintStack(
        label: 'Stack trace pengambilan detail kos',
        stackTrace: stackTrace,
      );
      _errorMessage =
          'Tidak dapat memuat detail kos. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
