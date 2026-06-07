import 'package:flutter/material.dart';

import '../models/adoption_listing.dart';
import '../theme/app_colors.dart';

/// Sahiplendirme listesindeki tek bir ilanı gösteren kart.
///
/// Veriyi dışarıdan [AdoptionListing] olarak alır. Şimdilik yalnızca
/// gösterim amaçlı (detay ekranı ileride eklenecek).
class AdoptionCard extends StatelessWidget {
  const AdoptionCard({super.key, required this.listing});

  final AdoptionListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Kartın vurgu rengi türden geliyor (kedi → terracotta, köpek → yeşil).
    final accent = listing.species.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol taraf: türün soluk tonlu kutusunda tür ikonu. İleride buraya
          // hayvanın fotoğrafı gelecek.
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(listing.species.icon, color: accent, size: 30),
          ),
          const SizedBox(width: 14),
          // Sağ taraf: isim + rozetler + açıklama. Kalan genişliği kaplasın.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İsim ve cins yan yana; uzun olursa isim kısalmasın diye
                // cinsi Expanded ile esnek bıraktık.
                Row(
                  children: [
                    Text(listing.name, style: theme.textTheme.titleMedium),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '· ${listing.breed}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Küçük bilgi rozetleri: cinsiyet, yaş, şehir.
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: listing.gender.icon,
                      label: listing.gender.label,
                      color: accent,
                    ),
                    _InfoChip(
                      icon: Icons.cake_outlined,
                      label: listing.ageLabel,
                      color: accent,
                    ),
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: listing.city,
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  listing.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.75),
                    height: 1.3,
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

/// Kart içindeki küçük bilgi rozeti: ikon + kısa metin (örn. "Dişi", "3 aylık").
///
/// Sadece bu dosyada kullanıldığı için private bıraktık.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
