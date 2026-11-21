import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

abstract class KosRepository {
  Future<List<Kos>> fetchKosTerbaru();
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
  Future<Kos?> fetchKosById(String id) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }
}
