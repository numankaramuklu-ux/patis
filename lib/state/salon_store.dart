import 'package:flutter/foundation.dart';

import '../models/salon_appointment.dart';
import '../models/salon_client.dart';

/// Pet salonu (kuaför) panelinin tüm verisini tutan "depo".
///
/// Randevular ve müşteriler burada toplanır; salon ana ekranı, Randevular ve
/// Müşteriler ekranları aynı kaynaktan beslendiği için veriler tutarlı kalır.
/// Bir randevunun durumu değişince (onay/tamamla/iptal) `notifyListeners()`
/// ile dinleyen tüm ekranlar güncellenir. Şimdilik bellekte; ileride Firebase.
class SalonStore extends ChangeNotifier {
  final List<SalonAppointment> _appointments = _seedAppointments();

  /// Randevuları bugüne göreceli tarihlerle üretir; böylece "Bugün"/"Yarın"
  /// etiketleri ve takvim görünümü her zaman güncel kalır (mock veri).
  static List<SalonAppointment> _seedAppointments() {
    final now = DateTime.now();
    // Saat/dakikayı atıp yalnızca gün bazını alır, sonra gün ekler.
    DateTime day(int addDays) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: addDays));
    return [
      SalonAppointment(
        id: 'a1',
        petName: 'Pamuk',
        breed: 'British Shorthair',
        ownerName: 'Ayşe Y.',
        service: 'Tıraş & Banyo',
        durationMin: 60,
        price: 450,
        date: day(0),
        time: '11:00',
        status: SalonApptStatus.onaylandi,
      ),
      SalonAppointment(
        id: 'a2',
        petName: 'Karamel',
        breed: 'Pomeranian',
        ownerName: 'Mert K.',
        service: 'Tırnak kesimi',
        durationMin: 20,
        price: 120,
        date: day(0),
        time: '13:30',
        status: SalonApptStatus.bekliyor,
      ),
      SalonAppointment(
        id: 'a3',
        petName: 'Lokum',
        breed: 'Maltese',
        ownerName: 'Selin A.',
        service: 'Komple bakım paketi',
        durationMin: 90,
        price: 600,
        date: day(0),
        time: '15:00',
        status: SalonApptStatus.bekliyor,
      ),
      SalonAppointment(
        id: 'a4',
        petName: 'Boncuk',
        breed: 'Tekir',
        ownerName: 'Zeynep A.',
        service: 'Banyo & fön',
        durationMin: 45,
        price: 300,
        date: day(0),
        time: '09:30',
        status: SalonApptStatus.tamamlandi,
      ),
      SalonAppointment(
        id: 'a5',
        petName: 'Şila',
        breed: 'Poodle',
        ownerName: 'Gizem D.',
        service: 'Tıraş (model)',
        durationMin: 75,
        price: 520,
        date: day(1),
        time: '10:00',
        status: SalonApptStatus.onaylandi,
      ),
      SalonAppointment(
        id: 'a6',
        petName: 'Duman',
        breed: 'Pomeranian',
        ownerName: 'Onur B.',
        service: 'Tırnak + kulak temizliği',
        durationMin: 30,
        price: 180,
        date: day(1),
        time: '12:15',
        status: SalonApptStatus.bekliyor,
      ),
      // Takvimi doldurmak için ileri günlere yayılmış randevular.
      SalonAppointment(
        id: 'a7',
        petName: 'Zeytin',
        breed: 'Golden Retriever',
        ownerName: 'Kaan M.',
        service: 'Banyo & fön',
        durationMin: 45,
        price: 350,
        date: day(2),
        time: '14:00',
        status: SalonApptStatus.onaylandi,
      ),
      SalonAppointment(
        id: 'a8',
        petName: 'Maviş',
        breed: 'Scottish Fold',
        ownerName: 'Derya T.',
        service: 'Tırnak kesimi',
        durationMin: 20,
        price: 120,
        date: day(4),
        time: '16:30',
        status: SalonApptStatus.bekliyor,
      ),
      SalonAppointment(
        id: 'a9',
        petName: 'Paşa',
        breed: 'Golden Retriever',
        ownerName: 'Emre S.',
        service: 'Komple bakım paketi',
        durationMin: 90,
        price: 600,
        date: day(6),
        time: '11:30',
        status: SalonApptStatus.onaylandi,
      ),
      SalonAppointment(
        id: 'a10',
        petName: 'Cesur',
        breed: 'Husky',
        ownerName: 'Buse Y.',
        service: 'Tıraş & Banyo',
        durationMin: 80,
        price: 480,
        date: day(9),
        time: '09:00',
        status: SalonApptStatus.bekliyor,
      ),
    ];
  }

  final List<SalonClient> _clients = const [
    SalonClient(
      id: 'c1',
      petName: 'Pamuk',
      breed: 'British Shorthair',
      species: 'Kedi',
      ownerName: 'Ayşe Yılmaz',
      phone: '0532 111 22 33',
      lastVisitLabel: '5 Haziran',
      totalVisits: 14,
      totalSpent: 5200,
      preferredServices: ['Tıraş & Banyo', 'Tırnak kesimi'],
      tag: 'Düzenli',
      note: 'Su sesinden ürküyor, fön sırasında sakin tutulmalı.',
      history: [
        SalonVisit(dateLabel: '5 Haziran', service: 'Tıraş & Banyo', price: 450),
        SalonVisit(dateLabel: '8 Mayıs', service: 'Tırnak kesimi', price: 120),
        SalonVisit(dateLabel: '12 Nisan', service: 'Tıraş & Banyo', price: 420),
      ],
    ),
    SalonClient(
      id: 'c2',
      petName: 'Lokum',
      breed: 'Maltese',
      species: 'Köpek',
      ownerName: 'Selin Acar',
      phone: '0533 444 55 66',
      lastVisitLabel: '1 Haziran',
      totalVisits: 22,
      totalSpent: 9800,
      preferredServices: ['Komple bakım paketi', 'Model tıraş'],
      tag: 'VIP',
      note: 'Yaz boyunca kısa model tıraş tercih ediyor.',
      history: [
        SalonVisit(
            dateLabel: '1 Haziran', service: 'Komple bakım paketi', price: 600),
        SalonVisit(dateLabel: '3 Mayıs', service: 'Model tıraş', price: 520),
        SalonVisit(dateLabel: '2 Nisan', service: 'Banyo & fön', price: 300),
      ],
    ),
    SalonClient(
      id: 'c3',
      petName: 'Duman',
      breed: 'Pomeranian',
      species: 'Köpek',
      ownerName: 'Onur Baş',
      phone: '0535 777 88 99',
      lastVisitLabel: '25 Mayıs',
      totalVisits: 6,
      totalSpent: 1500,
      preferredServices: ['Tırnak kesimi'],
      history: [
        SalonVisit(dateLabel: '25 Mayıs', service: 'Tırnak + kulak', price: 180),
        SalonVisit(dateLabel: '20 Nisan', service: 'Banyo & fön', price: 300),
      ],
    ),
    SalonClient(
      id: 'c4',
      petName: 'Şila',
      breed: 'Poodle',
      species: 'Köpek',
      ownerName: 'Gizem Demir',
      phone: '0536 222 33 44',
      lastVisitLabel: '20 Mayıs',
      totalVisits: 18,
      totalSpent: 7400,
      preferredServices: ['Tıraş (model)', 'Banyo & fön'],
      tag: 'Düzenli',
      note: 'Pati bölgesine dokunulması hassas.',
      history: [
        SalonVisit(dateLabel: '20 Mayıs', service: 'Tıraş (model)', price: 520),
        SalonVisit(dateLabel: '18 Nisan', service: 'Banyo & fön', price: 300),
        SalonVisit(dateLabel: '15 Mart', service: 'Tıraş (model)', price: 500),
      ],
    ),
    SalonClient(
      id: 'c5',
      petName: 'Zeytin',
      breed: 'Golden Retriever',
      species: 'Köpek',
      ownerName: 'Kaan Mutlu',
      phone: '0537 555 66 77',
      lastVisitLabel: '12 Mayıs',
      totalVisits: 4,
      totalSpent: 1300,
      preferredServices: ['Banyo & fön'],
      history: [
        SalonVisit(dateLabel: '12 Mayıs', service: 'Banyo & fön', price: 350),
        SalonVisit(dateLabel: '2 Nisan', service: 'Banyo & fön', price: 350),
      ],
    ),
  ];

  /// Tüm randevular (dışarıdan değiştirilemez).
  List<SalonAppointment> get appointments => List.unmodifiable(_appointments);

  /// Tüm müşteriler.
  List<SalonClient> get clients => List.unmodifiable(_clients);

  /// Bugünün randevuları (ana ekran ve özet için).
  List<SalonAppointment> get todays =>
      _appointments.where((a) => a.dayLabel == 'Bugün').toList();

  /// Bugün iptal edilmemiş randevu sayısı.
  int get todayCount =>
      todays.where((a) => a.status != SalonApptStatus.iptal).length;

  /// Onay bekleyen randevu sayısı (özet kartındaki "bekleyen talep").
  int get pendingCount =>
      _appointments.where((a) => a.status == SalonApptStatus.bekliyor).length;

  /// Bir randevunun durumunu değiştirir (onayla / tamamla / iptal).
  void updateStatus(String id, SalonApptStatus status) {
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i == -1) return;
    _appointments[i] = _appointments[i].copyWith(status: status);
    notifyListeners();
  }
}
