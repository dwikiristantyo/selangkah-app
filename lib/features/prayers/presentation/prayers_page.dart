import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> {
  double _fontSize = 24;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final background = _darkMode ? const Color(0xFF18212B) : AppColors.cream;
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Buku Doa'),
        backgroundColor: background,
        actions: [
          IconButton(
            tooltip: 'Ubah mode baca',
            onPressed: () => setState(() => _darkMode = !_darkMode),
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        children: [
          Slider(
            value: _fontSize,
            min: 18,
            max: 40,
            divisions: 11,
            label: _fontSize.round().toString(),
            onChanged: (value) => setState(() => _fontSize = value),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Konten Yasin, Tahlil, dan doa akan dimuat dari '
                  'prayers_content setelah data tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: _fontSize,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
