import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../theme/app_colors.dart';

/// Kilo takibini gösteren kart: üstte son kilo + değişim özeti, altta
/// zaman içindeki değişimi gösteren küçük çizgi grafik (fl_chart).
///
/// Tartım listesini dışarıdan [WeightEntry] listesi olarak alır (en eskiden
/// en yeniye sıralı bekler).
class WeightChartCard extends StatelessWidget {
  const WeightChartCard({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Özet için son iki tartımı kullanıyoruz: son kilo + bir öncekine göre fark.
    final last = entries.last;
    final previous = entries.length > 1 ? entries[entries.length - 2] : null;
    final diff = previous == null ? 0.0 : last.kg - previous.kg;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Üst özet satırı: güncel kilo + değişim rozeti ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${last.kg.toStringAsFixed(1)} kg',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'güncel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const Spacer(),
              if (previous != null) _ChangeBadge(diff: diff),
            ],
          ),
          const SizedBox(height: 20),
          // ---- Çizgi grafik ----
          // Sabit bir yükseklik veriyoruz; grafik genişliği kadar yer kaplar.
          SizedBox(
            height: 140,
            child: LineChart(_buildChartData(context)),
          ),
        ],
      ),
    );
  }

  /// Grafiğin tüm ayarlarını üreten yardımcı metot. build() kalabalıklaşmasın
  /// diye ayrı tuttuk.
  LineChartData _buildChartData(BuildContext context) {
    final theme = Theme.of(context);

    // Her tartımı (x = sıra, y = kilo) bir noktaya çeviriyoruz.
    final spots = <FlSpot>[
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].kg),
    ];

    // Y eksenini verinin biraz altından/üstünden başlatıp grafiği ortalıyoruz.
    final values = entries.map((e) => e.kg);
    final minY = values.reduce((a, b) => a < b ? a : b) - 0.5;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 0.5;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      // Sade görünüm için üst/sağ/sol başlıkları gizliyoruz; sadece alt
      // (tarih) etiketleri kalsın.
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              // Geçersiz/aradaki değerler için boş döneriz.
              if (index < 0 || index >= entries.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  entries[index].dateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      // Yatay hafif kılavuz çizgileri; dikey çizgileri kapatıyoruz.
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.text.withValues(alpha: 0.06),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, // köşeleri yumuşat → organik görünüm
          color: AppColors.forest,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: AppColors.card,
              strokeWidth: 2,
              strokeColor: AppColors.forest,
            ),
          ),
          // Çizginin altını yumuşak yeşil bir dolguyla boyuyoruz.
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.forest.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

/// Bir önceki tartıma göre kilo değişimini gösteren küçük rozet.
///
/// Artış kırmızımsı (terracotta), azalış yeşil olarak renklenir; oklar da
/// yönü gösterir. Sadece bu kartta kullanıldığı için private.
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.diff});

  final double diff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUp = diff > 0;
    final isFlat = diff == 0;

    final color = isFlat
        ? AppColors.text.withValues(alpha: 0.5)
        : (isUp ? AppColors.terracotta : AppColors.forest);

    final icon = isFlat
        ? Icons.remove
        : (isUp ? Icons.arrow_upward : Icons.arrow_downward);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${diff.abs().toStringAsFixed(1)} kg',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
