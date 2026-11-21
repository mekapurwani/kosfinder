import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('about-appbar'),
        leading: IconButton(
          key: const Key('about-back'),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('About'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '2415051089 - Ni Luh Meka Purwani',
            key: Key('about-identity'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
