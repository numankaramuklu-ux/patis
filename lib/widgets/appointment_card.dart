import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../theme/app_colors.dart';

/// Yaklaşan bir randevuyu gösteren kart.
///
/// Veriyi dışarıdan [Appointment] olarak alır.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment});

  final Appointment appointment;

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
