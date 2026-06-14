import 'package:flutter/foundation.dart';

import '../models/vet_appointment.dart';
import '../models/vet_patient.dart';

/// Veteriner kliniği panelinin tüm verisini tutan "depo".
///
/// Randevular ve hastalar burada toplanır; veteriner ana ekranı, Randevular ve
/// Hastalar ekranları aynı kaynaktan beslenir. Bir randevunun durumu değişince
/// dinleyen tüm ekranlar güncellenir. Şimdilik bellekte; ileride Firebase.
class VetStore extends ChangeNotifier {
  final List<VetAppointment> _appointments = [
    const VetAppointment(
      id: 'v1',
      petName: 'Boncuk',
      breed: 'Tekir',
      ownerName: 'Zeynep A.',
      type: VetApptType.asi,
      reason: 'Kuduz aşısı',
      durationMin: 20,
      price: 350,
      dayLabel: 'Bugün',
      time: '09:30',
      status: VetApptStatus.tamamlandi,
    ),
    const VetAppointment(
      id: 'v2',
      petName: 'Max',
      breed: 'Golden Retriever',
      ownerName: 'Can D.',
      type: VetApptType.kontrol,
      reason: 'Genel kontrol',
      durationMin: 30,
      price: 400,
      dayLabel: 'Bugün',
      time: '11:00',
      status: VetApptStatus.onaylandi,
    ),
    const VetAppointment(
      id: 'v3',
      petName: 'Limon',
      breed: 'Muhabbet kuşu',
      ownerName: 'Elif T.',
      type: VetApptType.kontrol,
      reason: 'Tüy dökülmesi şikayeti',
      durationMin: 25,
      price: 300,
      dayLabel: 'Bugün',
      time: '13:30',
      status: VetApptStatus.bekliyor,
    ),
    const VetAppointment(
      id: 'v4',
      petName: 'Karamel',
      breed: 'Pomeranian',
      ownerName: 'Derya K.',
      type: VetApptType.operasyon,
      reason: 'Kısırlaştırma',
      durationMin: 90,
      price: 2500,
      dayLabel: 'Bugün',
      time: '15:00',
      status: VetApptStatus.bekliyor,
    ),
    const VetAppointment(
      id: 'v5',
      petName: 'Zeytin',
      breed: 'British Shorthair',
      ownerName: 'Burak S.',
      type: VetApptType.acil,
      reason: 'Kusma & halsizlik',
      durationMin: 40,
      price: 600,
      dayLabel: 'Yarın',
      time: '10:15',
      status: VetApptStatus.onaylandi,
    ),
    const VetAppointment(
      id: 'v6',
      petName: 'Pamuk',
      breed: 'Van kedisi',
      ownerName: 'Sena Y.',
      type: VetApptType.asi,
      reason: 'Karma aşı (4\'lü)',
      durationMin: 20,
      price: 320,
      dayLabel: 'Yarın',
      time: '12:00',
      status: VetApptStatus.bekliyor,
    ),
  ];

