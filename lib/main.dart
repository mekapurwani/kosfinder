import 'package:flutter/material.dart';

import 'dart:async';

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/kos_provider.dart';
import 'providers/auth_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/owner_kos_list_screen.dart';
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
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: MaterialApp(
        title: 'KosFinder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: Colors.indigo,
            secondary: Colors.teal,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.indigo.withValues(alpha: 0.12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.indigo.withValues(alpha: 0.20),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        routes: {
          '/register': (_) => const RegisterScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const KosListScreen(),
          '/owner': (_) => const _OwnerRouteGuard(),
        },
        home: _AuthGate(
          authRepository: authRepository,
          configurationError: config.isConfigured
              ? null
              : 'Konfigurasi Supabase belum tersedia. Jalankan aplikasi '
                    'menggunakan --dart-define.',
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.authRepository, this.configurationError});

  final AuthRepository authRepository;
  final String? configurationError;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final StreamSubscription<bool> _sessionSubscription;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = widget.authRepository.hasActiveSession;
    context.read<AuthProvider>().restoreSession();
    _sessionSubscription = widget.authRepository.sessionChanges.listen((
      isActive,
    ) {
      if (isActive) {
        _wasAuthenticated = true;
      } else if (_wasAuthenticated && mounted) {
        _wasAuthenticated = false;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KosListScreen(configurationError: widget.configurationError);
  }
}

class _OwnerRouteGuard extends StatelessWidget {
  const _OwnerRouteGuard();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (!authProvider.hasActiveSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!(authProvider.profile?.isPemilikKos ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const OwnerKosListScreen();
  }
}
