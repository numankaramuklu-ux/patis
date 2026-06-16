import 'package:flutter/material.dart';

import '../models/adoption_listing.dart';
import '../theme/app_colors.dart';

/// Sahiplendirme listesindeki tek bir ilanı gösteren kart.
///
/// Veriyi dışarıdan [AdoptionListing] olarak alır. Sağ üstteki kalp ile
/// favoriye eklenir; karta dokununca detay ekranı açılır.
class AdoptionCard extends StatelessWidget {
  const AdoptionCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final AdoptionListing listing;

  /// İlan favoride mi? (kalbin dolu/boş görünmesini belirler).
  final bool isFavorite;

  /// Kalbe dokununca favoriye ekler/çıkarır.
  final VoidCallback onFavorite;

  /// Karta dokununca detay ekranına gider.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Kartın vurgu rengi türden geliyor (kedi → terracotta, köpek → yeşil).
    final accent = listing.species.color;
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
                    // İsim ve cins + sağda favori kalbi.
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
                        _FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite,
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
        ),
      ),
    );
  }
}

/// İlan kartının sağ üstündeki favori (kalp) düğmesi.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite
              ? AppColors.terracotta
              : AppColors.text.withValues(alpha: 0.4),
          size: 22,
        ),
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
