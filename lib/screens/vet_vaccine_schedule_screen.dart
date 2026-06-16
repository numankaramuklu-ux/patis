import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_patient.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import 'vet_patient_detail_screen.dart';

/// Veteriner kliniğinin "Aşı takvimi" ekranı.
///
/// Tüm hastaların sıradaki dozu olan aşılarını ([VetVaccination.nextDueLabel])
/// tek bir listede toplar ve tarihe göre (en yakın üstte) sıralar. Her satır
/// hayvanı, sahibini, aşıyı ve kalan süreyi gösterir; karta dokununca hastanın
/// detayına gider. Salt-okunur bir özet — veriyi [VetStore]'dan türetir.
class VetVaccineScheduleScreen extends StatelessWidget {
  const VetVaccineScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patients = context.watch<VetStore>().patients;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Her hastanın sıradaki dozu olan aşılarını tek listede topla.
    final entries = <_VaccineEntry>[];
    for (final patient in patients) {
      for (final vac in patient.vaccinations) {
        final due = vac.nextDueLabel;
        if (due == null) continue;
        entries.add(_VaccineEntry(
          patient: patient,
          vaccineName: vac.name,
          dueLabel: due,
          dueDate: parseTrDate(due, now: now),
        ));
      }
    }

    // Tarihe göre sırala; ayrıştırılamayanlar en sona.
    entries.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    final overdue = entries
        .where((e) => e.dueDate != null && e.dueDate!.isBefore(today))
        .length;
    final thisMonth = entries
        .where((e) =>
            e.dueDate != null &&
            !e.dueDate!.isBefore(today) &&
            e.dueDate!.year == now.year &&
            e.dueDate!.month == now.month)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Aşı takvimi')),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.vaccines_outlined,
                          size: 56,
                          color: AppColors.forest.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        'Sıradaki dozu olan aşı yok 🐾',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _StatsCard(
                    total: entries.length,
                    overdue: overdue,
                    thisMonth: thisMonth,
                  ),
                  const SizedBox(height: 20),
                  for (final entry in entries) ...[
                    _VaccineCard(
                      entry: entry,
                      today: today,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              VetPatientDetailScreen(patient: entry.patient),
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

/// Listedeki tek bir aşı kaydı (hasta + aşı + sıradaki doz tarihi).
class _VaccineEntry {
  const _VaccineEntry({
    required this.patient,
    required this.vaccineName,
    required this.dueLabel,
    required this.dueDate,
  });

  final VetPatient patient;
  final String vaccineName;
  final String dueLabel;

  /// [dueLabel]'dan ayrıştırılan tarih; ayrıştırılamazsa null.
  final DateTime? dueDate;
}

/// Üstteki özet kart (forest zeminli): toplam, geciken, bu ay.
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.total,
    required this.overdue,
    required this.thisMonth,
  });

  final int total;
  final int overdue;
  final int thisMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Stat(value: '$total', label: 'sıradaki aşı'),
          _divider(),
          _Stat(value: '$thisMonth', label: 'bu ay'),
          _divider(),
          _Stat(value: '$overdue', label: 'geciken'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: AppColors.cream.withValues(alpha: 0.2),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek bir aşı satırı; sağda kalan süreyi renkli bir rozet olarak gösterir.
class _VaccineCard extends StatelessWidget {
  const _VaccineCard({
    required this.entry,
    required this.today,
    required this.onTap,
  });

  final _VaccineEntry entry;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = entry.patient;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.vaccines_outlined,
                    color: AppColors.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.vaccineName} • ${patient.petName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sahibi: ${patient.ownerName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tarih: ${entry.dueLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _DueBadge(dueDate: entry.dueDate, today: today),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kalan süreyi renkli rozet olarak gösterir: geciken (terracotta), 7 günden
/// az (gold), ileri tarih (forest). Tarih ayrıştırılamadıysa rozet gösterilmez.
class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.dueDate, required this.today});

  final DateTime? dueDate;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final due = dueDate;
    if (due == null) return const SizedBox.shrink();

    final days = due.difference(today).inDays;
    final String label;
    final Color color;
    if (days < 0) {
      label = '${-days} gün geçti';
      color = AppColors.terracotta;
    } else if (days == 0) {
      label = 'Bugün';
      color = AppColors.terracotta;
    } else if (days <= 7) {
      label = '$days gün';
      color = AppColors.gold;
    } else {
      label = '$days gün';
      color = AppColors.forest;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
