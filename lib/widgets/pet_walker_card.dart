import 'dart:io';

import 'package:flutter/material.dart';

import '../models/pet_walker.dart';
import '../theme/app_colors.dart';

/// Köpek gezdirme listesindeki tek bir gezdiriciyi gösteren kart.
///
/// [PetSitterCard] ile aynı düzen; sağ üstteki kalp ile favoriye eklenir,
/// karta dokununca gezdiricinin detay ekranı açılır.
class PetWalkerCard extends StatelessWidget {
  const PetWalkerCard({
    super.key,
    required this.walker,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final PetWalker walker;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.forest;
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
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  image: walker.photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(walker.photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: walker.photoPath != null
                    ? null
                    : Text(
                        walker.name.characters.first,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: accent,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            walker.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (walker.verified) ...[
                          const SizedBox(width: 6),
                          const _VerifiedBadge(),
                        ],
                        const Spacer(),
                        _FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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
                            walker.district,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.text.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: '${walker.rating} (${walker.reviewCount})',
                          color: AppColors.gold,
                        ),
                        _InfoChip(
                          icon: Icons.directions_walk,
                          label: '₺${walker.pricePerWalk}/yürüyüş',
                          color: accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      walker.summary,
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

/// "Onaylı" rozeti: kimliği doğrulanmış gezdiricileri belirtir.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 13, color: AppColors.forest),
          const SizedBox(width: 3),
          Text(
            'Onaylı',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.forest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kart içindeki küçük bilgi rozeti: ikon + kısa metin.
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
