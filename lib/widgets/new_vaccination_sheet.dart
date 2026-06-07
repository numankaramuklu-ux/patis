import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vaccination.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// "Yeni aşı" ekleme formu (alttan açılan panel).
///
/// Kaydedilince aşıyı [PassportStore]'a ekler. Diğer formlarla aynı deseni
/// izler.
class NewVaccinationSheet extends StatefulWidget {
  const NewVaccinationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewVaccinationSheet(),
    );
  }

  @override
  State<NewVaccinationSheet> createState() => _NewVaccinationSheetState();
}

class _NewVaccinationSheetState extends State<NewVaccinationSheet> {
  final _nameController = TextEditingController();
  DateTime? _date; // yapıldığı tarih
  DateTime? _nextDue; // sonraki doz (isteğe bağlı)

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Tarih seçtiren diyaloğu açar. [forNextDue] ise sonuç sonraki doz alanına
  /// yazılır, değilse yapıldığı tarihe.
  Future<void> _pickDate({required bool forNextDue}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      // Yapılan aşı geçmişte, sonraki doz gelecekte olabilir → geniş aralık.
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    setState(() {
      if (forNextDue) {
        _nextDue = date;
      } else {
        _date = date;
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen aşı adı ve tarihi gir')),
      );
      return;
    }

    context.read<PassportStore>().addVaccination(
          Vaccination(
            name: name,
            dateLabel: formatTrDate(_date!),
            nextDueLabel: _nextDue == null ? null : formatTrDate(_nextDue!),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Text('Yeni aşı', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Aşı adı',
              hintText: 'Örn. Kuduz',
            ),
          ),
          const SizedBox(height: 8),
          _DateRow(
            label: _date == null ? 'Yapıldığı tarih seçilmedi' : formatTrDate(_date!),
            isSet: _date != null,
            onPick: () => _pickDate(forNextDue: false),
          ),
          _DateRow(
            label: _nextDue == null
                ? 'Sonraki doz (isteğe bağlı)'
                : 'Sonraki doz: ${formatTrDate(_nextDue!)}',
            isSet: _nextDue != null,
            onPick: () => _pickDate(forNextDue: true),
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
    );
  }
}

/// Tarih seçici satırı: solda seçilen tarih/etiket, sağda "Seç" butonu.
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.isSet,
    required this.onPick,
  });

  final String label;
  final bool isSet;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isSet
                  ? AppColors.text
                  : AppColors.text.withValues(alpha: 0.5),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: const Text('Seç'),
        ),
      ],
    );
  }
}
