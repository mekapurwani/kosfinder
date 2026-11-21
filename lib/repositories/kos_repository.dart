import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

abstract class KosRepository {
  Future<List<Kos>> fetchKosTerbaru();
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice});
  Future<Kos?> fetchKosById(String id);
}

abstract class OwnerKosRepository {
  Future<List<Kos>> fetchKosMilikPemilik();
  Future<Kos> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  });
  Future<Kos> updateKos({
    required String id,
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  });
}

class SupabaseKosRepository implements KosRepository, OwnerKosRepository {
  const SupabaseKosRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    final rows = await client
        .from('kos')
        .select(
          'id, name, address_area, monthly_price, '
          'description, whatsapp_number, status',
        )
        .order('created_at', ascending: false);

    return rows
        .map((row) => Kos.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      var queryBuilder = client
          .from('kos')
          .select(
            'id, name, address_area, monthly_price, '
            'description, whatsapp_number, status',
          );
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('monthly_price', maxPrice);
      }
      final rows = await queryBuilder.order('created_at', ascending: false);
      return rows
          .map((row) => Kos.fromMap(Map<String, dynamic>.from(row)))
          .toList();
    }

    final escapedQuery = trimmedQuery
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_')
        .replaceAll(',', '')
        .replaceAll('.', '');
    var queryBuilder = client
        .from('kos')
        .select(
          'id, name, address_area, monthly_price, '
          'description, whatsapp_number, status',
        )
        .or(
          'name.ilike.%$escapedQuery%,'
          'address_area.ilike.%$escapedQuery%',
        );
    if (maxPrice != null) {
      queryBuilder = queryBuilder.lte('monthly_price', maxPrice);
    }
    final rows = await queryBuilder.order('created_at', ascending: false);

    return rows
        .map((row) => Kos.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<Kos?> fetchKosById(String id) async {
    final row = await client
        .from('kos')
        .select(
          'id, name, address_area, monthly_price, '
          'description, whatsapp_number, status',
        )
        .eq('id', id)
        .maybeSingle();

    if (row == null) {
      return null;
    }
    return Kos.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<Kos>> fetchKosMilikPemilik() async {
    final ownerId = client.auth.currentUser?.id;
    if (ownerId == null) {
      throw StateError('Pemilik belum login.');
    }

    final rows = await client
        .from('kos')
        .select(
          'id, owner_id, name, address_area, monthly_price, '
          'description, whatsapp_number, status, created_at',
        )
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return rows
        .map((row) => Kos.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<Kos> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    final ownerId = client.auth.currentUser?.id;
    if (ownerId == null) {
      throw StateError('Pemilik belum login.');
    }

    final row = await client
        .from('kos')
        .insert({
          'owner_id': ownerId,
          'name': name,
          'address_area': addressArea,
          'monthly_price': monthlyPrice,
          'description': description,
          'whatsapp_number': whatsappNumber,
          'status': status,
        })
        .select(
          'id, owner_id, name, address_area, monthly_price, '
          'description, whatsapp_number, status, created_at',
        )
        .single();

    return Kos.fromMap(Map<String, dynamic>.from(row));
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
  }) async {
    final ownerId = client.auth.currentUser?.id;
    if (ownerId == null) {
      throw StateError('Pemilik belum login.');
    }

    final row = await client
        .from('kos')
        .update({
          'name': name,
          'address_area': addressArea,
          'monthly_price': monthlyPrice,
          'description': description,
          'whatsapp_number': whatsappNumber,
          'status': status,
        })
        .eq('id', id)
        .eq('owner_id', ownerId)
        .select(
          'id, owner_id, name, address_area, monthly_price, '
          'description, whatsapp_number, status, created_at',
        )
        .maybeSingle();

    if (row == null) {
      throw StateError(
        'Kos tidak ditemukan atau bukan milik pemilik yang login.',
      );
    }
    return Kos.fromMap(Map<String, dynamic>.from(row));
  }
}

class MissingSupabaseKosRepository implements KosRepository {
  const MissingSupabaseKosRepository();

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }

  @override
  Future<Kos?> fetchKosById(String id) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }
}
