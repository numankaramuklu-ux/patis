import 'package:flutter/material.dart';

import '../models/salon_appointment.dart';
import '../theme/app_colors.dart';

/// Salon randevusunu gösteren kart.
///
/// Solda saat sütunu, ortada hayvan/sahip/hizmet, üst köşede durum rozeti ve
/// altta süre·ücret. Dokununca [onTap] (detay paneli) çalışır. Hem salon ana
/// ekranında hem Randevular ekranında kullanılır.
class SalonAppointmentCard extends StatelessWidget {
  const SalonAppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final SalonAppointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = appointment.status.color;
    // İptal edilen randevu soluk görünsün.
    final faded = appointment.status == SalonApptStatus.iptal;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: faded ? 0.55 : 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saat sütunu.
                Column(
                  children: [
                    Text(
                      appointment.time,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.forest,
                      ),
                    ),
                    Text(
                      '${appointment.durationMin} dk',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.text.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 14),
                // Orta blok: hayvan + sahip + hizmet.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              appointment.petName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sahibi: ${appointment.ownerName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.content_cut,
                              size: 14, color: accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              appointment.service,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${appointment.price}₺',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Randevu durumunu gösteren küçük renkli rozet.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SalonApptStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
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
