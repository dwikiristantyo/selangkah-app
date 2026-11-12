import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/utils/memorial_date_calculator.dart';
import '../../deceased/data/deceased_models.dart';
import 'memorial_schedule.dart';

class MemorialScheduleRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<MemorialSchedule>> getForDeceased(String deceasedId) async {
    final response = await _client
        .from('memorial_schedules')
        .select()
        .eq('deceased_id', deceasedId)
        .order('target_date');
    return List<Map<String, dynamic>>.from(response)
        .map(MemorialSchedule.fromMap)
        .toList(growable: false);
  }

  Future<List<MemorialSchedule>> createOrRefreshFor(
    DeceasedProfile profile,
  ) async {
    final calculated = MemorialDateCalculator.calculate(profile.deathDate);
    final existing = await _client
        .from('memorial_schedules')
        .select('event_name, target_date')
        .eq('deceased_id', profile.id);
    final rowsByEvent = <String, Map<String, dynamic>>{
      for (final row in List<Map<String, dynamic>>.from(existing))
        row['event_name'] as String: row,
    };

    final rowsToCreate = <Map<String, dynamic>>[];
    for (final memorialDate in calculated) {
      final row = rowsByEvent[memorialDate.event.label];
      final targetDate = DateFormat('yyyy-MM-dd').format(memorialDate.date);
      if (row == null) {
        rowsToCreate.add({
          'deceased_id': profile.id,
          'event_name': memorialDate.event.label,
          'target_date': targetDate,
          'reminder_sent': false,
        });
      } else if (row['target_date'] != targetDate) {
        await _client
            .from('memorial_schedules')
            .update({'target_date': targetDate, 'reminder_sent': false})
            .eq('deceased_id', profile.id)
            .eq('event_name', memorialDate.event.label);
      }
    }

    if (rowsToCreate.isNotEmpty) {
      await _client.from('memorial_schedules').insert(rowsToCreate);
    }
    return getForDeceased(profile.id);
  }
}
