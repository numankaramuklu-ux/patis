import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
    required this.dayLabel,
    required this.time,
    this.status = SalonApptStatus.bekliyor,
  });

  /// Listede güncellerken bulmak için benzersiz kimlik.
  final String id;

  final String petName;
  final String breed;
  final String ownerName;

  /// Verilen hizmet (örn. "Tıraş & Banyo").
  final String service;

  /// Tahmini süre (dakika).
  final int durationMin;

  /// Ücret (TL).
  final int price;

  /// Gün etiketi (örn. "Bugün", "Yarın", "14 Haziran").
  final String dayLabel;

  /// Saat (örn. "11:00").
  final String time;

  final SalonApptStatus status;

  SalonAppointment copyWith({SalonApptStatus? status}) {
    return SalonAppointment(
      id: id,
      petName: petName,
      breed: breed,
      ownerName: ownerName,
      service: service,
      durationMin: durationMin,
      price: price,
      dayLabel: dayLabel,
      time: time,
      status: status ?? this.status,
    );
  }
}
