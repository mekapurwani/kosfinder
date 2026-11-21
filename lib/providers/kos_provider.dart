import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  KosProvider({required this.repository});

  final KosRepository repository;

  List<Kos> _kos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get kos => List.unmodifiable(_kos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
}
