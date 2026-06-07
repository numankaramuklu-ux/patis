import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Blog yazısının kategorisi. Karttaki renkli etiketi belirler.
///
/// Diğer modellerdeki gibi "gelişmiş enum": her kategori kendi etiketini,
/// ikonunu ve rengini taşır.
enum BlogCategory {
  bakim(label: 'Bakım', icon: Icons.spa_outlined, color: AppColors.forest),
  saglik(
    label: 'Sağlık',
    icon: Icons.favorite_outline,
    color: AppColors.terracotta,
  ),
  beslenme(
    label: 'Beslenme',
    icon: Icons.restaurant_outlined,
    color: AppColors.gold,
  ),
  egitim(label: 'Eğitim', icon: Icons.school_outlined, color: AppColors.forest);

  const BlogCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Blog ekranında listelenen tek bir yazı (yol haritası #6).
///
/// Şimdilik içerikler mock (sahte) ve elle yazılı — ileride Firebase'den
/// gerçek yazılarla değiştireceğiz.
class BlogPost {
  const BlogPost({
    required this.title,
    required this.category,
    required this.readMinutes,
    required this.excerpt,
    required this.body,
  });

  /// Yazının başlığı.
  final String title;

  /// Kategori — kartın renkli etiketini belirler.
  final BlogCategory category;

  /// Tahmini okuma süresi (dakika).
  final int readMinutes;

  /// Listede gösterilen kısa özet (ilk birkaç cümle).
  final String excerpt;

  /// Yazının tam metni — detay ekranında gösterilir. Paragrafları `\n\n`
  /// ile ayırıyoruz.
  final String body;
}
