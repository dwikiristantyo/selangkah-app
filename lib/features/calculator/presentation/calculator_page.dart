import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../deceased/data/deceased_models.dart';
import '../../deceased/data/deceased_repository.dart';
import '../../deceased/presentation/deceased_page.dart';
import '../data/memorial_schedule.dart';
import '../data/memorial_schedule_repository.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _deceasedRepository = DeceasedRepository();
  final _scheduleRepository = MemorialScheduleRepository();
  late Future<List<DeceasedProfile>> _profilesFuture;
  Future<List<MemorialSchedule>>? _schedulesFuture;
  String? _selectedProfileId;
  String? _statusMessage;
  bool _isCreatingSchedules = false;
  bool _isEnablingReminders = false;
  bool _showSchedules = false;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _loadProfiles();
  }

  Future<List<DeceasedProfile>> _loadProfiles() async {
    final profiles = await _deceasedRepository.getProfiles();
    if (mounted) {
      final selectedExists = profiles.any(
        (profile) => profile.id == _selectedProfileId,
      );
      final selectedId = selectedExists
          ? _selectedProfileId
          : profiles.isEmpty
              ? null
              : profiles.first.id;
      setState(() {
        _selectedProfileId = selectedId;
        _schedulesFuture = selectedId == null
            ? null
            : _scheduleRepository.getForDeceased(selectedId);
      });
    }
    return profiles;
  }

  Future<void> _reloadProfiles() async {
    setState(() {
      _statusMessage = null;
      _showSchedules = false;
      _profilesFuture = _loadProfiles();
    });
    await _profilesFuture;
  }

  void _selectProfile(String profileId) {
    setState(() {
      _selectedProfileId = profileId;
      _showSchedules = false;
      _statusMessage = null;
      _schedulesFuture = _scheduleRepository.getForDeceased(profileId);
    });
  }

  Future<void> _openProfiles() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const DeceasedPage()),
    );
    if (mounted) await _reloadProfiles();
  }

  Future<void> _createCalculation(DeceasedProfile profile) async {
    setState(() {
      _isCreatingSchedules = true;
      _statusMessage = null;
    });
    try {
      final schedules = await _scheduleRepository.createOrRefreshFor(profile);
      if (!mounted) return;
      setState(() {
        _schedulesFuture = Future.value(schedules);
        _showSchedules = true;
        _statusMessage = 'Jadwal peringatan berhasil disimpan.';
      });
    } catch (error) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal membuat perhitungan: $error');
      }
    } finally {
      if (mounted) setState(() => _isCreatingSchedules = false);
    }
  }

  Future<void> _enableReminders(
    DeceasedProfile profile,
    List<MemorialSchedule> schedules,
  ) async {
    setState(() {
      _isEnablingReminders = true;
      _statusMessage = null;
    });
    try {
      final result = await NotificationService.scheduleReminders(
        reminders: schedules
            .where((schedule) => !schedule.reminderSent)
            .map(
              (schedule) => LocalReminder(
                id: schedule.id,
                title: 'Peringatan ${schedule.eventName}',
                body:
                    'Hari ini jadwal ${schedule.eventName} untuk ${profile.name}. '
                    'Mari iringi dengan doa.',
                date: schedule.targetDate,
              ),
            )
            .toList(growable: false),
      );
      if (!mounted) return;
      setState(() {
        if (!result.isSupported) {
          _statusMessage =
              'Notifikasi lokal tersedia di aplikasi Android/iOS, bukan di Chrome.';
        } else if (!result.permissionGranted) {
          _statusMessage =
              'Izin notifikasi belum diberikan. Aktifkan izin SELANGKAH di pengaturan perangkat.';
        } else if (result.scheduledCount == 0) {
          _statusMessage =
              'Tidak ada tanggal peringatan mendatang untuk dijadwalkan.';
        } else {
          _statusMessage =
              '${result.scheduledCount} pengingat dijadwalkan pukul 09.00 waktu perangkat.';
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal mengaktifkan pengingat: $error');
      }
    } finally {
      if (mounted) setState(() => _isEnablingReminders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Peringatan')),
      body: FutureBuilder<List<DeceasedProfile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reloadProfiles,
            );
          }

          final profiles = snapshot.data ?? const <DeceasedProfile>[];
          if (profiles.isEmpty) return _NoProfiles(onAdd: _openProfiles);

          final selectedProfile = profiles.firstWhere(
            (profile) => profile.id == _selectedProfileId,
            orElse: () => profiles.first,
          );
          return _buildCalculator(selectedProfile, profiles);
        },
      ),
    );
  }

  Widget _buildCalculator(
    DeceasedProfile profile,
    List<DeceasedProfile> profiles,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: profile.id,
          decoration: const InputDecoration(
            labelText: 'Pilih profil almarhum',
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: profiles
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (id) {
            if (id != null) _selectProfile(id);
          },
        ),
        const SizedBox(height: 16),
        _ProfileSummary(profile: profile),
        const SizedBox(height: 22),
        FutureBuilder<List<MemorialSchedule>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: () => _selectProfile(profile.id),
              );
            }

            final schedules = snapshot.data ?? const <MemorialSchedule>[];
            if (schedules.isEmpty) {
              return _CreateCalculationCard(
                isLoading: _isCreatingSchedules,
                onPressed: () => _createCalculation(profile),
              );
            }

            return _SavedCalculationSection(
              schedules: schedules,
              isExpanded: _showSchedules,
              isEnablingReminders: _isEnablingReminders,
              onToggle: () => setState(
                () => _showSchedules = !_showSchedules,
              ),
              onEnableReminders: () => _enableReminders(profile, schedules),
            );
          },
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 16),
          _StatusMessage(message: _statusMessage!),
        ],
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile});

  final DeceasedProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF2E8CF),
              child: Icon(Icons.event_note, color: AppColors.navy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal wafat',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateFormatter.dual(profile.deathDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCalculationCard extends StatelessWidget {
  const _CreateCalculationCard({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 42,
              color: AppColors.gold,
            ),
            const SizedBox(height: 12),
            Text(
              'Perhitungan belum dibuat',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Buat jadwal 1, 3, 7, 40, 100 hari, dan haul berdasarkan '
              'tanggal wafat pada profil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate_outlined),
              label: Text(
                isLoading ? 'Membuat jadwal...' : 'Buat Perhitungan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCalculationSection extends StatelessWidget {
  const _SavedCalculationSection({
    required this.schedules,
    required this.isExpanded,
    required this.isEnablingReminders,
    required this.onToggle,
    required this.onEnableReminders,
  });

  final List<MemorialSchedule> schedules;
  final bool isExpanded;
  final bool isEnablingReminders;
  final VoidCallback onToggle;
  final VoidCallback onEnableReminders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onToggle,
          icon: Icon(isExpanded ? Icons.visibility_off : Icons.event_available),
          label: Text(
            isExpanded ? 'Sembunyikan Perhitungan' : 'Lihat Perhitungan',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: isEnablingReminders ? null : onEnableReminders,
          icon: isEnablingReminders
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_active_outlined),
          label: Text(
            isEnablingReminders ? 'Mengaktifkan...' : 'Aktifkan Pengingat',
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          for (final schedule in schedules) _ScheduleTile(schedule: schedule),
        ],
      ],
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule});

  final MemorialSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      schedule.targetDate.year,
      schedule.targetDate.month,
      schedule.targetDate.day,
    );
    final today = DateUtils.dateOnly(DateTime.now());
    final daysUntil = date.difference(today).inDays;
    final relativeDate = daysUntil == 0
        ? 'Hari ini'
        : daysUntil > 0
            ? '$daysUntil hari lagi'
            : 'Lewat ${daysUntil.abs()} hari';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF2E8CF),
          child: Icon(Icons.event, color: AppColors.navy),
        ),
        title: Text(schedule.eventName),
        subtitle: Text(AppDateFormatter.dual(date)),
        trailing: Text(
          relativeDate,
          style: TextStyle(
            color: daysUntil < 0 ? AppColors.muted : AppColors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NoProfiles extends StatelessWidget {
  const _NoProfiles({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 58,
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            Text(
              'Profil almarhum belum tersedia',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan profil beserta tanggal wafat terlebih dahulu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Buka Profil Almarhum'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              'Data peringatan tidak dapat dimuat',
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

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.navy)),
    );
  }
}
