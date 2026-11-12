import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/memorial_date_calculator.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  DateTime? _deathDate;

  Future<void> _selectDeathDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deathDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) setState(() => _deathDate = selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final dates = _deathDate == null
        ? const <MemorialDate>[]
        : MemorialDateCalculator.calculate(_deathDate!);
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Peringatan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            onPressed: _selectDeathDate,
            icon: const Icon(Icons.calendar_month),
            label: Text(_deathDate == null
                ? 'Pilih tanggal wafat'
                : 'Tanggal wafat: ${DateFormat.yMMMMd('id').format(_deathDate!)}'),
          ),
          const SizedBox(height: 16),
          for (final memorialDate in dates)
            ListTile(
              title: Text(memorialDate.event.label),
              trailing: Text(
                DateFormat.yMMMMd('id').format(memorialDate.date),
              ),
            ),
        ],
      ),
    );
  }
}
