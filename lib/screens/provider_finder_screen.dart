import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_provider.dart';
import '../state/service_provider_store.dart';
import '../theme/app_colors.dart';
import '../widgets/service_provider_card.dart';
import 'provider_detail_screen.dart';

/// Sıralama ölçütü.
enum _Sort { puan, ucret }

/// Veteriner veya kuaför bulma ekranı (türü [kind] ile gelir).
///
/// Ana Sayfa'daki "Veteriner" / "Kuaför" kutusundan açılır. Şehre göre
/// filtrelenip puana/ücrete göre sıralanabilir, favorilere eklenebilir; karta
/// dokununca yorumlu detay ekranı açılır. Veriler [ServiceProviderStore]'dan.
class ProviderFinderScreen extends StatefulWidget {
  const ProviderFinderScreen({super.key, required this.kind});

  final ProviderKind kind;

  @override
  State<ProviderFinderScreen> createState() => _ProviderFinderScreenState();
}

class _ProviderFinderScreenState extends State<ProviderFinderScreen> {
  bool _onlyVerified = false;
  bool _onlyFavorites = false;
  String? _city;
  _Sort _sort = _Sort.puan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<ServiceProviderStore>();
    final all = store.byKind(widget.kind);

    final cities = all.map((p) => p.city).toSet().toList()..sort();
    final activeCity = _city != null && cities.contains(_city) ? _city : null;

    final filtered = all.where((p) {
      if (_onlyVerified && !p.verified) return false;
      if (_onlyFavorites && !store.isFavorite(p.id)) return false;
      if (activeCity != null && p.city != activeCity) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        return switch (_sort) {
          _Sort.puan => b.rating.compareTo(a.rating),
          _Sort.ucret => (a.priceFrom ?? 1 << 30).compareTo(b.priceFrom ?? 1 << 30),
        };
      });

    final isVet = widget.kind == ProviderKind.veteriner;

    return Scaffold(
      appBar: AppBar(title: Text(widget.kind.plural)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              isVet ? 'Güvenilir veterinerler' : 'Usta kuaförler',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              isVet
                  ? 'Dostunun sağlığı emin ellerde'
                  : 'Dostun bakımlı ve mutlu kalsın',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

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

            Row(
              children: [
                Text(
                  'Sırala:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                SegmentedButton<_Sort>(
                  segments: const [
                    ButtonSegment(
                      value: _Sort.puan,
                      label: Text('Puan'),
                      icon: Icon(Icons.star_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _Sort.ucret,
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
                  child: Text(
                    _onlyFavorites
                        ? 'Henüz favori yok.\nKalbe dokunarak ekleyebilirsin 🐾'
                        : 'Bu filtreye uygun sonuç yok',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              for (final p in filtered) ...[
                ServiceProviderCard(
                  provider: p,
                  isFavorite: store.isFavorite(p.id),
                  onFavorite: () => store.toggleFavorite(p.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProviderDetailScreen(provider: p),
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
