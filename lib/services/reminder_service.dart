import '../models/app_notification.dart';
import '../state/appointment_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import '../utils/tr_date.dart';

/// Yaklaşan aşı ve randevular için otomatik hatırlatma bildirimleri üretir.
///
/// Oturum açıkken (ana ekran ilk kurulduğunda) bir kez çalışır. Her kayıt için
/// benzersiz bir anahtar üretip [NotificationStore]'a verir; aynı aşı/randevu
/// için tekrar bildirim oluşmaz (anahtarlar kalıcı tutulur). Tarihler Türkçe
/// etiketlerden [parseTrDate] ile çözülür.
class ReminderService {
  const ReminderService._();

  /// Randevular için pencere: bugünden itibaren bu kadar gün içindekiler.
  static const _appointmentWindowDays = 7;

  /// Aşılar için pencere (daha uzun, çünkü plan yapmak gerekir).
  static const _vaccineWindowDays = 30;

  /// Yaklaşan aşı/randevuları tarar ve gerekli hatırlatmaları ekler.
  static void sync({
    required PassportStore passport,
    required AppointmentStore appointments,
    required NotificationStore notifications,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Randevu kartında pet adını gösterebilmek için kimlik → ad eşlemesi.
    final petNameById = {
      for (final p in passport.pets) p.id: p.pet.name,
    };

    // ---- Randevular ----
    for (final appt in appointments.appointments) {
      // "12 Haziran, 14:30" → tarih kısmı "12 Haziran".
      final datePart = appt.dateLabel.split(',').first.trim();
      final date = parseTrDate(datePart, now: now);
      if (date == null) continue;
      final days = DateTime(date.year, date.month, date.day)
          .difference(today)
          .inDays;
      if (days < 0 || days > _appointmentWindowDays) continue;

      final petName = appt.petId != null ? petNameById[appt.petId] : null;
      final who = petName != null ? '$petName • ' : '';
      notifications.addReminder(
        key: 'appt:${appt.title}:${appt.dateLabel}',
        notification: AppNotification(
          kind: NotificationKind.appointment,
          title: 'Yaklaşan randevu',
          body: '$who${appt.title} ${_whenLabel(days)} '
              '(${appt.dateLabel} • ${appt.place}).',
          timeAgo: 'Az önce',
        ),
      );
    }

    // ---- Aşılar (sonraki doz) ----
    for (final profile in passport.pets) {
      for (final vac in profile.vaccinations) {
        final due = vac.nextDueLabel;
        if (due == null || due.trim().isEmpty) continue;
        final date = parseTrDate(due, now: now);
        if (date == null) continue;
        final days = DateTime(date.year, date.month, date.day)
            .difference(today)
            .inDays;
        if (days < 0 || days > _vaccineWindowDays) continue;

        notifications.addReminder(
          key: 'vacc:${profile.pet.name}:${vac.name}:$due',
          notification: AppNotification(
            kind: NotificationKind.appointment,
            title: 'Aşı zamanı yaklaşıyor',
            body: '${profile.pet.name} için ${vac.name} aşısının sonraki dozu '
                '${_whenLabel(days)} ($due).',
            timeAgo: 'Az önce',
          ),
        );
      }
    }
  }

  /// Gün farkını insan diline çevirir.
  static String _whenLabel(int days) {
    if (days <= 0) return 'bugün';
    if (days == 1) return 'yarın';
    return '$days gün sonra';
  }
}
