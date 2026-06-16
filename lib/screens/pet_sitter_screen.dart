import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_sitter.dart';
import '../state/pet_sitter_store.dart';
import '../theme/app_colors.dart';
import '../widgets/new_pet_sitter_sheet.dart';
import '../widgets/pet_sitter_card.dart';
import 'pet_sitter_detail_screen.dart';

/// Bakıcıların sıralama ölçütü.
enum _SitterSort { puan, ucret }

/// Pet sitter bulma ekranı (yol haritası #4).
///
/// Ana Sayfa'daki "Pet Sitter" kutusundan açılır. Bakıcılar türe göre
/// filtrelenip puana/ücrete göre sıralanabilir, favorilere eklenebilir ve
/// karta dokununca detay açılır. Kullanıcı "Bakıcı ol" ile kendi ilanını
/// ekleyebilir. Veriler [PetSitterStore]'dan gelir (kalıcı).
class PetSitterScreen extends StatefulWidget {
  const PetSitterScreen({super.key});

  @override
  State<PetSitterScreen> createState() => _PetSitterScreenState();
}

class _PetSitterScreenState extends State<PetSitterScreen> {
  SitterPet? _pet; // null = tüm türler
  bool _onlyVerified = false;
  bool _onlyFavorites = false;
  String? _city; // null = tüm şehirler
  _SitterSort _sort = _SitterSort.puan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<PetSitterStore>();

    // Mevcut bakıcılardan benzersiz şehir listesi (alfabetik).
    final cities = store.sitters.map((s) => s.city).toSet().toList()..sort();
    // Seçili şehir artık listede yoksa (ör. veri değişti) filtreyi sıfırla.
    final activeCity = _city != null && cities.contains(_city) ? _city : null;

    final filtered =
        store.sitters.where((s) {
          if (_pet != null && !s.accepts.contains(_pet)) return false;
          if (_onlyVerified && !s.verified) return false;
          if (_onlyFavorites && !store.isFavorite(s.id)) return false;
          if (activeCity != null && s.city != activeCity) return false;
          return true;
        }).toList()..sort((a, b) {
          return switch (_sort) {
            _SitterSort.puan => b.rating.compareTo(a.rating),
            _SitterSort.ucret => a.pricePerDay.compareTo(b.pricePerDay),
          };
        });

    return Scaffold(
      appBar: AppBar(title: const Text('Pet Sitter')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewPetSitterSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Bakıcı ol'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text('Güvenilir bakıcılar', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Sen yokken dostun emin ellerde',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Filtre çipleri: tür + onaylı + favoriler.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected:
                      _pet == null &&
                      !_onlyVerified &&
                      !_onlyFavorites &&
                      activeCity == null,
                  onTap: () => setState(() {
                    _pet = null;
                    _onlyVerified = false;
                    _onlyFavorites = false;
                    _city = null;
                  }),
                ),
                for (final pet in SitterPet.values)
                  _FilterChip(
                    label: pet.label,
                    icon: pet.icon,
                    selected: _pet == pet,
                    onTap: () => setState(() => _pet = pet),
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

            // Şehir filtresi (açılır menü).
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
                SegmentedButton<_SitterSort>(
                  segments: const [
                    ButtonSegment(
                      value: _SitterSort.puan,
                      label: Text('Puan'),
                      icon: Icon(Icons.star_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _SitterSort.ucret,
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
                            ? 'Henüz favori bakıcı yok.\nKalbe dokunarak ekleyebilirsin 🐾'
                            : 'Bu filtreye uygun bakıcı yok',
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
              for (final sitter in filtered) ...[
                PetSitterCard(
                  sitter: sitter,
                  isFavorite: store.isFavorite(sitter.id),
                  onFavorite: () => store.toggleFavorite(sitter.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PetSitterDetailScreen(sitter: sitter),
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

/// Üstteki tür/onaylı/favori filtre çipi.
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
