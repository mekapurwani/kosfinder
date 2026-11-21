import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  const KosFormScreen({super.key});

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _status = 'Tersedia';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final price = num.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harga harus berupa angka')));
      return;
    }

    final provider = context.read<KosProvider>();
    final success = await provider.createKos(
      name: _nameController.text.trim(),
      addressArea: _addressController.text.trim(),
      monthlyPrice: price,
      description: _descriptionController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      status: _status,
    );

    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Tidak dapat menambah kos.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kos')),
      body: Consumer<KosProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('kos-name'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kos',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama kos wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('kos-address'),
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat/Area',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Alamat/area wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('kos-price'),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Harga per bulan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Harga wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('kos-description'),
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi singkat',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('kos-whatsapp'),
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nomor WhatsApp wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('kos-status'),
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Tersedia',
                        child: Text('Tersedia'),
                      ),
                      DropdownMenuItem(value: 'Penuh', child: Text('Penuh')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('save-kos'),
                    onPressed: provider.isLoading ? null : _save,
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Kos'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
