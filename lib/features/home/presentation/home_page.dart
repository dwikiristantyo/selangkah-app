import 'package:flutter/material.dart';

import '../../auth/data/auth_repository.dart';
import '../../calculator/presentation/calculator_page.dart';
import '../../deceased/presentation/deceased_page.dart';
import '../../prayers/presentation/prayers_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELANGKAH'),
        actions: [
          TextButton(
            onPressed: () => AuthRepository().signOut(),
            child: const Text('Keluar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Mengalirkan Doa di Setiap Langkah',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Kenang dengan kasih, iringi dengan doa.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.event,
            title: 'Kalkulator Peringatan',
            subtitle: 'Hitung 1, 3, 7, 40, 100 hari, dan haul.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CalculatorPage(),
              ),
            ),
          ),
          _FeatureCard(
            icon: Icons.people_alt_outlined,
            title: 'Profil Almarhum',
            subtitle: 'Kelola profil dan kenangan keluarga.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DeceasedPage(),
              ),
            ),
          ),
          _FeatureCard(
            icon: Icons.menu_book_outlined,
            title: 'Buku Doa',
            subtitle: 'Baca Yasin, Tahlil, dan doa lainnya.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrayersPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
