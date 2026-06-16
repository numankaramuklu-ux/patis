import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bir günlük kaydındaki ruh hâli. Her değer kendi etiketini, emojisini ve
/// rengini taşır (kart rozeti ve seçici için).
enum PetMood {
  mutlu(label: 'Mutlu', emoji: '😺', color: AppColors.gold),
  oyuncu(label: 'Oyuncu', emoji: '🐾', color: AppColors.forest),
  sakin(label: 'Sakin', emoji: '😌', color: Color(0xFF5B8C7B)),
  uykulu(label: 'Uykulu', emoji: '😴', color: AppColors.text),
  keyifsiz(label: 'Keyifsiz', emoji: '🤒', color: AppColors.terracotta);

  const PetMood({
    required this.label,
    required this.emoji,
    required this.color,
  });

  final String label;
  final String emoji;
  final Color color;
}

/// Bir evcil hayvanın günlüğündeki tek bir kayıt: tarih + ruh hâli + not.
///
/// Sahip, dostunun o günkü hâlini ve anısını not eder. Kayıtlar [PetProfile]
/// içinde tutulur ve diğer pasaport verisiyle birlikte diske yazılır.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.dateLabel,
    required this.mood,
    required this.text,
  });

  /// Listede bulup silmek için benzersiz kimlik.
  final String id;

  /// Yazıldığı tarih (örn. "16 Haziran").
  final String dateLabel;

  /// O günkü ruh hâli.
  final PetMood mood;

  /// Notun kendisi.
  final String text;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'dateLabel': dateLabel,
        'mood': mood.name,
        'text': text,
      };

  /// Saklanan Map'ten [JournalEntry] üretir. Bilinmeyen ruh hâli "mutlu"ya düşer.
  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String? ?? '',
        dateLabel: json['dateLabel'] as String? ?? '',
        mood: PetMood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => PetMood.mutlu,
        ),
        text: json['text'] as String? ?? '',
      );
}
