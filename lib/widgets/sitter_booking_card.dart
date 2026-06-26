import 'package:flutter/material.dart';

import '../models/sitter_booking.dart';
import '../theme/app_colors.dart';

/// Pet sitter panelindeki tek bir konaklama rezervasyonunu gösteren kart.
///
/// Veriyi dışarıdan [SitterBooking] olarak alır; durumdan gelen renkli bir
/// rozet, hayvan/sahip bilgisi, tarih aralığı ve ücret özetini gösterir. [onTap]
/// verilirse karta dokununca aksiyon paneli açılır.
class SitterBookingCard extends StatelessWidget {
  const SitterBookingCard({super.key, required this.booking, this.onTap});

  final SitterBooking booking;
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
                      color: AppColors.terracotta.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(booking.speciesIcon,
                        color: AppColors.terracotta, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.petName} • ${booking.breed}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sahibi: ${booking.ownerName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              // Tarih aralığı + gece sayısı + ücret tek satırda.
              Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: 16,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${booking.rangeLabel} • ${booking.nights} gece',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${booking.total} ₺',
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

/// Rezervasyon durum rozeti (Bekliyor/Onaylı/Tamamlandı/İptal).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SitterBookingStatus status;

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
