import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Bir köpek yürüyüşü talebinin durumu. Her durum kendi etiketini ve rengini
/// taşır (kartlardaki rozet için).
enum WalkStatus {
  bekliyor(label: 'Bekliyor', color: AppColors.gold),
  onaylandi(label: 'Onaylı', color: AppColors.forest),
  tamamlandi(label: 'Tamamlandı', color: Color(0xFF5B8C7B)),
  iptal(label: 'İptal', color: AppColors.terracotta);

  const WalkStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Pet walker panelindeki tek bir köpek yürüyüşü.
///
/// Konaklamadan farklı olarak yürüyüş tek bir gün + saat + süreden oluşur.
/// Durum değişebildiği için [copyWith] ile yeni kopya üretip `WalkStore`
/// listesinde değiştiriyoruz (model immutable kalıyor).
class DogWalk {
  const DogWalk({
    required this.id,
    required this.ownerName,
    required this.petName,
    required this.breed,
    required this.date,
    required this.time,
    required this.durationMin,
    required this.price,
    this.note,
    this.phone,
    this.status = WalkStatus.bekliyor,
  });

  /// Benzersiz kimlik.
  final String id;

  final String ownerName;
  final String petName;
  final String breed;

  /// Yürüyüş günü (saat [time]'da ayrı tutulur).
  final DateTime date;

  /// Saat (örn. "09:00").
  final String time;

  /// Süre (dakika, örn. 30 / 45 / 60).
  final int durationMin;

  /// Ücret (TL).
  final int price;

  /// Sahibin notu (örn. "Diğer köpeklerden çekiniyor"). İsteğe bağlı.
  final String? note;

  /// İletişim telefonu (isteğe bağlı).
  final String? phone;

  final WalkStatus status;

  /// Saat + süre etiketi (örn. "09:00 • 30 dk").
  String get timeLabel => '$time • $durationMin dk';

  /// Gün etiketi: bugüne göreceli ("Bugün"/"Yarın"/"Dün") ya da "14 Haziran".
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

  /// Bugüne mi ait? (saat yok sayılır)
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DogWalk copyWith({WalkStatus? status}) {
    return DogWalk(
      id: id,
      ownerName: ownerName,
      petName: petName,
      breed: breed,
      date: date,
      time: time,
      durationMin: durationMin,
      price: price,
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
        'date': date.toIso8601String(),
        'time': time,
        'durationMin': durationMin,
        'price': price,
        'note': note,
        'phone': phone,
        'status': status.name,
      };

  /// Saklanan Map'ten [DogWalk] üretir. Bilinmeyen durum bekliyor'a düşer.
  factory DogWalk.fromJson(Map<String, dynamic> json) => DogWalk(
        id: json['id'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        petName: json['petName'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        time: json['time'] as String? ?? '',
        durationMin: (json['durationMin'] as num?)?.toInt() ?? 30,
        price: (json['price'] as num?)?.toInt() ?? 0,
        note: json['note'] as String?,
        phone: json['phone'] as String?,
        status: WalkStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => WalkStatus.bekliyor,
        ),
      );
}
