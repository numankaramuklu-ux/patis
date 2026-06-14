import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_patient.dart';
import '../models/vet_prescription.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Bir hastaya reçete yazma formu (alttan açılan panel).
///
/// Hasta detayındaki "Reçete" butonu açar. Birden çok ilaç satırı (ad +
/// doz/kullanım) eklenebilir, ek bir not yazılabilir. Kaydedilince reçete
/// [VetStore]'a hasta kimliğiyle eklenir ve detayda "Reçeteler" altında görünür.
class NewPrescriptionSheet extends StatefulWidget {
  const NewPrescriptionSheet({super.key, required this.patient});

  final VetPatient patient;

  static void show(BuildContext context, VetPatient patient) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NewPrescriptionSheet(patient: patient),
    );
  }

  @override
  State<NewPrescriptionSheet> createState() => _NewPrescriptionSheetState();
}

/// Form üzerindeki tek bir ilaç satırının controller'ları.
class _MedicineRow {
  _MedicineRow()
      : nameController = TextEditingController(),
        dosageController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController dosageController;

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
  }
}

class _NewPrescriptionSheetState extends State<NewPrescriptionSheet> {
  // En az bir ilaç satırıyla başla.
  final List<_MedicineRow> _rows = [_MedicineRow()];
  final _noteController = TextEditingController();

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_MedicineRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _save() {
    // Adı dolu olan satırları al.
    final medicines = <VetPrescriptionMedicine>[];
    for (final row in _rows) {
      final name = row.nameController.text.trim();
      if (name.isEmpty) continue;
      medicines.add(VetPrescriptionMedicine(
        name: name,
        dosage: row.dosageController.text.trim(),
      ));
    }

    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir ilaç adı gir')),
      );
      return;
    }

    final note = _noteController.text.trim();
    context.read<VetStore>().addPrescription(
          widget.patient.id,
          VetPrescription(
            dateLabel: formatTrDayMonth(DateTime.now()),
            medicines: medicines,
            note: note.isEmpty ? null : note,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.patient.petName} için reçete kaydedildi')),
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
            Text('Reçete yaz', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.patient.petName} • ${widget.patient.ownerName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'İlaçlar',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _rows.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: _rows[i].nameController,
                      decoration: const InputDecoration(
                        labelText: 'İlaç adı',
                        hintText: 'Örn. Amoksisilin',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _rows[i].dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Doz',
                        hintText: '2x1, 5 gün',
                        isDense: true,
                      ),
                    ),
                  ),
                  // İlk satır silinemez (en az bir tane kalsın).
                  IconButton(
                    onPressed: _rows.length > 1 ? () => _removeRow(i) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.terracotta,
                    tooltip: 'Satırı sil',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('İlaç ekle'),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Not (opsiyonel)',
                hintText: 'Örn. Tok karnına alınmalı',
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
                child: const Text('Reçeteyi kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
