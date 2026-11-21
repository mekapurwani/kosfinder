import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository({this.result, this.searchResult, this.error});

  final List<Kos>? result;
  final List<Kos>? searchResult;
  final Object? error;
  String? lastSearchQuery;

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }

  @override
  Future<List<Kos>> searchKosTerbaru(String query) async {
    lastSearchQuery = query;
    if (error != null) {
      throw error!;
    }
    return searchResult ?? [];
  }

  @override
  Future<Kos?> fetchKosById(String id) async => null;
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

  test('searchKos meneruskan kata pencarian dan menyimpan hasil', () async {
    const matches = [
      Kos(
        id: '3',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
    ];
    final repository = _FakeKosRepository(searchResult: matches);
    final provider = KosProvider(repository: repository);

    await provider.searchKos('mawar');

    expect(repository.lastSearchQuery, 'mawar');
    expect(provider.kos, matches);
    expect(provider.errorMessage, isNull);
  });

  test('searchKos menandai hasil pencarian kosong', () async {
    final provider = KosProvider(
      repository: _FakeKosRepository(searchResult: []),
    );

    await provider.searchKos('tidak ada');

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

  test('loadKosById menyimpan kos yang dipilih', () async {
    const selected = Kos(
      id: 'detail-1',
      name: 'Kos Detail',
      addressArea: 'Singaraja',
      monthlyPrice: 850000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Penuh',
    );
    final provider = KosProvider(repository: _DetailKosRepository(selected));

    await provider.loadKosById('detail-1');

    expect(provider.selectedKos, selected);
    expect(provider.errorMessage, isNull);
  });

  test('loadKosById menandai kos yang tidak ditemukan', () async {
    final provider = KosProvider(repository: _DetailKosRepository(null));

    await provider.loadKosById('missing');

    expect(provider.selectedKos, isNull);
    expect(provider.errorMessage, 'Kos tidak ditemukan.');
  });
}

class _DetailKosRepository implements KosRepository {
  _DetailKosRepository(this.detail);

  final Kos? detail;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => [];

  @override
  Future<List<Kos>> searchKosTerbaru(String query) async => [];

  @override
  Future<Kos?> fetchKosById(String id) async => detail;
}
