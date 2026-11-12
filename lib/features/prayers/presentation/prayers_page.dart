import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../data/prayer_content_repository.dart';
import '../data/quran_repository.dart';
import 'quran_reader_page.dart';

class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> {
  final _contentRepository = PrayerContentRepository();
  late Future<List<PrayerContent>> _contentsFuture;
  double _fontSize = 24;
  bool _darkMode = false;

  static const _openingPassages = [
    QuranPassage(
      title: 'Al-Fatihah',
      description: 'Surah ke-1 · 7 ayat',
      chapter: 1,
    ),
    QuranPassage(
      title: 'Ali Imran: 185',
      description: 'Kullu nafsin dzā’iqatul-maut',
      chapter: 3,
      verse: 185,
    ),
  ];

  static const _mainPassages = [
    QuranPassage(
      title: 'Surat Yasin',
      description: 'Surah ke-36 · 83 ayat',
      chapter: 36,
    ),
    QuranPassage(
      title: 'Awal Surat Al-Baqarah',
      description: 'Surah ke-2 · ayat 1–5',
      chapter: 2,
      verseCount: 5,
    ),
    QuranPassage(
      title: 'Ayat Kursi',
      description: 'Al-Baqarah: 255',
      chapter: 2,
      verse: 255,
    ),
  ];

