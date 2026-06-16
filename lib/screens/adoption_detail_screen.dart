import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/adoption_listing.dart';
import '../state/adoption_store.dart';
import '../theme/app_colors.dart';

/// Tek bir sahiplendirme ilanının detay ekranı.
///
/// Büyük tür rozetli başlık, hayvanın bilgileri ve tanıtım yazısı. Üstte
/// favori (kalp) düğmesi, altta "Sahiplenmek istiyorum" iletişim aksiyonu
/// (şimdilik mock geri bildirim). Favori durumu [AdoptionStore]'dan canlı gelir.
class AdoptionDetailScreen extends StatelessWidget {
  const AdoptionDetailScreen({super.key, required this.listing});

  final AdoptionListing listing;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<AdoptionStore>();
    final isFav = store.isFavorite(listing.id);
    final accent = listing.species.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
        actions: [
          IconButton(
            onPressed: () => store.toggleFavorite(listing.id),
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? AppColors.terracotta : null,
            tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Büyük başlık ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(listing.species.icon, color: accent, size: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(listing.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.species.label} • ${listing.breed}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Bilgi kutuları ----
            Row(
              children: [
                _InfoBox(
                  icon: listing.gender.icon,
                  value: listing.gender.label,
                  label: 'cinsiyet',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.cake_outlined,
                  value: listing.ageLabel,
                  label: 'yaş',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.location_on_outlined,
                  value: listing.city,
                  label: 'şehir',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Tanıtım ----
            Text('Hakkında', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.text.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                listing.summary,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 28),

            // ---- Aksiyonlar ----
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _snack(
                      context,
                      '${listing.name} hakkında mesaj gönderiliyor…',
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Mesaj'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: const BorderSide(color: AppColors.forest),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _snack(
                      context,
                      '${listing.name} için başvurun alındı 🐾',
                    ),
                    icon: const Icon(Icons.favorite_outline),
                    label: const Text('Sahiplen'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: AppColors.cream,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Detaydaki tek bir bilgi kutusu (ikon + değer + etiket).
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forest, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
