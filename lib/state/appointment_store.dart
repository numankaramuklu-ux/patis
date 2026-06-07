import 'package:flutter/foundation.dart';

import '../models/appointment.dart';

/// Randevuların tutulduğu "depo" (store).
///
/// `ChangeNotifier`'dan türer: içindeki veri değiştiğinde `notifyListeners()`
/// çağırırız, bu depoyu dinleyen ekranlar (Provider aracılığıyla) otomatik
/// yeniden çizilir. Böylece "yeni randevu eklendi" bilgisini ekrana elle
/// taşımamıza gerek kalmaz.
///
/// Şimdilik veriler bellekte (uygulama kapanınca sıfırlanır). İleride Firebase'e
/// bağlayınca bu sınıfın içini gerçek veritabanı çağrılarıyla dolduracağız;
/// ekranlar değişmeden çalışmaya devam eder.
class AppointmentStore extends ChangeNotifier {
  // Başlangıç (mock) randevuları. `_` ile başlaması "dışarıdan doğrudan
  // erişilemez, özeldir" demektir.
  final List<Appointment> _appointments = [
    const Appointment(
      title: 'Aşı kontrolü',
      place: 'Patiş Veteriner Kliniği',
      dateLabel: '12 Haziran, 14:30',
    ),
    const Appointment(
      title: 'Tüy bakımı & tıraş',
      place: 'Minik Patiler Kuaför',
      dateLabel: '18 Haziran, 11:00',
      type: AppointmentType.kuafor,
    ),
    const Appointment(
      title: 'Genel sağlık kontrolü',
      place: 'Patiş Veteriner Kliniği',
      dateLabel: '2 Temmuz, 16:00',
    ),
  ];

  /// Ekranların okuyacağı randevu listesi.
  ///
  /// `List.unmodifiable` ile dışarıya değiştirilemez bir kopya veriyoruz:
  /// liste yalnızca [add] gibi metotlarla değişsin, başka yerden yanlışlıkla
  /// bozulmasın istiyoruz.
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  /// Listeye yeni bir randevu ekler ve dinleyicileri uyarır.
  void add(Appointment appointment) {
    // En üstte görünsün diye başa ekliyoruz.
    _appointments.insert(0, appointment);
    notifyListeners();
  }
}
