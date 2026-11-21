import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository({this.result, this.error});

  final List<Kos>? result;
  final Object? error;

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }
}

void main() {
  test('loadKos menyimpan urutan kos yang diterima repository', () async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Terbaru',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
      Kos(
        id: '2',
        name: 'Kos Lama',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
    ];
    final provider = KosProvider(repository: _FakeKosRepository(result: kos));

    await provider.loadKos();

    expect(provider.kos, kos);
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('loadKos menandai data kosong', () async {
    final provider = KosProvider(repository: _FakeKosRepository(result: []));

    await provider.loadKos();

    expect(provider.kos, isEmpty);
    expect(provider.errorMessage, isNull);
  });

  test('loadKos menampilkan pesan ramah saat koneksi gagal', () async {
    final provider = KosProvider(
      repository: _FakeKosRepository(error: Exception('offline')),
    );

    await provider.loadKos();

    expect(provider.kos, isEmpty);
    expect(
      provider.errorMessage,
      'Tidak dapat memuat daftar kos. Periksa koneksi internet.',
    );
  });
}
