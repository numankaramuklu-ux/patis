import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_appointment.dart';
import '../models/vet_patient.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Bir hasta için yeni randevu oluşturma formu (alttan açılan panel).
///
/// Hasta detayındaki "Randevu" butonu açar; hayvan/sahip bilgisi hastadan
/// ön-doldurulur. Kaydedilince randevu [VetStore]'a eklenir ve Randevular
/// ekranı/takviminde görünür.
class NewVetAppointmentSheet extends StatefulWidget {
  const NewVetAppointmentSheet({super.key, required this.patient});

  final VetPatient patient;

  static void show(BuildContext context, VetPatient patient) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NewVetAppointmentSheet(patient: patient),
    );
  }

  @override
  State<NewVetAppointmentSheet> createState() => _NewVetAppointmentSheetState();
}

class _NewVetAppointmentSheetState extends State<NewVetAppointmentSheet> {
  final _reasonController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _priceController = TextEditingController();

  VetApptType _type = VetApptType.kontrol;
  DateTime? _dateTime;

  @override
  void dispose() {
    _reasonController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// "14 Haziran, 14:30" biçiminde etiket (önizleme için).
  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${formatTrDayMonth(dt)}, $hour:$minute';
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty || _dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen sebep ve tarih/saat gir')),
      );
      return;
    }

    final dt = _dateTime!;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    context.read<VetStore>().addAppointment(
          VetAppointment(
            id: 'v${DateTime.now().millisecondsSinceEpoch}',
            patientId: widget.patient.id,
            petName: widget.patient.petName,
            breed: widget.patient.breed,
            ownerName: widget.patient.ownerName,
            type: _type,
            reason: reason,
            durationMin: duration,
            price: price,
            date: DateTime(dt.year, dt.month, dt.day),
            time: time,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.patient.petName} için randevu eklendi')),
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
            Text('Yeni randevu', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.patient.petName} • ${widget.patient.ownerName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // Randevu türü.
            Text(
              'Tür',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in VetApptType.values)
                  ChoiceChip(
                    label: Text(t.label),
                    avatar: Icon(
                      t.icon,
                      size: 16,
                      color: _type == t ? AppColors.cream : t.color,
                    ),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                    showCheckmark: false,
                    backgroundColor: AppColors.card,
                    selectedColor: t.color,
                    labelStyle: TextStyle(
                      color: _type == t ? AppColors.cream : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Sebep / işlem',
                hintText: 'Örn. Aşı kontrolü',
              ),
            ),
            const SizedBox(height: 20),

            // Tarih/saat seçici.
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dateTime == null
                        ? 'Tarih / saat seçilmedi'
                        : _formatDateTime(_dateTime!),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _dateTime == null
                          ? AppColors.text.withValues(alpha: 0.5)
                          : AppColors.text,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Tarih seç'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Süre + ücret yan yana.
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Süre (dk)',
                      hintText: '30',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ücret (₺)',
                      hintText: 'Örn. 400',
                    ),
                  ),
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
                child: const Text('Randevu oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
