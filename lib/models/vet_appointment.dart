import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

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
    required this.date,
    required this.time,
    this.status = VetApptStatus.bekliyor,
    this.patientId,
  });

  final String id;
  final String petName;
  final String breed;
  final String ownerName;

  /// Bu randevunun ait olduğu hasta ([VetPatient.id]). Kayıtlı bir hasta
  /// değilse (ör. ilk kez gelen) null olabilir.
  final String? patientId;

  /// Randevu türü (ikon/renk için).
  final VetApptType type;

  /// Tıbbi sebep / işlem (örn. "Kuduz aşısı", "Diş taşı temizliği").
  final String reason;

  final int durationMin;
  final int price;

  /// Randevunun tarihi (saat bilgisi [time]'da ayrı tutulur).
  final DateTime date;

  final String time;
  final VetApptStatus status;

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
      date: date,
      time: time,
      status: status ?? this.status,
      patientId: patientId,
    );
  }

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Tarih ISO 8601
  /// metni, tür ve durum enum adı olarak yazılır.
  Map<String, dynamic> toJson() => {
        'id': id,
        'petName': petName,
        'breed': breed,
        'ownerName': ownerName,
        'type': type.name,
        'reason': reason,
        'durationMin': durationMin,
        'price': price,
        'date': date.toIso8601String(),
        'time': time,
        'status': status.name,
        'patientId': patientId,
      };

  /// Saklanan Map'ten [VetAppointment] üretir. Bilinmeyen tür/durum varsayılana
  /// (kontrol / bekliyor) düşer.
  factory VetAppointment.fromJson(Map<String, dynamic> json) => VetAppointment(
        id: json['id'] as String? ?? '',
        petName: json['petName'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        type: VetApptType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => VetApptType.kontrol,
        ),
        reason: json['reason'] as String? ?? '',
        durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        time: json['time'] as String? ?? '',
        status: VetApptStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => VetApptStatus.bekliyor,
        ),
        patientId: json['patientId'] as String?,
      );
}
