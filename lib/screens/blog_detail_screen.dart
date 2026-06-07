import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';

/// Tek bir blog yazısının tam metnini gösteren ekran (yol haritası #6).
///
/// Blog listesindeki bir karta dokununca açılır. Yazıyı dışarıdan [BlogPost]
/// olarak alır.
class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = post.category.color;
    // Yazıyı paragraflara böl (modelde `\n\n` ile ayrılmıştı).
    final paragraphs = post.body.split('\n\n');
    return Scaffold(
      appBar: AppBar(title: Text(post.category.label)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Kategori + okuma süresi.
            Row(
              children: [
                Icon(post.category.icon, size: 16, color: accent),
                const SizedBox(width: 5),
                Text(
                  post.category.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.schedule,
                  size: 15,
                  color: AppColors.text.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 3),
                Text(
                  '${post.readMinutes} dk okuma',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            // Her paragrafı arada boşlukla diziyoruz.
            for (final paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: AppColors.text.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
