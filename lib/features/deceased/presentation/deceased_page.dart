import 'package:flutter/material.dart';

class DeceasedPage extends StatelessWidget {
  const DeceasedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Almarhum')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Daftar profil dan galeri akan tersedia setelah akun terhubung.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
