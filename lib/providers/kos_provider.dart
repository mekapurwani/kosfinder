import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  KosProvider({required this.repository});

  final KosRepository repository;

  List<Kos> _kos = [];
  Kos? _selectedKos;
  List<Kos> _ownedKos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get kos => List.unmodifiable(_kos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Kos? get selectedKos => _selectedKos;
  List<Kos> get ownedKos => List.unmodifiable(_ownedKos);

  OwnerKosRepository get _ownerRepository {
    if (repository is OwnerKosRepository) {
      return repository as OwnerKosRepository;
    }
    throw StateError('Repository pemilik tidak tersedia.');
  }

  Future<void> loadOwnedKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ownedKos = await _ownerRepository.fetchKosMilikPemilik();
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat kos pemilik: $error');
      debugPrintStack(label: 'Stack trace kos pemilik', stackTrace: stackTrace);
      _errorMessage = 'Tidak dapat memuat kos Anda. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final kos = await _ownerRepository.createKos(
        name: name,
        addressArea: addressArea,
        monthlyPrice: monthlyPrice,
        description: description,
        whatsappNumber: whatsappNumber,
        status: status,
      );
      _ownedKos = [kos, ..._ownedKos];
      return true;
    } catch (error, stackTrace) {
      debugPrint('Gagal menambah kos: $error');
      debugPrintStack(label: 'Stack trace tambah kos', stackTrace: stackTrace);
      _errorMessage = 'Tidak dapat menambah kos. Periksa koneksi internet.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateKos({
    required String id,
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedKos = await _ownerRepository.updateKos(
        id: id,
        name: name,
        addressArea: addressArea,
        monthlyPrice: monthlyPrice,
        description: description,
        whatsappNumber: whatsappNumber,
        status: status,
      );
      _ownedKos = _ownedKos
          .map((kos) => kos.id == id ? updatedKos : kos)
          .toList();
      _selectedKos = updatedKos;
      return true;
    } catch (error, stackTrace) {
      debugPrint('Gagal mengubah kos: $error');
      debugPrintStack(label: 'Stack trace ubah kos', stackTrace: stackTrace);
      if (error is StateError && error.toString().contains('bukan milik')) {
        _errorMessage = 'Anda tidak memiliki akses untuk mengubah kos ini.';
      } else {
        _errorMessage = 'Tidak dapat mengubah kos. Periksa koneksi internet.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> searchKos(String query, {num? maxPrice}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kos = await repository.searchKosTerbaru(query, maxPrice: maxPrice);
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
