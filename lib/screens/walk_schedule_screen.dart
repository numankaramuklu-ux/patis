import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dog_walk.dart';
import '../state/walk_store.dart';
import '../theme/app_colors.dart';
import '../widgets/dog_walk_card.dart';
import '../widgets/new_dog_walk_sheet.dart';
import 'pet_walker_dashboard_screen.dart';

/// Pet walker rolünün Randevu sekmesi: "Program" (yürüyüş takvimi).
///
/// Üstte durum filtreleri (Tümü / Bekliyor / Onaylı / Tamamlandı / İptal),
/// altında güne göre (Bugün, Yarın, …) gruplanmış yürüyüş kartları. Karta
/// dokununca aksiyon paneli açılır. Veriler [WalkStore]'dan gelir.
class WalkScheduleScreen extends StatefulWidget {
  const WalkScheduleScreen({super.key});

  @override
  State<WalkScheduleScreen> createState() => _WalkScheduleScreenState();
}

class _WalkScheduleScreenState extends State<WalkScheduleScreen> {
  // null = "Tümü". Aksi halde sadece bu durumdaki yürüyüşler gösterilir.
  WalkStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<WalkStore>();
    final all = store.walks;

    final filtered =
        _filter == null ? all : all.where((w) => w.status == _filter).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Program', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Bugün ${store.todayCount} yürüyüş • ${store.pendingCount} onay bekliyor',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            _FilterChips(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 20),
            ..._listView(theme, filtered),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewDogWalkSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Yeni yürüyüş'),
      ),
    );
  }

  List<Widget> _listView(ThemeData theme, List<DogWalk> filtered) {
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 56,
                color: AppColors.text.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Bu filtrede yürüyüş yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Güne göre grupla (liste zaten gün/saat sırasında).
    final days = <String>[];
    for (final w in filtered) {
      if (!days.contains(w.dayLabel)) days.add(w.dayLabel);
    }
    return [
      for (final day in days) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(day, style: theme.textTheme.titleLarge),
        ),
        for (final w in filtered.where((w) => w.dayLabel == day)) ...[
          DogWalkCard(
            walk: w,
            onTap: () => WalkDetailSheet.show(context, w),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    ];
  }
}

/// Durum filtresi seçici (yatay chip dizisi).
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final WalkStatus? selected;
  final ValueChanged<WalkStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(String, WalkStatus?)>[
      ('Tümü', null),
      for (final s in WalkStatus.values) (s.label, s),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, value) = items[i];
          final active = selected == value;
          return ChoiceChip(
            label: Text(label),
            selected: active,
            onSelected: (_) => onChanged(value),
            showCheckmark: false,
            backgroundColor: AppColors.card,
            selectedColor: AppColors.forest,
            labelStyle: TextStyle(
              color: active ? AppColors.cream : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: active
                    ? AppColors.forest
                    : AppColors.text.withValues(alpha: 0.15),
              ),
            ),
          );
        },
      ),
    );
  }
}
