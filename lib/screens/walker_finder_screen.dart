import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/pet_walker_store.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_walker_card.dart';
import 'walker_detail_screen.dart';

/// Gezdiricilerin sıralama ölçütü.
enum _WalkerSort { puan, ucret }

/// Köpek gezdirme bulma ekranı.
///
/// Ana Sayfa'daki "Köpek Gezdirme" kutusundan açılır. Gezdiriciler şehre göre
/// filtrelenip puana/ücrete göre sıralanabilir, favorilere eklenebilir ve karta
/// dokununca detay açılır. Veriler [PetWalkerStore]'dan gelir (kalıcı).
class WalkerFinderScreen extends StatefulWidget {
  const WalkerFinderScreen({super.key});

  @override
  State<WalkerFinderScreen> createState() => _WalkerFinderScreenState();
}

class _WalkerFinderScreenState extends State<WalkerFinderScreen> {
  bool _onlyVerified = false;
  bool _onlyFavorites = false;
  String? _city; // null = tüm şehirler
  _WalkerSort _sort = _WalkerSort.puan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<PetWalkerStore>();

    final cities = store.walkers.map((w) => w.city).toSet().toList()..sort();
    final activeCity = _city != null && cities.contains(_city) ? _city : null;

    final filtered = store.walkers.where((w) {
      if (_onlyVerified && !w.verified) return false;
      if (_onlyFavorites && !store.isFavorite(w.id)) return false;
      if (activeCity != null && w.city != activeCity) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        return switch (_sort) {
          _WalkerSort.puan => b.rating.compareTo(a.rating),
          _WalkerSort.ucret => a.pricePerWalk.compareTo(b.pricePerWalk),
        };
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Köpek Gezdirme')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Güvenilir gezdiriciler', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Dostun her gün hareketli kalsın',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Filtre çipleri: tümü + onaylı + favoriler.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: !_onlyVerified &&
                      !_onlyFavorites &&
                      activeCity == null,
                  onTap: () => setState(() {
                    _onlyVerified = false;
                    _onlyFavorites = false;
                    _city = null;
                  }),
                ),
                _FilterChip(
                  label: 'Onaylı',
                  icon: Icons.verified,
                  selected: _onlyVerified,
                  onTap: () => setState(() => _onlyVerified = !_onlyVerified),
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
            const SizedBox(height: 12),

            // Şehir filtresi.
            Row(
              children: [
                Icon(
                  Icons.location_city_outlined,
                  size: 18,
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Şehir:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String?>(
                    value: activeCity,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('Tüm şehirler'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tüm şehirler'),
                      ),
                      for (final c in cities)
                        DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ],
                    onChanged: (value) => setState(() => _city = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sıralama.
            Row(
              children: [
                Text(
                  'Sırala:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                SegmentedButton<_WalkerSort>(
                  segments: const [
                    ButtonSegment(
                      value: _WalkerSort.puan,
                      label: Text('Puan'),
                      icon: Icon(Icons.star_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _WalkerSort.ucret,
                      label: Text('Ücret'),
                      icon: Icon(Icons.payments_outlined, size: 16),
                    ),
                  ],
                  selected: {_sort},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _sort = s.first),
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
                            ? 'Henüz favori gezdirici yok.\nKalbe dokunarak ekleyebilirsin 🐾'
                            : 'Bu filtreye uygun gezdirici yok',
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
              for (final walker in filtered) ...[
                PetWalkerCard(
                  walker: walker,
                  isFavorite: store.isFavorite(walker.id),
                  onFavorite: () => store.toggleFavorite(walker.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WalkerDetailScreen(walker: walker),
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

/// Üstteki onaylı/favori filtre çipi.
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
