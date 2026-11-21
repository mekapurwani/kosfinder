import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/kos_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_screen.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = SupabaseConfig.fromEnvironment();
  if (config.isConfigured) {
    await Supabase.initialize(url: config.url, publishableKey: config.anonKey);
  }

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.config = const SupabaseConfig(url: '', anonKey: ''),
  });

  final SupabaseConfig config;

  @override
  Widget build(BuildContext context) {
    final authRepository = config.isConfigured
        ? SupabaseAuthRepository(Supabase.instance.client)
        : const MissingAuthRepository();
    final repository = config.isConfigured
        ? SupabaseKosRepository(Supabase.instance.client)
        : const MissingSupabaseKosRepository();
    final provider = KosProvider(repository: repository);

    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: MaterialApp(
        title: 'KosFinder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: KosListScreen(
          configurationError: config.isConfigured
              ? null
              : 'Konfigurasi Supabase belum tersedia. Jalankan aplikasi '
                    'menggunakan --dart-define.',
        ),
      ),
    );
  }
}
