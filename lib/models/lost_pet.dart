import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'adoption_listing.dart';

/// Bir kayıp ilanının durumu. Kartın vurgu rengini ve etiketini belirler.
///
/// "Kayıp" (sahibi arıyor) ve "Bulundu" (biri buldu, sahibini arıyor) iki
/// farklı durumdur; rengiyle bir bakışta ayırt edilsin diye enhanced enum.
enum LostPetStatus {
  kayip(
    label: 'Kayıp',
    icon: Icons.error_outline,
    color: AppColors.terracotta,
  ),
  bulundu(
    label: 'Bulundu',
    icon: Icons.check_circle_outline,
    color: AppColors.forest,
  );

  const LostPetStatus({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Kayıp/Bulundu ekranındaki tek bir ilan (yol haritası #5).
///
/// Şimdilik veriler mock (sahte) ve harita yok — sonraki adımda konum/harita
/// ve konuma dayalı bildirim ekleyeceğiz.
class LostPet {
  const LostPet({
    required this.name,
    required this.species,
    required this.status,
    required this.location,
    required this.dateLabel,
    required this.description,
    this.hasReward = false,
    this.contactName,
    this.phone,
  });

  /// Hayvanın adı; bilinmiyorsa "İsimsiz" gibi bir metin verilir.
  final String name;

  /// Tür — yalnızca ikon için [AdoptionSpecies]'i yeniden kullanıyoruz
  /// (kartın rengi türden değil, [status]'tan gelir).
  final AdoptionSpecies species;

  /// İlan kayıp mı yoksa bulundu mu?
  final LostPetStatus status;

  /// Son görüldüğü / bulunduğu yer (örn. "Beşiktaş, İstanbul").
  final String location;

  /// Tarih etiketi (örn. "5 Haziran").
  final String dateLabel;

  /// Serbest açıklama (renk, tasma, davranış vb.).
  final String description;

  /// Ödül var mı? `true` ise kartta "Ödüllü" rozeti gösterilir.
  final bool hasReward;

  /// İlan sahibinin / bulan kişinin adı (iletişim için, isteğe bağlı).
  final String? contactName;

  /// İletişim telefonu (arama/mesaj için). Yoksa iletişim aksiyonu kapalıdır.
  final String? phone;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Tür ve durum
  /// enum adı olarak yazılır.
  Map<String, dynamic> toJson() => {
        'name': name,
        'species': species.name,
        'status': status.name,
        'location': location,
        'dateLabel': dateLabel,
        'description': description,
        'hasReward': hasReward,
        'contactName': contactName,
        'phone': phone,
      };

  /// Saklanan Map'ten [LostPet] üretir. Bilinmeyen tür/durum varsayılana düşer.
  factory LostPet.fromJson(Map<String, dynamic> json) => LostPet(
        name: json['name'] as String? ?? '',
        species: AdoptionSpecies.values.firstWhere(
          (s) => s.name == json['species'],
          orElse: () => AdoptionSpecies.kedi,
        ),
        status: LostPetStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => LostPetStatus.kayip,
        ),
        location: json['location'] as String? ?? '',
        dateLabel: json['dateLabel'] as String? ?? '',
        description: json['description'] as String? ?? '',
        hasReward: json['hasReward'] as bool? ?? false,
        contactName: json['contactName'] as String?,
        phone: json['phone'] as String?,
      );
}
