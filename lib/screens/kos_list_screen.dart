import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kos_provider.dart';
import 'kos_detail_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({super.key, this.configurationError});

  final String? configurationError;

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
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
      appBar: AppBar(title: const Text('KosFinder')),
      body: widget.configurationError != null
          ? _MessageView(widget.configurationError!)
          : Consumer<KosProvider>(
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
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final kos = provider.kos[index];
                      return Card(
                        child: ListTile(
                          title: Text(kos.name),
                          subtitle: Text(
                            '${kos.addressArea}\n'
                            'Rp${kos.monthlyPrice.toStringAsFixed(0)} / bulan',
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