  static const _selectedPassages = [
    QuranPassage(
      title: 'Al-Ikhlas',
      description: 'Surah ke-112 · 4 ayat',
      chapter: 112,
    ),
    QuranPassage(
      title: 'Al-Falaq',
      description: 'Surah ke-113 · 5 ayat',
      chapter: 113,
    ),
    QuranPassage(
      title: 'An-Nas',
      description: 'Surah ke-114 · 6 ayat',
      chapter: 114,
    ),
    QuranPassage(
      title: 'Al-Mulk',
      description: 'Surah ke-67 · 30 ayat',
      chapter: 67,
    ),
    QuranPassage(
      title: 'Al-Waqi’ah',
      description: 'Surah ke-56 · 96 ayat',
      chapter: 56,
    ),
    QuranPassage(
      title: 'Ar-Rahman',
      description: 'Surah ke-55 · 78 ayat',
      chapter: 55,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentsFuture = _contentRepository.load();
  }

  @override
  Widget build(BuildContext context) {
    final background = _darkMode ? const Color(0xFF18212B) : AppColors.cream;
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Buku Doa'),
        backgroundColor: background,
        foregroundColor: foreground,
        actions: [
          IconButton(
            tooltip: 'Ubah mode baca',
            onPressed: () => setState(() => _darkMode = !_darkMode),
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _introCard(),
          const SizedBox(height: 18),
          _readerSettings(foreground),
          const SizedBox(height: 18),
          _sectionTitle('Ayat pembuka', 'Kutipan Al-Qur’an'),
          for (final passage in _openingPassages) _passageTile(passage),
          const SizedBox(height: 12),
          _sectionTitle('Bacaan inti', 'Yasin, doa, dan tahlil'),
          for (final passage in _mainPassages) _passageTile(passage),
          _tahlilGuideTile(),
          const SizedBox(height: 12),
          _sectionTitle('Surat pilihan', 'Bacaan pendukung'),
          for (final passage in _selectedPassages) _passageTile(passage),
          const SizedBox(height: 12),
          _sectionTitle(
            'Doa & wirid',
            'Doa Yasin, tahlil, arwah, dan ziarah dari Supabase',
          ),
          _databaseContent(),
          const SizedBox(height: 16),
          _sectionTitle('Rujukan', 'Sumber bacaan'),
          _referenceTile(
            title: 'Qur’an Kemenag',
            subtitle: 'Rujukan resmi untuk memeriksa mushaf dan terjemahan.',
            url: Uri.parse('https://quran.kemenag.go.id/'),
          ),
          _referenceTile(
            title: 'Tahlil & Doa Arwah — Quran NU',
            subtitle: 'Contoh susunan bacaan tahlil yang lazim di Indonesia.',
            url: Uri.parse('https://quran.nu.or.id/tahlil'),
          ),
          _referenceTile(
            title: 'Doa penutup bacaan Al-Qur’an — Quran NU',
            subtitle: 'Rujukan doa setelah pembacaan Al-Qur’an.',
            url: Uri.parse('https://quran.nu.or.id/doa/doa-baca-al-quran'),
          ),
          _referenceTile(
            title: 'Doa Kematian & Ziarah — Quran NU',
            subtitle: 'Doa takziah dan salam ketika ziarah kubur.',
            url: Uri.parse('https://quran.nu.or.id/doa/doa-kematian'),
          ),
          _referenceTile(
            title: 'Asmaul Husna — Quran NU',
            subtitle: 'Rujukan Asmaul Husna dan wirid.',
            url: Uri.parse('https://quran.nu.or.id/wirid/munajat'),
          ),
          const SizedBox(height: 8),
          Text(
            'Susunan tahlil dapat berbeda menurut keluarga dan majelis. '
            'Silakan ikuti panduan guru atau tradisi setempat.',
            style: TextStyle(
              color: foreground.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_rounded, color: AppColors.goldLight, size: 32),
          SizedBox(height: 12),
          Text(
            'Buku Saku Doa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Bacaan Arab, transliterasi Latin, dan terjemahan Indonesia '
            'dengan ukuran teks yang dapat disesuaikan.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _readerSettings(Color foreground) {
    return Card(
      color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.text_fields, color: AppColors.green),
            Expanded(
              child: Slider(
                value: _fontSize,
                min: 18,
                max: 40,
                divisions: 11,
                label: _fontSize.round().toString(),
                onChanged: (value) => setState(() => _fontSize = value),
              ),
            ),
            Text(
              '${_fontSize.round()}',
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: foreground,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: foreground.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passageTile(QuranPassage passage) {
    return Card(
      color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1FC9A052),
          child: Icon(Icons.auto_stories_outlined, color: AppColors.navy),
        ),
        title: Text(
          passage.title,
          style: TextStyle(
            color: _darkMode ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          passage.description,
          style: TextStyle(
            color: _darkMode ? Colors.white70 : AppColors.muted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuranReaderPage(
              passage: passage,
              initialFontSize: _fontSize,
              initialDarkMode: _darkMode,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tahlilGuideTile() {
    return Card(
      color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1F008080),
          child: Icon(Icons.format_list_numbered, color: AppColors.green),
        ),
        title: Text(
          'Mukaddimah & urutan tahlil',
          style: TextStyle(
            color: _darkMode ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Tawasul, surat pendek, zikir, dan doa penutup',
          style: TextStyle(
            color: _darkMode ? Colors.white70 : AppColors.muted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
        onTap: _showTahlilGuide,
      ),
    );
  }

  Widget _databaseContent() {
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return FutureBuilder<List<PrayerContent>>(
      future: _contentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
            child: ListTile(
              title: Text(
                'Konten doa tidak dapat dimuat.',
                style: TextStyle(color: foreground),
              ),
              subtitle: Text(
                '${snapshot.error}',
                style: TextStyle(color: foreground.withValues(alpha: 0.7)),
              ),
              trailing: IconButton(
                tooltip: 'Coba lagi',
                onPressed: () => setState(
                  () => _contentsFuture = _contentRepository.load(),
                ),
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }

        final contents = snapshot.data!;
        if (contents.isEmpty) {
          return Card(
            color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada konten tambahan di prayers_content. Tambahkan '
                'bacaan dengan kategori Yasin, Tahlil, Doa Arwah, atau '
                'Ziarah Kubur agar doa khusus tampil di sini. Bacaan '
                'Al-Qur’an tersedia pada bagian di atas.',
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
            ),
          );
        }

        final groups = <String, List<PrayerContent>>{};
        for (final content in contents) {
          groups.putIfAbsent(content.category, () => []).add(content);
        }
        return Column(
          children: [
            for (final entry in groups.entries)
              Card(
                color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${entry.value.length} bacaan',
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.65),
                    ),
                  ),
                  children: [
                    for (final content in entry.value)
                      _prayerContentTile(content, foreground),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _prayerContentTile(PrayerContent content, Color foreground) {
    return ExpansionTile(
      title: Text(
        content.title,
        style: TextStyle(color: foreground),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        if (content.arabicText.isNotEmpty)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              content.arabicText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: foreground,
                fontSize: _fontSize,
                height: 1.9,
              ),
            ),
          ),
        if (content.latinText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            content.latinText,
            style: TextStyle(
              color: foreground,
              fontSize: _fontSize * 0.72,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (content.translation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            content.translation,
            style: TextStyle(
              color: foreground.withValues(alpha: 0.8),
              fontSize: _fontSize * 0.68,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _referenceTile({
    required String title,
    required String subtitle,
    required Uri url,
  }) {
    return Card(
      color: _darkMode ? const Color(0xFF25313D) : AppColors.ivory,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.link, color: AppColors.green),
        title: Text(
          title,
          style: TextStyle(
            color: _darkMode ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _darkMode ? Colors.white70 : AppColors.muted,
          ),
        ),
        trailing: const Icon(Icons.open_in_new, color: AppColors.gold),
        onTap: () => _openReference(url),
      ),
    );
  }

  Future<void> _showTahlilGuide() {
    final foreground = _darkMode ? Colors.white : AppColors.navy;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _darkMode ? const Color(0xFF18212B) : AppColors.cream,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Panduan ringkas tahlil',
                style: TextStyle(
                  color: foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final step in const [
                'Mukaddimah dan tawasul, lalu membaca Al-Fatihah.',
                'Membaca surat pilihan, seperti Yasin atau surat-surat pendek.',
                'Melanjutkan dengan istighfar, shalawat, tahlil, dan zikir.',
                'Menutup dengan doa untuk almarhum/almarhumah dan keluarga.',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '•  $step',
                    style: TextStyle(color: foreground, height: 1.5),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openReference(Uri.parse('https://quran.nu.or.id/tahlil'));
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Buka rujukan lengkap Quran NU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReference(Uri url) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan rujukan tidak dapat dibuka.')),
      );
    }
  }
}
