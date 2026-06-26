import 'package:flutter/material.dart';

import '../models/dog_walk.dart';
import '../theme/app_colors.dart';

/// Pet walker panelindeki tek bir köpek yürüyüşünü gösteren kart.
///
/// Veriyi dışarıdan [DogWalk] olarak alır; durumdan gelen renkli bir rozet,
/// köpek/sahip bilgisi, gün+saat+süre ve ücreti gösterir. [onTap] verilirse
/// karta dokununca aksiyon paneli açılır.
class DogWalkCard extends StatelessWidget {
  const DogWalkCard({super.key, required this.walk, this.onTap});

  final DogWalk walk;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_walk,
                        color: AppColors.forest, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${walk.petName} • ${walk.breed}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sahibi: ${walk.ownerName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: walk.status),
                ],
              ),
              const SizedBox(height: 12),
              // Saat + süre + ücret tek satırda.
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${walk.dayLabel} • ${walk.timeLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${walk.price} ₺',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yürüyüş durum rozeti (Bekliyor/Onaylı/Tamamlandı/İptal).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WalkStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
