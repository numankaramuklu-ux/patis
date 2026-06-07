import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/weight_entry.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// "Yeni tartım" ekleme formu (alttan panel).
///
/// Kaydedilince kiloyu [PassportStore]'a ekler; grafikte yeni nokta belirir.
class NewWeightSheet extends StatefulWidget {
  const NewWeightSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewWeightSheet(),
    );
  }

  @override
  State<NewWeightSheet> createState() => _NewWeightSheetState();
}

class _NewWeightSheetState extends State<NewWeightSheet> {
  final _kgController = TextEditingController();
  // Tartım tarihi; varsayılan bugün. Grafikte kısa ay adı (örn. "Tem") görünür.
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _kgController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null) return;
    setState(() => _date = date);
  }

  void _save() {
    // Virgülle yazılmış ondalığı da kabul et (örn. "4,3").
    final text = _kgController.text.trim().replaceAll(',', '.');
    final kg = double.tryParse(text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir kilo gir')),
      );
      return;
    }

    context.read<PassportStore>().addWeight(
          WeightEntry(kg: kg, dateLabel: trMonthShort(_date)),
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
          Text('Yeni tartım', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _kgController,
            // Ondalıklı sayı klavyesi; rakam, nokta ve virgüle izin ver.
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Kilo (kg)',
              hintText: 'Örn. 4.3',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tarih: ${formatTrDate(_date)}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: const Text('Seç'),
              ),
            ],
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
