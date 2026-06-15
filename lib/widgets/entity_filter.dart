import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// İşletme randevu ekranlarında müşteriye/hastaya göre süzme için açılır liste.
///
/// Seçenekler kimlik→ad eşlemesidir ([SalonClient.id] / [VetPatient.id]); bu
/// sayede süzme gerçek kayıt kimliği üzerinden yapılır (yalnızca ada göre değil).
/// `null` seçimi "Tümü" anlamına gelir.
class EntityFilter extends StatelessWidget {
  const EntityFilter({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  /// Alan etiketi (örn. "Müşteri" / "Hasta").
  final String label;

  /// Seçenekler: kimlik → görünen ad. Ekleme sırası korunur.
  final Map<String, String> options;

  /// Seçili kimlik; null = Tümü.
  final String? selected;

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.pets),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
        for (final entry in options.entries)
          DropdownMenuItem<String?>(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
