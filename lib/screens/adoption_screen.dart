import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/adoption_listing.dart';
import '../state/adoption_store.dart';
import '../theme/app_colors.dart';
import '../widgets/adoption_card.dart';
import '../widgets/new_adoption_listing_sheet.dart';
import 'adoption_detail_screen.dart';

/// Sahiplendirme ilanları ekranı (yol haritası #3).
///
/// Ana Sayfa'daki "Sahiplendirme" kutusundan açılır. İlanlar türe göre
/// filtrelenebilir ve favorilere eklenebilir (favoriler [AdoptionStore]'da
/// kalıcı). Bir karta dokununca ilan detayı açılır. İlanlar şimdilik mock —
/// ileride Firebase'den gerçek ilanlarla değiştirilecek.
class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  // Seçili tür filtresi (null = tümü).
  AdoptionSpecies? _species;
  // Yalnızca favorileri göster.
  bool _onlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<AdoptionStore>();

    final filtered = store.listings.where((l) {
      if (_species != null && l.species != _species) return false;
      if (_onlyFavorites && !store.isFavorite(l.id)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sahiplendirme')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewAdoptionListingSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('İlan ver'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text('Yuva arayan dostlar', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Bir patiye sıcak bir yuva ol',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Filtre çipleri: tür + favoriler.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: _species == null && !_onlyFavorites,
                  onTap: () => setState(() {
                    _species = null;
                    _onlyFavorites = false;
                  }),
                ),
                _FilterChip(
                  label: 'Kedi',
                  icon: Icons.pets,
                  selected: _species == AdoptionSpecies.kedi,
                  onTap: () => setState(() => _species = AdoptionSpecies.kedi),
                ),
                _FilterChip(
                  label: 'Köpek',
                  icon: Icons.pets,
                  selected: _species == AdoptionSpecies.kopek,
                  onTap: () => setState(() => _species = AdoptionSpecies.kopek),
                ),
                _FilterChip(
                  label:
                      'Favoriler${store.favoriteCount > 0 ? ' (${store.favoriteCount})' : ''}',
                  icon: Icons.favorite,
                  selected: _onlyFavorites,
                  onTap: () => setState(() => _onlyFavorites = !_onlyFavorites),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        _onlyFavorites
                            ? Icons.favorite_border
                            : Icons.search_off,
                        size: 56,
                        color: AppColors.forest.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onlyFavorites
                            ? 'Henüz favori ilan yok.\nKalbe dokunarak ekleyebilirsin 🐾'
                            : 'Bu filtreye uygun ilan yok',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final listing in filtered) ...[
                AdoptionCard(
                  listing: listing,
                  isFavorite: store.isFavorite(listing.id),
                  onFavorite: () => store.toggleFavorite(listing.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdoptionDetailScreen(listing: listing),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

/// Üstteki tür/favori filtre çipi.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.forest : AppColors.card,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.forest
                  : AppColors.text.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? AppColors.cream : AppColors.text,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.cream : AppColors.text,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
