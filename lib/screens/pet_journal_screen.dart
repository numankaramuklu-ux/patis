import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal_entry.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../widgets/new_journal_entry_sheet.dart';

/// Aktif evcil hayvanın günlüğü.
///
/// Sahibin tuttuğu ruh hâli + not kayıtlarını en yeni üstte gösterir. FAB ile
/// yeni kayıt eklenir, sola kaydırınca (onaylı) silinir. Kayıtlar aktif hayvana
/// aittir; pasaporttaki hayvan değişirse içerik de değişir. [PassportStore]'dan
/// canlı beslenir.
class PetJournalScreen extends StatelessWidget {
  const PetJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<PassportStore>();
    final petName = store.pet.name;
    final entries = store.journal;

    return Scaffold(
      appBar: AppBar(title: Text('$petName günlüğü')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewJournalEntrySheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Not ekle'),
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 56,
                          color: AppColors.forest.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        '$petName için henüz günlük yok.\nSağ alttan ilk notu ekle 🐾',
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                children: [
                  for (final entry in entries) ...[
                    _JournalCard(
                      entry: entry,
                      onDelete: () => store.deleteJournalEntry(entry.id),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Günlükteki tek bir kayıt kartı. Sola kaydırınca (onay sonrası) silinir.
class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry, required this.onDelete});

  final JournalEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = entry.mood;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.terracotta,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.cream),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günlük kaydı silindi')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ruh hâli rozeti (emoji + etiket).
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: mood.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        mood.label,
                        style: TextStyle(
                          color: mood.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  entry.dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(entry.text, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// Silmeden önce onay sorar (kaza ile kaydırmayı önler).
  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaydı sil'),
        content: const Text('Bu günlük kaydı silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
