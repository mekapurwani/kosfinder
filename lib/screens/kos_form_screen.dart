import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  const KosFormScreen({super.key, this.kos});

  final Kos? kos;

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
  final _roomCountController = TextEditingController();

  bool get _isEdit => widget.kos != null;

  String get _status {
    final roomCount = int.tryParse(_roomCountController.text.trim());
    return roomCount == null || roomCount > 0 ? 'Tersedia' : 'Penuh';
  }

  @override
  void initState() {
    super.initState();
    _roomCountController.addListener(_roomCountChanged);
    final kos = widget.kos;
    if (kos != null) {
      _nameController.text = kos.name;
      _addressController.text = kos.addressArea;
      _priceController.text = kos.monthlyPrice.toStringAsFixed(0);
      _descriptionController.text = kos.description;
      _whatsappController.text = kos.whatsappNumber;
      _roomCountController.text = kos.roomCount.toString();
    } else {
      _roomCountController.text = '0';
    }
  }

  void _roomCountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _roomCountController.removeListener(_roomCountChanged);
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    _roomCountController.dispose();
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

    final roomCount = int.tryParse(_roomCountController.text.trim());
    if (roomCount == null || roomCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah kamar harus berupa angka')),
      );
      return;
    }
    final status = roomCount == 0 ? 'Penuh' : _status;

    final provider = context.read<KosProvider>();
    final success = _isEdit
        ? await provider.updateKos(
            id: widget.kos!.id,
            name: _nameController.text.trim(),
            addressArea: _addressController.text.trim(),
            monthlyPrice: price,
            description: _descriptionController.text.trim(),
            whatsappNumber: _whatsappController.text.trim(),
            status: status,
            roomCount: roomCount,
          )
        : await provider.createKos(
            name: _nameController.text.trim(),
            addressArea: _addressController.text.trim(),
            monthlyPrice: price,
            description: _descriptionController.text.trim(),
            whatsappNumber: _whatsappController.text.trim(),
            status: status,
            roomCount: roomCount,
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
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Kos' : 'Tambah Kos')),
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
                  TextFormField(
                    key: const Key('kos-room-count'),
                    controller: _roomCountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Jumlah kamar',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Jumlah kamar wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    key: const Key('kos-status'),
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _status,
                      key: const Key('kos-status-value'),
                      style: TextStyle(
                        color: _status == 'Tersedia'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                        : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Kos'),
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
