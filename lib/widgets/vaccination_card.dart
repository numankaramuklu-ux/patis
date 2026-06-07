import 'package:flutter/material.dart';

import '../models/vaccination.dart';
import '../theme/app_colors.dart';

/// Tek bir aşı kaydını gösteren kart.
///
/// Veriyi dışarıdan [Vaccination] olarak alır; randevu kartıyla aynı görsel
/// dili kullanır ama vurgu rengi yeşil (aşı = sağlık/koruma çağrışımı).
class VaccinationCard extends StatelessWidget {
  const VaccinationCard({super.key, required this.vaccination});

  final Vaccination vaccination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Sol taraftaki yuvarlak ikon kutusu (kartlardaki ortak desen).
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.vaccines_outlined, color: AppColors.forest),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccination.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Yapıldı: ${vaccination.dateLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Sonraki doz varsa sağda küçük bir "rozet" olarak göster.
          if (vaccination.nextDueLabel != null)
            _NextDueBadge(label: vaccination.nextDueLabel!),
        ],
      ),
    );
  }
}

/// "Sonraki doz" tarihini gösteren küçük altın renkli rozet.
///
/// Sadece bu kartta kullanıldığı için private (alt çizgiyle) tuttuk.
class _NextDueBadge extends StatelessWidget {
  const _NextDueBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Sonraki',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.forest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
