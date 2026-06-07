import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../theme/app_colors.dart';

/// Başlık + not alan, yeniden kullanılabilir kayıt formu (alttan panel).
///
/// Hem "Alerji ekle" hem "İlaç ekle" için kullanılır; ikisi de aynı şekle
/// ([HealthRecord]) sahip olduğundan tek form yeterli. Başlık ve alan
/// etiketleri dışarıdan verilir, kaydedilince [onSave] çağrılır.
class NewHealthRecordSheet extends StatefulWidget {
  const NewHealthRecordSheet({
    super.key,
    required this.heading,
    required this.titleLabel,
    required this.titleHint,
    required this.noteLabel,
    required this.noteHint,
    required this.onSave,
  });

  /// Panel başlığı (örn. "Yeni alerji").
  final String heading;
  final String titleLabel;
  final String titleHint;
  final String noteLabel;
  final String noteHint;

  /// Kaydedilince oluşturulan kaydı geri verir.
  final ValueChanged<HealthRecord> onSave;

  /// Paneli açan kısa yardımcı.
  static void show(
    BuildContext context, {
    required String heading,
    required String titleLabel,
    required String titleHint,
    required String noteLabel,
    required String noteHint,
    required ValueChanged<HealthRecord> onSave,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NewHealthRecordSheet(
        heading: heading,
        titleLabel: titleLabel,
        titleHint: titleHint,
        noteLabel: noteLabel,
        noteHint: noteHint,
        onSave: onSave,
      ),
    );
  }

  @override
  State<NewHealthRecordSheet> createState() => _NewHealthRecordSheetState();
}

class _NewHealthRecordSheetState extends State<NewHealthRecordSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    if (title.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldur')),
      );
      return;
    }

    widget.onSave(HealthRecord(title: title, note: note));
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
          Text(widget.heading, style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: widget.titleLabel,
              hintText: widget.titleHint,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: widget.noteLabel,
              hintText: widget.noteHint,
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
    );
  }
}
