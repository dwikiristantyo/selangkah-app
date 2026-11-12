import 'package:flutter_test/flutter_test.dart';
import 'package:selangkah/features/calculator/data/memorial_schedule.dart';

void main() {
  test('maps a Supabase memorial schedule row', () {
    final schedule = MemorialSchedule.fromMap({
      'id': 'schedule-1',
      'deceased_id': 'deceased-1',
      'event_name': '40 Hari',
      'target_date': '2024-06-11',
      'reminder_sent': false,
    });

    expect(schedule.id, 'schedule-1');
    expect(schedule.deceasedId, 'deceased-1');
    expect(schedule.eventName, '40 Hari');
    expect(schedule.targetDate, DateTime(2024, 6, 11));
    expect(schedule.reminderSent, isFalse);
  });
}
