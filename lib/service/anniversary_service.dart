import '../data/model/person.dart';
import '../data/model/schedule.dart';

class AnniversaryService {
  /// Generate recurring anniversary schedules for a specific day.
  ///
  /// [people] List of people to check anniversaries for.
  /// [day] The specific date to check (Year is ignored for matching, used for event date).
  /// [usePersonNamePrefix] If true, titles will be "Name - Title". If false, "Title".
  static List<Schedule> getAnniversariesForDay(
    List<Person> people,
    DateTime day, {
    bool usePersonNamePrefix = true,
  }) {
    final List<Schedule> schedules = [];

    for (final person in people) {
      for (final anniv in person.anniversaries) {
        if (anniv.date.month == day.month && anniv.date.day == day.day) {
          final title = usePersonNamePrefix
              ? '${person.name} - ${anniv.title}'
              : anniv.title;

          schedules.add(
            Schedule(
              id: 'anniv_${anniv.id}_${day.year}',
              title: title,
              startDateTime: day,
              endDateTime: day,
              allDay: true,
              type: ScheduleType.anniversary,
              personIds: [person.id],
              groupId: person.groupId, // Inherit person's group color
              isAnniversary: true,
            ),
          );
        }
      }
    }

    return schedules;
  }
}
