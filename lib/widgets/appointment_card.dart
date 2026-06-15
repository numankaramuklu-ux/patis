import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../theme/app_colors.dart';

/// Yaklaşan bir randevuyu gösteren kart.
///
/// Veriyi dışarıdan [Appointment] olarak alır.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.petName});

  final Appointment appointment;

  /// Randevunun ait olduğu hayvanın adı. Verilirse başlığın altında küçük bir
  /// rozet olarak gösterilir (çoklu hayvan desteği).
  final String? petName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Kartın vurgu rengi ve ikonu artık randevu türünden geliyor
    // (veteriner → yeşil, kuaför → terracotta).
    final accent = appointment.type.color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(appointment.type.icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  appointment.place,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                // Hangi dosta ait olduğunu gösteren rozet.
                if (petName != null && petName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pets, size: 12, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          petName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            appointment.dateLabel,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
