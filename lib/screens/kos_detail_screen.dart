import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/kos.dart';
import '../widgets/status_badge.dart';

class KosDetailScreen extends StatelessWidget {
  const KosDetailScreen({super.key, required this.kos});

  final Kos kos;

  Future<void> _openWhatsApp(BuildContext context) async {
    final opened = await launchUrl(
      kos.whatsappUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak dapat dibuka.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  kos.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              StatusBadge(status: kos.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(kos.addressArea),
          const SizedBox(height: 8),
          Text(
            'Rp${kos.monthlyPrice.toStringAsFixed(0)} / bulan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(kos.description),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openWhatsApp(context),
            icon: const Icon(Icons.chat),
            label: const Text('Hubungi Pemilik'),
          ),
        ],
      ),
    );
  }
}
