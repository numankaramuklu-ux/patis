import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sitter_booking.dart';
import '../state/sitter_booking_store.dart';
import '../theme/app_colors.dart';
import 'pet_sitter_dashboard_screen.dart';
import '../widgets/new_sitter_booking_sheet.dart';
import '../widgets/sitter_booking_card.dart';

/// Pet sitter rolünün Randevu sekmesi: "Takvim" (konaklama programı).
///
/// Üstte durum filtreleri (Tümü / Bekliyor / Onaylı / Tamamlandı / İptal),
/// altında başlangıç gününe göre (Bugün, Yarın, …) gruplanmış konaklama
/// kartları. Karta dokununca aksiyon paneli açılır. Veriler
/// [SitterBookingStore]'dan gelir.
class SitterScheduleScreen extends StatefulWidget {
  const SitterScheduleScreen({super.key});

  @override
  State<SitterScheduleScreen> createState() => _SitterScheduleScreenState();
}

class _SitterScheduleScreenState extends State<SitterScheduleScreen> {
  // null = "Tümü". Aksi halde sadece bu durumdaki rezervasyonlar gösterilir.
  SitterBookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<SitterBookingStore>();
    final all = store.bookings;

    final filtered = _filter == null
        ? all
        : all.where((b) => b.status == _filter).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Takvim', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${store.activeCount} aktif konaklama • ${store.pendingCount} onay bekliyor',
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
        onPressed: () => NewSitterBookingSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Yeni konaklama'),
      ),
    );
  }

  List<Widget> _listView(ThemeData theme, List<SitterBooking> filtered) {
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
                'Bu filtrede konaklama yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Başlangıç gününe göre grupla (liste zaten tarih sırasında).
    final days = <String>[];
    for (final b in filtered) {
      if (!days.contains(b.dayLabel)) days.add(b.dayLabel);
    }
    return [
      for (final day in days) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(day, style: theme.textTheme.titleLarge),
        ),
        for (final b in filtered.where((b) => b.dayLabel == day)) ...[
          SitterBookingCard(
            booking: b,
            onTap: () => SitterBookingDetailSheet.show(context, b),
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

  final SitterBookingStatus? selected;
  final ValueChanged<SitterBookingStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(String, SitterBookingStatus?)>[
      ('Tümü', null),
      for (final s in SitterBookingStatus.values) (s.label, s),
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
