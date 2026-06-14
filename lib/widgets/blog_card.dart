import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';

/// Blog listesindeki tek bir yazıyı gösteren kart.
///
/// Dokununca [onTap] çalışır (yazı detayını açmak için). Veriyi dışarıdan
/// [BlogPost] olarak alır.
class BlogCard extends StatelessWidget {
  const BlogCard({super.key, required this.post, required this.onTap});

  final BlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = post.category.color;
    // Material + InkWell: kart zemini + yumuşak gölge + dokununca dalga efekti.
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: AppColors.forest.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: kategori etiketi ve okuma süresi.
              Row(
                children: [
                  _CategoryChip(category: post.category),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${post.readMinutes} dk',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                post.excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              // "Devamını oku" ipucu — kartın tıklanabilir olduğunu belli eder.
              Row(
                children: [
                  Text(
                    'Devamını oku',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 15, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kategori etiketi: ikon + ad, kategorinin kendi renginde.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final BlogCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: category.color),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: category.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
