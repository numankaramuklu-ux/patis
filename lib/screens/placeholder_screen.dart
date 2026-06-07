import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Henüz geliştirmediğimiz sekmeler için ortak "yakında gelecek" ekranı.
///
/// Başlığı ve ikonu dışarıdan parametre olarak alır; böylece tek bir widget'ı
/// dört farklı sekme için tekrar kullanabiliyoruz (kopyala-yapıştır yapmadan).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  /// Ekranın üst başlığı (örn. "Pasaport").
  final String title;

  /// Ortada gösterilecek büyük ikon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.forest.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              '$title\nyakında burada olacak 🐾',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
