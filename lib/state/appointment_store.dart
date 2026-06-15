import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appointment.dart';

/// Randevuların tutulduğu "depo" (store).
///
/// `ChangeNotifier`'dan türer: içindeki veri değiştiğinde `notifyListeners()`
/// çağırırız, bu depoyu dinleyen ekranlar (Provider aracılığıyla) otomatik
/// yeniden çizilir. Böylece "yeni randevu eklendi" bilgisini ekrana elle
/// taşımamıza gerek kalmaz.
///
/// Randevular `shared_preferences` ile kalıcıdır: uygulama yeniden açıldığında
/// geri yüklenir. İleride Firebase'e bağlayınca bu sınıfın içini gerçek
/// veritabanı çağrılarıyla dolduracağız; ekranlar değişmeden çalışmaya devam eder.
class AppointmentStore extends ChangeNotifier {
  AppointmentStore() {
    _load();
  }

  static const _kAppointments = 'appointments';

  // Başlangıç (mock) randevuları. `_` ile başlaması "dışarıdan doğrudan
  // erişilemez, özeldir" demektir.
  // Varsayılan randevular ilk hayvana (Pamuk, 'p1') bağlıdır.
  final List<Appointment> _appointments = [
    const Appointment(
      title: 'Aşı kontrolü',
      place: 'Patiş Veteriner Kliniği',
      dateLabel: '12 Haziran, 14:30',
      petId: 'p1',
    ),
    const Appointment(
      title: 'Tüy bakımı & tıraş',
      place: 'Minik Patiler Kuaför',
      dateLabel: '18 Haziran, 11:00',
      type: AppointmentType.kuafor,
      petId: 'p1',
    ),
    const Appointment(
      title: 'Genel sağlık kontrolü',
      place: 'Patiş Veteriner Kliniği',
      dateLabel: '2 Temmuz, 16:00',
      petId: 'p1',
    ),
  ];

  /// Ekranların okuyacağı randevu listesi.
  ///
  /// `List.unmodifiable` ile dışarıya değiştirilemez bir kopya veriyoruz:
  /// liste yalnızca [add] gibi metotlarla değişsin, başka yerden yanlışlıkla
  /// bozulmasın istiyoruz.
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  /// Belirli bir hayvana ([PetProfile.id]) ait randevular.
  List<Appointment> appointmentsFor(String petId) =>
      _appointments.where((a) => a.petId == petId).toList();

  /// Listeye yeni bir randevu ekler ve dinleyicileri uyarır.
  void add(Appointment appointment) {
    // En üstte görünsün diye başa ekliyoruz.
    _appointments.insert(0, appointment);
    notifyListeners();
    _persist();
  }

  /// Kayıtlı randevuları diskten yükler (varsa varsayılanların yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAppointments);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
    _appointments
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Randevu listesini JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kAppointments,
      jsonEncode(_appointments.map((a) => a.toJson()).toList()),
    );
  }
}
