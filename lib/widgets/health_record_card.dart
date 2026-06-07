import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../theme/app_colors.dart';

/// Bir sağlık kaydını (alerji ya da ilaç) gösteren tek tip kart.
///
/// İkon ve vurgu rengini dışarıdan alır; böylece aynı kartı hem "Alerjiler"
/// hem "İlaçlar" bölümünde farklı renk/ikonla yeniden kullanabiliyoruz.
/// Aşı kartıyla aynı görsel dili paylaşır (yuvarlak kart + soluk ikon kutusu).
class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({
    super.key,
    required this.record,
    required this.icon,
    required this.color,
  });

  final HealthRecord record;

  /// Sol taraftaki ikon (örn. alerji için uyarı, ilaç için hap ikonu).
  final IconData icon;

  /// Bu kartın vurgu rengi (ikon ve kutu tonu için).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  record.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
