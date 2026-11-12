import 'package:flutter/material.dart';

import '../../../core/utils/app_date_formatter.dart';
import '../data/deceased_models.dart';
import '../data/deceased_repository.dart';

class DeceasedFormPage extends StatefulWidget {
  const DeceasedFormPage({super.key, this.profile});

  final DeceasedProfile? profile;

  @override
  State<DeceasedFormPage> createState() => _DeceasedFormPageState();
}

class _DeceasedFormPageState extends State<DeceasedFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DeceasedRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _quoteController;
  late DateTime? _birthDate;
  late DateTime? _deathDate;
  bool _isSubmitting = false;
  bool _showDateErrors = false;
  String? _errorMessage;

  bool get _hasDateOrderError =>
      _birthDate != null &&
      _deathDate != null &&
      _deathDate!.isBefore(_birthDate!);

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile?.name);
    _quoteController = TextEditingController(text: profile?.quote);
    _birthDate = profile?.birthDate;
    _deathDate = profile?.deathDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isBirthDate}) async {
    final now = DateTime.now();
    final selected = isBirthDate ? _birthDate : _deathDate;
    final date = await showDatePicker(
      context: context,
      initialDate: selected ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date == null) return;
    setState(() {
      if (isBirthDate) {
        _birthDate = date;
      } else {
        _deathDate = date;
      }
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    final formIsValid = _formKey.currentState!.validate();
    setState(() {
      _showDateErrors = true;
      _errorMessage = null;
    });
    if (!formIsValid ||
        _birthDate == null ||
        _deathDate == null ||
        _hasDateOrderError) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final existing = widget.profile;
      if (existing == null) {
        await _repository.createProfile(
          name: _nameController.text,
          birthDate: _birthDate!,
          deathDate: _deathDate!,
          quote: _quoteController.text,
        );
      } else {
        await _repository.updateProfile(
          id: existing.id,
          name: _nameController.text,
          birthDate: _birthDate!,
          deathDate: _deathDate!,
          quote: _quoteController.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return AppDateFormatter.dual(date);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ubah Profil' : 'Tambah Profil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Data kenangan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informasi ini hanya dapat dikelola oleh akun Anda.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: 18),
                _DatePickerField(
                  label: 'Tanggal lahir',
                  value: _formatDate(_birthDate),
                  error: _showDateErrors && _birthDate == null
                      ? 'Pilih tanggal lahir.'
                      : null,
                  icon: Icons.cake_outlined,
                  onPressed: () => _selectDate(isBirthDate: true),
                ),
                const SizedBox(height: 18),
                _DatePickerField(
                  label: 'Tanggal wafat',
                  value: _formatDate(_deathDate),
                  error: _showDateErrors && _deathDate == null
                      ? 'Pilih tanggal wafat.'
                      : _showDateErrors && _hasDateOrderError
                          ? 'Tanggal wafat tidak boleh sebelum tanggal lahir.'
                          : null,
                  icon: Icons.event_outlined,
                  onPressed: () => _selectDate(isBirthDate: false),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _quoteController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Kutipan atau kenangan (opsional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.format_quote_rounded),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _save,
                  icon: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Profil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
    this.error,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: BorderSide(
              color: error == null
                  ? Theme.of(context).colorScheme.outlineVariant
                  : Theme.of(context).colorScheme.error,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
