import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_date_formatter.dart';
import '../data/deceased_models.dart';
import '../data/deceased_repository.dart';
import 'deceased_detail_page.dart';
import 'deceased_form_page.dart';

class DeceasedPage extends StatefulWidget {
  const DeceasedPage({super.key});

  @override
  State<DeceasedPage> createState() => _DeceasedPageState();
}

class _DeceasedPageState extends State<DeceasedPage> {
  final _repository = DeceasedRepository();
  late Future<List<DeceasedProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _repository.getProfiles();
  }

  Future<void> _refresh() async {
    final future = _repository.getProfiles();
    setState(() {
      _profilesFuture = future;
    });
    await future;
  }

  Future<void> _openForm({DeceasedProfile? profile}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DeceasedFormPage(profile: profile),
      ),
    );
    if (mounted) await _refresh();
  }

  Future<void> _deleteProfile(DeceasedProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus profil?'),
        content: Text(
          'Profil ${profile.name} beserta foto-fotonya akan dihapus.',
        ),
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
      await _repository.deleteProfile(profile);
      if (!mounted) return;
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil dihapus.')),
        );
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Almarhum'),
        actions: [
          IconButton(
            tooltip: 'Tambah profil',
            onPressed: () => _openForm(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Profil'),
      ),
      body: FutureBuilder<List<DeceasedProfile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final profiles = snapshot.data ?? const <DeceasedProfile>[];
          if (profiles.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 100),
                  Icon(
                    Icons.photo_album_outlined,
                    size: 64,
                    color: Color(0xFFC9A052),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada profil kenangan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan profil untuk menyimpan tanggal penting, '
                    'kutipan, dan foto.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: profiles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return _ProfileCard(
                  profile: profile,
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeceasedDetailPage(profileId: profile.id),
                      ),
                    );
                    if (mounted) await _refresh();
                  },
                  onEdit: () => _openForm(profile: profile),
                  onDelete: () => _deleteProfile(profile),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final DeceasedProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final photo = profile.photos.where((item) => item.isPrimary).firstOrNull ??
        profile.photos.firstOrNull;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              _ProfileAvatar(photo: photo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lahir: ${AppDateFormatter.dual(profile.birthDate, abbreviated: true)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wafat: ${AppDateFormatter.dual(profile.deathDate, abbreviated: true)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (profile.quote != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.quote!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                    if (profile.photos.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${profile.photos.length} foto',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_ProfileAction>(
                tooltip: 'Aksi profil',
                onSelected: (action) {
                  if (action == _ProfileAction.edit) onEdit();
                  if (action == _ProfileAction.delete) onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ProfileAction.edit,
                    child: Text('Ubah profil'),
                  ),
                  PopupMenuItem(
                    value: _ProfileAction.delete,
                    child: Text('Hapus profil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProfileAction { edit, delete }

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photo});

  final DeceasedPhoto? photo;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: Color(0xFFF2E8CF),
        child: Icon(Icons.person_outline, size: 34, color: Color(0xFF18365D)),
      );
    }

    return FutureBuilder<String>(
      future: DeceasedRepository().getPhotoUrl(photo!.storagePath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFF2E8CF),
            child: Icon(Icons.broken_image_outlined, color: Color(0xFF18365D)),
          );
        }
        if (!snapshot.hasData) {
          return const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFF2E8CF),
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: snapshot.data!,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            placeholder: (_, __) => const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFF2E8CF),
            ),
            errorWidget: (_, __, ___) => const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFF2E8CF),
              child:
                  Icon(Icons.broken_image_outlined, color: Color(0xFF18365D)),
            ),
          ),
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Profil belum dapat dimuat',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
