import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';
import 'kos_form_screen.dart';

class OwnerKosListScreen extends StatefulWidget {
  const OwnerKosListScreen({super.key});

  @override
  State<OwnerKosListScreen> createState() => _OwnerKosListScreenState();
}

class _OwnerKosListScreenState extends State<OwnerKosListScreen> {
  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KosProvider>().loadOwnedKos();
      }
    });
  }

  Future<void> _openForm() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const KosFormScreen()));
    if (mounted) {
      await context.read<KosProvider>().loadOwnedKos();
    }
  }

  Future<void> _openEditForm(Kos kos) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => KosFormScreen(kos: kos)));
    if (mounted) {
      await context.read<KosProvider>().loadOwnedKos();
    }
  }

  Future<void> _confirmDelete(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        key: const Key('delete-kos-dialog'),
        title: const Text('Hapus Kos'),
        content: Text('Hapus "${kos.name}" secara permanen?'),
        actions: [
          TextButton(
            key: const Key('cancel-delete-kos'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm-delete-kos'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider = context.read<KosProvider>();
    final success = await provider.deleteKos(kos.id);
    if (!mounted) {
      return;
    }

    if (success) {
      await provider.loadOwnedKos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Tidak dapat menghapus kos.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('owner-kos-appbar'),
        leading: IconButton(
          key: const Key('owner-kos-back'),
          tooltip: 'Kembali',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Kos Saya'),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-kos'),
        onPressed: _openForm,
        tooltip: 'Tambah Kos',
        child: const Icon(Icons.add),
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (provider.ownedKos.isEmpty) {
            return const Center(child: Text('Belum ada kos'));
          }

          return RefreshIndicator(
            onRefresh: provider.loadOwnedKos,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.ownedKos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final kos = provider.ownedKos[index];
                return Card(
                  child: ListTile(
                    key: Key('owned-kos-${kos.id}'),
                    title: Text(kos.name),
                    subtitle: Text(
                      '${kos.addressArea}\n'
                      'Rp${kos.monthlyPrice.toStringAsFixed(0)} / bulan',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(kos.status),
                        const SizedBox(width: 8),
                        IconButton(
                          key: Key('edit-kos-${kos.id}'),
                          tooltip: 'Edit Kos',
                          onPressed: () => _openEditForm(kos),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          key: Key('delete-kos-${kos.id}'),
                          tooltip: 'Hapus Kos',
                          onPressed: () => _confirmDelete(kos),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
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
