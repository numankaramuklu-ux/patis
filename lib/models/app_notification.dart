import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bir bildirimin türü. Türüne göre ikon ve renk seçilir; ileride dokununca
/// ilgili ekrana yönlendirmek için de kullanılabilir.
enum NotificationKind { appointment, community, lostPet, system }

/// Uygulama içi tek bir bildirim (yol haritası: Bildirimler).
///
/// [read] (okundu mu) kullanıcı dokundukça değiştiği için `final` DEĞİL.
/// Bunu elle değil her zaman [NotificationStore] üzerinden değiştiririz ki
/// ekran ve rozet otomatik güncellensin.
class AppNotification {
  AppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.read = false,
  });

  /// Bildirimin türü (randevu, topluluk, kayıp, sistem).
  final NotificationKind kind;

  /// Kısa başlık.
  final String title;

  /// Açıklama metni.
  final String body;

  /// Ne kadar önce geldiği (örn. "2 saat önce"). Şimdilik hazır metin.
  final String timeAgo;

  /// Kullanıcı bu bildirimi okudu mu? (değişebilir)
  bool read;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Tür enum adı.
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'title': title,
        'body': body,
        'timeAgo': timeAgo,
        'read': read,
      };

  /// Saklanan Map'ten [AppNotification] üretir. Bilinmeyen tür system'a düşer.
  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        kind: NotificationKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => NotificationKind.system,
        ),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        timeAgo: json['timeAgo'] as String? ?? '',
        read: json['read'] as bool? ?? false,
      );

  /// Türüne göre gösterilecek ikon.
  IconData get icon {
    switch (kind) {
      case NotificationKind.appointment:
        return Icons.event_outlined;
      case NotificationKind.community:
        return Icons.groups_outlined;
      case NotificationKind.lostPet:
        return Icons.location_on_outlined;
      case NotificationKind.system:
        return Icons.pets;
    }
  }

  /// Türüne göre vurgu rengi (paletimizden).
  Color get color {
    switch (kind) {
      case NotificationKind.appointment:
        return AppColors.gold;
      case NotificationKind.community:
        return AppColors.forest;
      case NotificationKind.lostPet:
        return AppColors.terracotta;
      case NotificationKind.system:
        return AppColors.forest;
    }
  }
}
