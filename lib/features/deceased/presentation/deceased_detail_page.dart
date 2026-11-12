import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../data/deceased_models.dart';
import '../data/deceased_repository.dart';
import 'deceased_form_page.dart';

class DeceasedDetailPage extends StatefulWidget {
  const DeceasedDetailPage({super.key, required this.profileId});

  final String profileId;

  @override
  State<DeceasedDetailPage> createState() => _DeceasedDetailPageState();
}

class _DeceasedDetailPageState extends State<DeceasedDetailPage> {
  final _repository = DeceasedRepository();
  final _picker = ImagePicker();
  late Future<DeceasedProfile> _profileFuture;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getProfile(widget.profileId);
  }

  void _reload() {
    setState(() {
      _errorMessage = null;
      _profileFuture = _repository.getProfile(widget.profileId);
    });
  }

  Future<void> _editProfile(DeceasedProfile profile) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DeceasedFormPage(profile: profile),
      ),
    );
    if (saved == true && mounted) _reload();
  }

  Future<void> _addPhotos(DeceasedProfile profile) async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 2400,
      );
      if (files.isEmpty) return;

      for (var index = 0; index < files.length; index++) {
        await _repository.uploadPhoto(
          deceasedId: profile.id,
          file: files[index],
          isPrimary: profile.photos.isEmpty && index == 0,
        );
      }
      if (mounted) _reload();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Sebagian foto mungkin sudah tersimpan. Periksa galeri dan '
              'coba unggah lagi jika perlu. Detail: $error';
          _profileFuture = _repository.getProfile(widget.profileId);
        });
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(DeceasedPhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus foto?'),
        content: const Text('Foto ini akan dihapus dari galeri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deletePhoto(photo);
      if (mounted) _reload();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kenangan'),
        actions: [
          FutureBuilder<DeceasedProfile>(
            future: _profileFuture,
            builder: (context, snapshot) => IconButton(
              tooltip: 'Ubah profil',
              onPressed:
                  snapshot.hasData ? () => _editProfile(snapshot.data!) : null,
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<DeceasedProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profil tidak dapat dimuat: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildProfileContent(DeceasedProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.goldLight,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lahir: ${AppDateFormatter.dual(profile.birthDate)}\n'
                    'Wafat: ${AppDateFormatter.dual(profile.deathDate)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            if (profile.quote != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          profile.quote!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Galeri Kenangan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${profile.photos.length} foto',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Simpan dan kenang momen-momen berharga.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              _InlineError(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _isUploading ? null : () => _addPhotos(profile),
              icon: _isUploading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _isUploading ? 'Mengunggah foto...' : 'Tambah beberapa foto',
              ),
            ),
            const SizedBox(height: 16),
            if (profile.photos.isEmpty)
              const _EmptyGallery()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 3 : 2;
                  return GridView.builder(
                    itemCount: profile.photos.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) => _PhotoTile(
                      photo: profile.photos[index],
                      repository: _repository,
                      onDelete: () => _deletePhoto(profile.photos[index]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.repository,
    required this.onDelete,
  });

  final DeceasedPhoto photo;
  final DeceasedRepository repository;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<String>(
            future: repository.getPhotoUrl(photo.storagePath),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.hasError) {
                  return const _PhotoLoadError();
                }
                return const Center(child: CircularProgressIndicator());
              }
              return CachedNetworkImage(
                imageUrl: snapshot.data!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const _PhotoLoadError(),
              );
            },
          ),
          if (photo.isPrimary)
            const Positioned(
              left: 8,
              top: 8,
              child: Chip(
                visualDensity: VisualDensity.compact,
                avatar: Icon(Icons.star, size: 16, color: AppColors.gold),
                label: Text('Utama'),
              ),
            ),
          Positioned(
            right: 6,
            top: 6,
            child: IconButton.filledTonal(
              tooltip: 'Hapus foto',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoLoadError extends StatelessWidget {
  const _PhotoLoadError();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF2E8CF),
      child: Center(
        child:
            Icon(Icons.broken_image_outlined, size: 36, color: AppColors.navy),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E1D2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 42,
            color: AppColors.gold,
          ),
          SizedBox(height: 10),
          Text('Belum ada foto di galeri ini.'),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
