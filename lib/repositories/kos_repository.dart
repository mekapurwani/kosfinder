import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

abstract class KosRepository {
  Future<List<Kos>> fetchKosTerbaru();
  Future<List<Kos>> searchKosTerbaru(String query);
  Future<Kos?> fetchKosById(String id);
}

class SupabaseKosRepository implements KosRepository {
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
  Future<List<Kos>> searchKosTerbaru(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return fetchKosTerbaru();
    }

    final escapedQuery = trimmedQuery
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_')
        .replaceAll(',', '')
        .replaceAll('.', '');
    final rows = await client
        .from('kos')
        .select(
          'id, name, address_area, monthly_price, '
          'description, whatsapp_number, status',
        )
        .or(
          'name.ilike.%$escapedQuery%,'
          'address_area.ilike.%$escapedQuery%',
        )
        .order('created_at', ascending: false);

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
}

class MissingSupabaseKosRepository implements KosRepository {
  const MissingSupabaseKosRepository();

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }

  @override
  Future<List<Kos>> searchKosTerbaru(String query) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }

  @override
  Future<Kos?> fetchKosById(String id) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }
}
