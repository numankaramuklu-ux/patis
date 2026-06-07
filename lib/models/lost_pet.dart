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
}
