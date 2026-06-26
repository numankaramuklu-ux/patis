// ReminderService unit testleri.
//
// Yaklaşan randevu ve aşılar için hatırlatma üretildiğini ve aynı kayıt için
// tekrar üretilmediğini (kalıcı anahtar) doğrular. Tarihler bugüne göreceli
// üretilir ki test her gün geçerli kalsın.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petapp/models/appointment.dart';
import 'package:petapp/models/vaccination.dart';
import 'package:petapp/services/reminder_service.dart';
import 'package:petapp/state/appointment_store.dart';
import 'package:petapp/state/notification_store.dart';
import 'package:petapp/state/passport_store.dart';
import 'package:petapp/utils/tr_date.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  String label(int addDays) =>
      formatTrDayMonth(DateTime.now().add(Duration(days: addDays)));

  test('yaklaşan randevu için hatırlatma üretir', () {
    final passport = PassportStore();
    final appointments = AppointmentStore();
    final notifications = NotificationStore();

    appointments.add(
      Appointment(
        title: 'Test Randevu',
        place: 'Test Klinik',
        dateLabel: label(3),
        petId: passport.current.id,
      ),
    );

    ReminderService.sync(
      passport: passport,
      appointments: appointments,
      notifications: notifications,
    );

    expect(
      notifications.hasReminder('appt:Test Randevu:${label(3)}'),
      isTrue,
    );
  });

  test('yaklaşan aşı dozu için hatırlatma üretir', () {
    final passport = PassportStore();
    final appointments = AppointmentStore();
    final notifications = NotificationStore();

    passport.addVaccination(
      Vaccination(
        name: 'TestAsi',
        dateLabel: '1 Ocak 2020',
        nextDueLabel: label(10),
      ),
    );

    ReminderService.sync(
      passport: passport,
      appointments: appointments,
      notifications: notifications,
    );

    final petName = passport.pet.name;
    expect(
      notifications.hasReminder('vacc:$petName:TestAsi:${label(10)}'),
      isTrue,
    );
  });

  test('pencere dışındaki kayıt için hatırlatma üretmez', () {
    final passport = PassportStore();
    final appointments = AppointmentStore();
    final notifications = NotificationStore();

    // 60 gün sonrası: randevu penceresi (7 gün) ve aşı penceresi (30 gün) dışı.
    appointments.add(
      Appointment(
        title: 'Uzak Randevu',
        place: 'Test',
        dateLabel: label(60),
        petId: passport.current.id,
      ),
    );

    ReminderService.sync(
      passport: passport,
      appointments: appointments,
      notifications: notifications,
    );

    expect(notifications.hasReminder('appt:Uzak Randevu:${label(60)}'), isFalse);
  });

  test('aynı kayıt için ikinci kez hatırlatma üretmez (dedup)', () {
    final passport = PassportStore();
    final appointments = AppointmentStore();
    final notifications = NotificationStore();

    appointments.add(
      Appointment(
        title: 'Tekil Randevu',
        place: 'Test',
        dateLabel: label(2),
        petId: passport.current.id,
      ),
    );

    ReminderService.sync(
      passport: passport,
      appointments: appointments,
      notifications: notifications,
    );
    final countAfterFirst = notifications.notifications.length;

    ReminderService.sync(
      passport: passport,
      appointments: appointments,
      notifications: notifications,
    );
    expect(notifications.notifications.length, countAfterFirst);
  });
}