  final List<VetPatient> _patients = const [
    VetPatient(
      id: 'p1',
      petName: 'Boncuk',
      species: 'Kedi',
      breed: 'Tekir',
      ageLabel: '3 yaşında',
      weightKg: 4.2,
      ownerName: 'Zeynep Aydın',
      phone: '0532 111 22 33',
      lastVisitLabel: '2 Haziran',
      totalVisits: 9,
      nextVaccineLabel: '10 Ağustos',
      allergies: ['Tavuk proteini'],
      tag: 'Düzenli',
      note: 'İğneden çok korkuyor, sakinleştirilerek yapılmalı.',
      vaccinations: [
        VetVaccination(
            name: 'Kuduz', dateLabel: '2 Haziran', nextDueLabel: '2 Haz 2027'),
        VetVaccination(
            name: 'Karma (4\'lü)',
            dateLabel: '10 Şubat',
            nextDueLabel: '10 Ağustos'),
      ],
      treatments: [
        VetTreatment(
            dateLabel: '2 Haziran',
            title: 'Kuduz aşısı',
            note: 'Reaksiyon gözlenmedi'),
        VetTreatment(
            dateLabel: '14 Nisan',
            title: 'Diş taşı temizliği',
            note: 'Hafif diş eti iltihabı, ağız bakımı önerildi'),
      ],
    ),
    VetPatient(
      id: 'p2',
      petName: 'Max',
      species: 'Köpek',
      breed: 'Golden Retriever',
      ageLabel: '5 yaşında',
      weightKg: 31.5,
      ownerName: 'Can Demir',
      phone: '0533 444 55 66',
      lastVisitLabel: '28 Mayıs',
      totalVisits: 16,
      nextVaccineLabel: '20 Temmuz',
      allergies: ['Polen'],
      tag: 'Kronik',
      note: 'Kalça displazisi takibi sürüyor.',
      vaccinations: [
        VetVaccination(
            name: 'Karma', dateLabel: '20 Ocak', nextDueLabel: '20 Temmuz'),
        VetVaccination(
            name: 'Kuduz', dateLabel: '20 Ocak', nextDueLabel: '20 Oca 2027'),
      ],
      treatments: [
        VetTreatment(
            dateLabel: '28 Mayıs',
            title: 'Genel kontrol',
            note: 'Kilo takibi, eklem desteği reçete edildi'),
        VetTreatment(
            dateLabel: '3 Mart', title: 'Kan tahlili', note: 'Değerler normal'),
      ],
    ),
    VetPatient(
      id: 'p3',
      petName: 'Limon',
      species: 'Kuş',
      breed: 'Muhabbet kuşu',
      ageLabel: '1 yaşında',
      weightKg: 0.04,
      ownerName: 'Elif Tuna',
      phone: '0535 777 88 99',
      lastVisitLabel: '15 Mayıs',
      totalVisits: 3,
      vaccinations: [],
      treatments: [
        VetTreatment(
            dateLabel: '15 Mayıs',
            title: 'Tüy dökülmesi muayenesi',
            note: 'Beslenme düzenlemesi önerildi'),
      ],
    ),
    VetPatient(
      id: 'p4',
      petName: 'Karamel',
      species: 'Köpek',
      breed: 'Pomeranian',
      ageLabel: '2 yaşında',
      weightKg: 3.1,
      ownerName: 'Derya Kaya',
      phone: '0536 222 33 44',
      lastVisitLabel: '1 Mayıs',
      totalVisits: 6,
      nextVaccineLabel: '1 Eylül',
      tag: 'Düzenli',
      vaccinations: [
        VetVaccination(
            name: 'Karma', dateLabel: '1 Mart', nextDueLabel: '1 Eylül'),
      ],
      treatments: [
        VetTreatment(dateLabel: '1 Mayıs', title: 'Ön kısırlaştırma kontrolü'),
      ],
    ),
    VetPatient(
      id: 'p5',
      petName: 'Zeytin',
      species: 'Kedi',
      breed: 'British Shorthair',
      ageLabel: '4 yaşında',
      weightKg: 5.0,
      ownerName: 'Burak Sönmez',
      phone: '0537 555 66 77',
      lastVisitLabel: '10 Mayıs',
      totalVisits: 11,
      nextVaccineLabel: '5 Ekim',
      allergies: ['Balık'],
      vaccinations: [
        VetVaccination(
            name: 'Karma', dateLabel: '5 Nisan', nextDueLabel: '5 Ekim'),
      ],
      treatments: [
        VetTreatment(
            dateLabel: '10 Mayıs',
            title: 'Mide rahatsızlığı',
            note: 'Diyet maması ve probiyotik verildi'),
      ],
    ),
  ];

  /// Tüm randevular.
  List<VetAppointment> get appointments => List.unmodifiable(_appointments);

  /// Tüm hastalar.
  List<VetPatient> get patients => List.unmodifiable(_patients);

  /// Bugünün randevuları.
  List<VetAppointment> get todays =>
      _appointments.where((a) => a.dayLabel == 'Bugün').toList();

  /// Bugün iptal edilmemiş randevu sayısı.
  int get todayCount =>
      todays.where((a) => a.status != VetApptStatus.iptal).length;

  /// Onay bekleyen randevu sayısı.
  int get pendingCount =>
      _appointments.where((a) => a.status == VetApptStatus.bekliyor).length;

  /// Bir randevunun durumunu değiştirir.
  void updateStatus(String id, VetApptStatus status) {
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i == -1) return;
    _appointments[i] = _appointments[i].copyWith(status: status);
    notifyListeners();
  }
}
