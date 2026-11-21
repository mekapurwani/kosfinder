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
  num? lastMaxPrice;

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    lastSearchQuery = query;
    lastMaxPrice = maxPrice;
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

  test('searchKos meneruskan harga maksimum', () async {
    const matches = [
      Kos(
        id: '4',
        name: 'Kos Anggrek',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
    ];
    final repository = _FakeKosRepository(searchResult: matches);
    final provider = KosProvider(repository: repository);

    await provider.searchKos('singaraja', maxPrice: 800000);

    expect(repository.lastSearchQuery, 'singaraja');
    expect(repository.lastMaxPrice, 800000);
    expect(provider.kos, matches);
  });

  test('searchKos menyaring kos di atas harga maksimum', () async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Murah',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
      Kos(
        id: '2',
        name: 'Kos Mahal',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
    ];
    final provider = KosProvider(repository: _FakeFilteredKosRepository(kos));

    await provider.searchKos('', maxPrice: 800000);

    expect(provider.kos, [kos.first]);
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

  test('loadOwnedKos menyimpan hanya kos hasil repository pemilik', () async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(owned: owned),
    );

    await provider.loadOwnedKos();

    expect(provider.ownedKos, owned);
    expect(provider.errorMessage, isNull);
  });

  test('createKos menambahkan kos baru ke daftar pemilik', () async {
    const created = Kos(
      id: 'owned-2',
      name: 'Kos Melati',
      addressArea: 'Singaraja',
      monthlyPrice: 900000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
      ownerId: 'owner-1',
    );
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(created: created),
    );

    final success = await provider.createKos(
      name: 'Kos Melati',
      addressArea: 'Singaraja',
      monthlyPrice: 900000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    expect(success, isTrue);
    expect(provider.ownedKos, [created]);
  });

  test('createKos langsung menambahkan kos ke daftar publik', () async {
    final provider = KosProvider(repository: _FakeOwnerKosRepository());
    await provider.loadKos();

    final success = await provider.createKos(
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    expect(success, isTrue);
    expect(provider.kos.map((kos) => kos.name), contains('Kos Baru'));
  });

  test('updateKos mengubah kos milik pemilik', () async {
    const original = Kos(
      id: 'owned-1',
      name: 'Kos Lama',
      addressArea: 'Singaraja',
      monthlyPrice: 700000,
      ownerId: 'owner-1',
    );
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(owned: [original]),
    );
    await provider.loadOwnedKos();

    final success = await provider.updateKos(
      id: 'owned-1',
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Penuh',
    );

    expect(success, isTrue);
    expect(provider.ownedKos.single.name, 'Kos Baru');
    expect(provider.ownedKos.single.status, 'Penuh');
  });

  test('updateKos langsung memperbarui daftar kos publik', () async {
    const original = Kos(
      id: 'owned-1',
      name: 'Kos Lama',
      addressArea: 'Singaraja',
      monthlyPrice: 700000,
      ownerId: 'owner-1',
    );
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(owned: [original]),
    );
    await provider.loadKos();

    final success = await provider.updateKos(
      id: 'owned-1',
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Penuh',
    );

    expect(success, isTrue);
    expect(provider.kos.single.name, 'Kos Baru');
    expect(provider.kos.single.status, 'Penuh');
  });

  test('updateKos tetap menghormati filter harga publik', () async {
    const original = Kos(
      id: 'owned-1',
      name: 'Kos Lama',
      addressArea: 'Singaraja',
      monthlyPrice: 700000,
      ownerId: 'owner-1',
    );
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(owned: [original]),
    );
    await provider.searchKos('kos', maxPrice: 750000);

    await provider.updateKos(
      id: 'owned-1',
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 900000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    expect(provider.kos, isEmpty);
  });

  test('updateKos menolak kos milik pemilik lain', () async {
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(
        updateError: StateError(
          'Kos tidak ditemukan atau bukan milik pemilik yang login.',
        ),
      ),
    );

    final success = await provider.updateKos(
      id: 'kos-pemilik-lain',
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    expect(success, isFalse);
    expect(
      provider.errorMessage,
      'Anda tidak memiliki akses untuk mengubah kos ini.',
    );
  });

  test('updateKos menampilkan pesan koneksi saat gagal', () async {
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(updateError: Exception('offline')),
    );

    final success = await provider.updateKos(
      id: 'owned-1',
      name: 'Kos Baru',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    expect(success, isFalse);
    expect(
      provider.errorMessage,
      'Tidak dapat mengubah kos. Periksa koneksi internet.',
    );
  });

  test('updateKos status offline mempertahankan status lama', () async {
    const original = Kos(
      id: 'owned-1',
      name: 'Kos Mawar',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      status: 'Tersedia',
      ownerId: 'owner-1',
    );
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(
        owned: [original],
        updateError: Exception('offline'),
      ),
    );
    await provider.loadKos();

    final success = await provider.updateKos(
      id: 'owned-1',
      name: 'Kos Mawar',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Penuh',
    );

    expect(success, isFalse);
    expect(provider.kos.single.status, 'Tersedia');
  });

  test('deleteKos menghapus kos dari daftar pemilik', () async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final repository = _FakeOwnerKosRepository(owned: owned);
    final provider = KosProvider(repository: repository);
    await provider.loadOwnedKos();

    final success = await provider.deleteKos('owned-1');

    expect(success, isTrue);
    expect(repository.lastDeletedId, 'owned-1');
    expect(provider.ownedKos, isEmpty);
  });

  test('deleteKos langsung menghapus kos dari daftar publik', () async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(owned: owned),
    );
    await provider.loadKos();

    final success = await provider.deleteKos('owned-1');

    expect(success, isTrue);
    expect(provider.kos, isEmpty);
  });

  test('deleteKos menolak kos milik pemilik lain', () async {
    final provider = KosProvider(
      repository: _FakeOwnerKosRepository(
        deleteError: StateError(
          'Kos tidak ditemukan atau bukan milik pemilik yang login.',
        ),
      ),
    );

    final success = await provider.deleteKos('kos-pemilik-lain');

    expect(success, isFalse);
    expect(
      provider.errorMessage,
      'Anda tidak memiliki akses untuk menghapus kos ini.',
    );
  });
}

