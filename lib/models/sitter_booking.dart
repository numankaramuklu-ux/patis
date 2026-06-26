import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Bir pet sitter konaklama (rezervasyon) talebinin durumu. Her durum kendi
/// etiketini ve rengini taşır (kartlardaki rozet için). Salon randevusuyla aynı
/// deseni izler.
enum SitterBookingStatus {
  bekliyor(label: 'Bekliyor', color: AppColors.gold),
  onaylandi(label: 'Onaylı', color: AppColors.forest),
  tamamlandi(label: 'Tamamlandı', color: Color(0xFF5B8C7B)),
  iptal(label: 'İptal', color: AppColors.terracotta);

  const SitterBookingStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Pet sitter panelindeki tek bir konaklama rezervasyonu.
///
/// Bir sahip, dostunu belirli tarih aralığında sitter'a emanet etmek için talep
/// oluşturur. Durum değişebildiği için [copyWith] ile yeni kopya üretip
/// `SitterBookingStore` listesinde değiştiriyoruz (model immutable kalıyor).
class SitterBooking {
  const SitterBooking({
    required this.id,
    required this.ownerName,
    required this.petName,
    required this.breed,
    required this.species,
    required this.startDate,
    required this.endDate,
    required this.pricePerNight,
    this.note,
    this.phone,
    this.status = SitterBookingStatus.bekliyor,
  });

  /// Listede güncellerken bulmak için benzersiz kimlik.
  final String id;

  final String ownerName;
  final String petName;
  final String breed;

  /// Hayvan türü ("Kedi" / "Köpek"). İkon seçimi için kullanılır.
  final String species;

  /// Konaklamanın başladığı gün.
  final DateTime startDate;

  /// Konaklamanın bittiği gün (çıkış günü).
  final DateTime endDate;

  /// Gecelik ücret (TL).
  final int pricePerNight;

  /// Sahibin notu (örn. mama saati, ilaç). İsteğe bağlı.
  final String? note;

  /// İletişim telefonu (isteğe bağlı).
  final String? phone;

  final SitterBookingStatus status;

  /// Konaklama gece sayısı (en az 1).
  int get nights {
    final n = endDate.difference(startDate).inDays;
    return n < 1 ? 1 : n;
  }

  /// Toplam ücret (gece × gecelik).
  int get total => nights * pricePerNight;

  /// Tür ikonu (kedi/köpek için pati; bilinmiyorsa genel pati).
  IconData get speciesIcon => Icons.pets;

  /// Tarih aralığı etiketi (örn. "12 Haziran – 15 Haziran").
  String get rangeLabel =>
      '${formatTrDayMonth(startDate)} – ${formatTrDayMonth(endDate)}';

  /// Başlangıç gününün etiketi: bugüne göreceli ("Bugün"/"Yarın"/"Dün") ya da
  /// "14 Haziran". Liste görünümünde gruplama başlığı olarak kullanılır.
  String get dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = d.difference(today).inDays;
    switch (diff) {
      case 0:
        return 'Bugün';
      case 1:
        return 'Yarın';
      case -1:
        return 'Dün';
      default:
        return formatTrDayMonth(startDate);
    }
  }

  /// Bugün bu konaklama sürüyor mu? (onaylı ve bugün aralıkta)
  bool get isActiveToday {
    if (status != SitterBookingStatus.onaylandi) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !today.isBefore(start) && !today.isAfter(end);
  }

  SitterBooking copyWith({SitterBookingStatus? status}) {
    return SitterBooking(
      id: id,
      ownerName: ownerName,
      petName: petName,
      breed: breed,
      species: species,
      startDate: startDate,
      endDate: endDate,
      pricePerNight: pricePerNight,
      note: note,
      phone: phone,
      status: status ?? this.status,
    );
  }

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerName': ownerName,
        'petName': petName,
        'breed': breed,
        'species': species,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'pricePerNight': pricePerNight,
        'note': note,
        'phone': phone,
        'status': status.name,
      };

  /// Saklanan Map'ten [SitterBooking] üretir. Bilinmeyen durum bekliyor'a düşer.
  factory SitterBooking.fromJson(Map<String, dynamic> json) => SitterBooking(
        id: json['id'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        petName: json['petName'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        species: json['species'] as String? ?? '',
        startDate:
            DateTime.tryParse(json['startDate'] as String? ?? '') ??
                DateTime.now(),
        endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ??
            DateTime.now(),
        pricePerNight: (json['pricePerNight'] as num?)?.toInt() ?? 0,
        note: json['note'] as String?,
        phone: json['phone'] as String?,
        status: SitterBookingStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SitterBookingStatus.bekliyor,
        ),
      );
}
