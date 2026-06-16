import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal_entry.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Yeni günlük kaydı oluşturma formu (alttan açılan panel).
///
/// Sahip o günkü ruh hâlini seçer ve kısa bir not yazar. Tarih otomatik olarak
/// bugündür. Kaydedilince aktif hayvanın günlüğüne [PassportStore] üzerinden
/// eklenir.
class NewJournalEntrySheet extends StatefulWidget {
  const NewJournalEntrySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewJournalEntrySheet(),
    );
  }

  @override
  State<NewJournalEntrySheet> createState() => _NewJournalEntrySheetState();
}

class _NewJournalEntrySheetState extends State<NewJournalEntrySheet> {
  final _textController = TextEditingController();
  PetMood _mood = PetMood.mutlu;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birkaç kelime yaz')),
      );
      return;
    }

    context.read<PassportStore>().addJournalEntry(
          JournalEntry(
            id: 'j${DateTime.now().millisecondsSinceEpoch}',
            dateLabel: formatTrDayMonth(DateTime.now()),
            mood: _mood,
            text: text,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Günlüğe eklendi 🐾')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Bugün nasıldı?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Ruh hâli seçici.
            Text(
              'Ruh hâli',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mood in PetMood.values)
                  _MoodChip(
                    mood: mood,
                    selected: mood == _mood,
                    onTap: () => setState(() => _mood = mood),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Not',
                hintText: 'Bugün dostunla ne yaşadın?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ruh hâli seçici çipi (emoji + etiket). Seçiliyse rengiyle dolar.
class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final PetMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? mood.color.withValues(alpha: 0.18) : AppColors.card,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? mood.color
                  : AppColors.text.withValues(alpha: 0.12),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                mood.label,
                style: TextStyle(
                  color: selected ? mood.color : AppColors.text,
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