class _FakeOwnerKosRepository implements KosRepository, OwnerKosRepository {
  _FakeOwnerKosRepository({
    this.owned = const [],
    this.created,
    this.updateError,
    this.deleteError,
  });

  List<Kos> owned;
  final Kos? created;
  final Object? updateError;
  final Object? deleteError;
  String? lastDeletedId;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => owned;

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    final normalizedQuery = query.trim().toLowerCase();
    return owned.where((item) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.name.toLowerCase().contains(normalizedQuery) ||
          item.addressArea.toLowerCase().contains(normalizedQuery);
      final matchesPrice = maxPrice == null || item.monthlyPrice <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();
  }

  @override
  Future<Kos?> fetchKosById(String id) async => null;

  @override
  Future<List<Kos>> fetchKosMilikPemilik() async => owned;

  @override
  Future<Kos> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
    int roomCount = 0,
  }) async {
    final newKos =
        created ??
        Kos(
          id: 'owned-new',
          name: name,
          addressArea: addressArea,
          monthlyPrice: monthlyPrice,
          description: description,
          whatsappNumber: whatsappNumber,
          status: status,
          ownerId: 'owner-1',
          roomCount: roomCount,
        );
    owned = [newKos, ...owned];
    return newKos;
  }

  @override
  Future<Kos> updateKos({
    required String id,
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
    int roomCount = 0,
  }) async {
    if (updateError != null) {
      throw updateError!;
    }
    final updatedKos = Kos(
      id: id,
      name: name,
      addressArea: addressArea,
      monthlyPrice: monthlyPrice,
      description: description,
      whatsappNumber: whatsappNumber,
      status: status,
      ownerId: 'owner-1',
      roomCount: roomCount,
    );
    owned = owned.map((kos) => kos.id == id ? updatedKos : kos).toList();
    return updatedKos;
  }

  @override
  Future<void> deleteKos(String id) async {
    lastDeletedId = id;
    if (deleteError != null) {
      throw deleteError!;
    }
    owned = owned.where((kos) => kos.id != id).toList();
  }
}

class _DetailKosRepository implements KosRepository {
  _DetailKosRepository(this.detail);

  final Kos? detail;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => [];

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async => [];

  @override
  Future<Kos?> fetchKosById(String id) async => detail;
}

class _FakeFilteredKosRepository implements KosRepository {
  _FakeFilteredKosRepository(this.kos);

  final List<Kos> kos;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => kos;

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    return kos.where((item) {
      final matchesQuery =
          query.trim().isEmpty ||
          item.name.toLowerCase().contains(query.trim().toLowerCase()) ||
          item.addressArea.toLowerCase().contains(query.trim().toLowerCase());
      final matchesPrice = maxPrice == null || item.monthlyPrice <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();
  }

  @override
  Future<Kos?> fetchKosById(String id) async => null;
}
