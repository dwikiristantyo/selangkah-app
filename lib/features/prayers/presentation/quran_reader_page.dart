import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/quran_repository.dart';

class QuranReaderPage extends StatefulWidget {
  const QuranReaderPage({
    super.key,
    required this.passage,
    required this.initialFontSize,
    required this.initialDarkMode,
  });

  final QuranPassage passage;
  final double initialFontSize;
  final bool initialDarkMode;

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final _repository = QuranRepository();
  late Future<List<QuranVerse>> _versesFuture;
  late double _fontSize;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _versesFuture = _repository.load(widget.passage);
    _fontSize = widget.initialFontSize;
    _darkMode = widget.initialDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final background = _darkMode ? const Color(0xFF18212B) : AppColors.cream;
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(widget.passage.title),
        backgroundColor: background,
        foregroundColor: foreground,
        actions: [
          IconButton(
            tooltip: 'Perkecil teks',
            onPressed: () => setState(
              () => _fontSize = (_fontSize - 2).clamp(18, 40),
            ),
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            tooltip: 'Perbesar teks',
            onPressed: () => setState(
              () => _fontSize = (_fontSize + 2).clamp(18, 40),
            ),
            icon: const Icon(Icons.text_increase),
          ),
          IconButton(
            tooltip: 'Ubah mode baca',
            onPressed: () => setState(() => _darkMode = !_darkMode),
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: FutureBuilder<List<QuranVerse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              message: snapshot.error.toString(),
              onRetry: () => setState(
                () => _versesFuture = _repository.load(widget.passage),
              ),
            );
          }

          final verses = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                widget.passage.description,
                style: TextStyle(color: foreground.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),
              for (final verse in verses)
                _VerseCard(
                  verse: verse,
                  fontSize: _fontSize,
                  foreground: foreground,
                  darkMode: _darkMode,
                ),
              const SizedBox(height: 12),
              Text(
                'Teks Arab, transliterasi, dan terjemahan Indonesia: '
                'Quran.com API (resource terjemahan Kementerian Agama RI).',
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.verse,
    required this.fontSize,
    required this.foreground,
    required this.darkMode,
  });

  final QuranVerse verse;
  final double fontSize;
  final Color foreground;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final surface = darkMode ? const Color(0xFF25313D) : AppColors.ivory;
    return Card(
      color: surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                child: Text(
                  '${verse.verseNumber}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.arabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: foreground,
                  fontSize: fontSize + 4,
                  height: 2,
                ),
              ),
            ),
            if (verse.transliteration.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                verse.transliteration,
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.9),
                  fontSize: fontSize * 0.72,
                  height: 1.65,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (verse.translation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                verse.translation,
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.78),
                  fontSize: fontSize * 0.68,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 40),
              const SizedBox(height: 12),
              Text(
                'Bacaan belum dapat dimuat.\n$message',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
}
