import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Bir salon randevusunun durumu. Her durum kendi etiketini ve rengini taşır
/// (kartlardaki rozet için).
enum SalonApptStatus {
  bekliyor(label: 'Bekliyor', color: AppColors.gold),
  onaylandi(label: 'Onaylı', color: AppColors.forest),
  tamamlandi(label: 'Tamamlandı', color: Color(0xFF5B8C7B)),
  iptal(label: 'İptal', color: AppColors.terracotta);

  const SalonApptStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Pet salonunun (kuaför) tek bir müşteri randevusu.
///
/// Sahibin baktığı randevudan farklı olarak burada hizmet, süre, ücret ve durum
/// gibi işletme alanları var. Durum değişebildiği için [copyWith] ile yeni bir
/// kopya üretip [SalonStore] listesinde değiştiriyoruz (model immutable kalıyor).
class SalonAppointment {
  const SalonAppointment({
    required this.id,
    required this.petName,
    required this.breed,
    required this.ownerName,
    required this.service,
    required this.durationMin,
    required this.price,
    required this.date,
    required this.time,
    this.status = SalonApptStatus.bekliyor,
    this.clientId,
  });

  /// Listede güncellerken bulmak için benzersiz kimlik.
  final String id;

  /// Bu randevunun ait olduğu müşteri ([SalonClient.id]). Kayıtlı bir müşteri
  /// değilse (ör. tek seferlik gelen) null olabilir.
  final String? clientId;

  final String petName;
  final String breed;
  final String ownerName;

  /// Verilen hizmet (örn. "Tıraş & Banyo").
  final String service;

  /// Tahmini süre (dakika).
  final int durationMin;

  /// Ücret (TL).
  final int price;

  /// Randevunun tarihi (saat bilgisi [time]'da ayrı tutulur).
  final DateTime date;

  /// Saat (örn. "11:00").
  final String time;

  final SalonApptStatus status;

  /// Gün etiketi: bugüne göreceli ("Bugün"/"Yarın"/"Dün") ya da "14 Haziran".
  /// [date]'ten türetilir; liste görünümünde gruplama başlığı olarak kullanılır.
  String get dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    switch (diff) {
      case 0:
        return 'Bugün';
      case 1:
        return 'Yarın';
      case -1:
        return 'Dün';
      default:
        return formatTrDayMonth(date);
    }
  }

  SalonAppointment copyWith({SalonApptStatus? status}) {
    return SalonAppointment(
      id: id,
      petName: petName,
      breed: breed,
      ownerName: ownerName,
      service: service,
      durationMin: durationMin,
      price: price,
      date: date,
      time: time,
      status: status ?? this.status,
      clientId: clientId,
    );
  }

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Tarih ISO 8601
  /// metni, durum enum adı olarak yazılır.
  Map<String, dynamic> toJson() => {
        'id': id,
        'petName': petName,
        'breed': breed,
        'ownerName': ownerName,
        'service': service,
        'durationMin': durationMin,
        'price': price,
        'date': date.toIso8601String(),
        'time': time,
        'status': status.name,
        'clientId': clientId,
      };

  /// Saklanan Map'ten [SalonAppointment] üretir. Bilinmeyen durum bekliyor'a düşer.
  factory SalonAppointment.fromJson(Map<String, dynamic> json) =>
      SalonAppointment(
        id: json['id'] as String? ?? '',
        petName: json['petName'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        service: json['service'] as String? ?? '',
        durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        time: json['time'] as String? ?? '',
        status: SalonApptStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SalonApptStatus.bekliyor,
        ),
        clientId: json['clientId'] as String?,
      );
}
