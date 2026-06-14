import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Veteriner randevusunun durumu (salon ile aynı akış: bekle → onayla → tamamla).
enum VetApptStatus {
  bekliyor(label: 'Bekliyor', color: AppColors.gold),
  onaylandi(label: 'Onaylı', color: AppColors.forest),
  tamamlandi(label: 'Tamamlandı', color: Color(0xFF5B8C7B)),
  iptal(label: 'İptal', color: AppColors.terracotta);

  const VetApptStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Veteriner randevusunun türü. Her tür kendi ikon ve rengini taşır; bu sayede
/// kartta türe göre görsel ayrım yapılır.
enum VetApptType {
  asi(label: 'Aşı', icon: Icons.vaccines_outlined, color: AppColors.forest),
  kontrol(
      label: 'Kontrol',
      icon: Icons.monitor_heart_outlined,
      color: Color(0xFF5B8C7B)),
  operasyon(
      label: 'Operasyon',
      icon: Icons.healing_outlined,
      color: AppColors.gold),
  acil(
      label: 'Acil',
      icon: Icons.emergency_outlined,
      color: AppColors.terracotta);

  const VetApptType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Veteriner kliniğinin tek bir hasta randevusu.
///
/// Salon randevusuyla aynı mantık, ama "hizmet" yerine tür + tıbbi sebep var.
/// Durum değişince [copyWith] ile yeni kopya üretilip [VetStore] listesinde
/// güncellenir.
class VetAppointment {
  const VetAppointment({
    required this.id,
    required this.petName,
    required this.breed,
    required this.ownerName,
    required this.type,
    required this.reason,
    required this.durationMin,
    required this.price,
    required this.dayLabel,
    required this.time,
    this.status = VetApptStatus.bekliyor,
  });

  final String id;
  final String petName;
  final String breed;
  final String ownerName;

  /// Randevu türü (ikon/renk için).
  final VetApptType type;

  /// Tıbbi sebep / işlem (örn. "Kuduz aşısı", "Diş taşı temizliği").
  final String reason;

  final int durationMin;
  final int price;
  final String dayLabel;
  final String time;
  final VetApptStatus status;

  VetAppointment copyWith({VetApptStatus? status}) {
    return VetAppointment(
      id: id,
      petName: petName,
      breed: breed,
      ownerName: ownerName,
      type: type,
      reason: reason,
      durationMin: durationMin,
      price: price,
      dayLabel: dayLabel,
      time: time,
      status: status ?? this.status,
    );
  }
}
