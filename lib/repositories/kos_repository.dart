import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

abstract class KosRepository {
  Future<List<Kos>> fetchKosTerbaru();
}

class SupabaseKosRepository implements KosRepository {
  const SupabaseKosRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    final rows = await client
        .from('kos')
        .select('id, name, address_area, monthly_price')
        .order('created_at', ascending: false);

    return rows
        .map((row) => Kos.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }
}

class MissingSupabaseKosRepository implements KosRepository {
  const MissingSupabaseKosRepository();

  @override
  Future<List<Kos>> fetchKosTerbaru() async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }
}
