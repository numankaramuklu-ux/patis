import 'package:flutter/material.dart';

import '../models/lost_pet.dart';
import '../theme/app_colors.dart';

/// Kayıp/Bulundu listesindeki tek bir ilanı gösteren kart.
///
/// Veriyi dışarıdan [LostPet] olarak alır. Kartın rengi ilanın durumundan
/// (Kayıp → terracotta, Bulundu → yeşil) gelir. [onTap] verilirse karta
/// dokununca detay ekranı açılır.
class LostPetCard extends StatelessWidget {
  const LostPetCard({super.key, required this.lostPet, this.onTap});

  final LostPet lostPet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = lostPet.status.color;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Üst satır: durum rozeti (Kayıp/Bulundu) ve varsa "Ödüllü" rozeti.
          Row(
            children: [
              _StatusBadge(status: lostPet.status),
              if (lostPet.hasReward) ...[
                const SizedBox(width: 8),
                const _RewardBadge(),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tür ikonu (renk durumdan gelir).
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(lostPet.species.icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lostPet.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    // Yer ve tarih tek satırda, ikonlarıyla.
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            lostPet.location,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.text.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          lostPet.dateLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lostPet.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.text.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Büyük durum rozeti: ilanın Kayıp mı Bulundu mu olduğunu net gösterir.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LostPetStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: AppColors.cream),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ödüllü" rozeti: ilanı bulana ödül verileceğini belirtir.
class _RewardBadge extends StatelessWidget {
  const _RewardBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, size: 14, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(
            'Ödüllü',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
