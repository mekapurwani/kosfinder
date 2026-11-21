import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import 'kos_detail_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({super.key, this.configurationError});

  final String? configurationError;

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  num? get _maxPrice {
    final text = _maxPriceController.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return num.tryParse(text);
  }

  void _applyFilters() {
    context.read<KosProvider>().searchKos(
      _searchController.text,
      maxPrice: _maxPrice,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.configurationError == null) {
        context.read<KosProvider>().loadKos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.hasActiveSession) {
                return IconButton(
                  key: const Key('logout-appbar'),
                  tooltip: 'Logout',
                  onPressed: authProvider.isLoading
                      ? null
                      : () => authProvider.logout(),
                  icon: const Icon(Icons.logout),
                );
              }

              return IconButton(
                key: const Key('open-login'),
                tooltip: 'Login',
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                icon: const Icon(Icons.login),
              );
            },
          ),
          IconButton(
            key: const Key('open-register'),
            tooltip: 'Registrasi',
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: widget.configurationError != null
          ? _MessageView(widget.configurationError!)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        key: const Key('search-field'),
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau lokasi/area',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const Key('max-price-field'),
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Harga maksimum',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Hapus harga maksimum',
                            onPressed: () {
                              _maxPriceController.clear();
                              _applyFilters();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<KosProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return _MessageView(provider.errorMessage!);
                      }

                      if (provider.kos.isEmpty) {
                        return const _MessageView('Kos tidak ditemukan');
                      }

                      return RefreshIndicator(
                        onRefresh: provider.loadKos,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.kos.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final kos = provider.kos[index];
                            return Card(
                              child: ListTile(
                                title: Text(kos.name),
                                subtitle: Text(
                                  '${kos.addressArea}\n'
                                  'Rp${kos.monthlyPrice.toStringAsFixed(0)} '
                                  '/ bulan',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => KosDetailScreen(kos: kos),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
