import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dog_walk.dart';
import '../state/walk_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Pet walker'ın yeni bir köpek yürüyüşü ekleme formu (alttan açılan panel).
///
/// Köpek/sahip bilgisi, tarih + saat, süre ve ücret alınır. Kaydedilince
/// yürüyüş [WalkStore]'a "Onaylı" olarak eklenir (walker'ın kendi eklediği
/// kayıt zaten kabul edilmiş demektir).
class NewDogWalkSheet extends StatefulWidget {
  const NewDogWalkSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewDogWalkSheet(),
    );
  }

  @override
  State<NewDogWalkSheet> createState() => _NewDogWalkSheetState();
}

class _NewDogWalkSheetState extends State<NewDogWalkSheet> {
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  // Seçilebilir süreler (dakika).
  static const _durations = [30, 45, 60];
  int _duration = 30;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;
    setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() => _time = time);
  }

  String get _timeLabel => _time == null
      ? 'Seç'
      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  void _save() {
    final petName = _petNameController.text.trim();
    final ownerName = _ownerController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (petName.isEmpty || ownerName.isEmpty) {
      _error('Köpek adı ve sahip adı zorunlu');
      return;
    }
    if (_date == null || _time == null) {
      _error('Tarih ve saati seç');
      return;
    }
    if (price <= 0) {
      _error('Ücreti gir');
      return;
    }

    final time =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

    context.read<WalkStore>().add(
          DogWalk(
            id: 'wk${DateTime.now().millisecondsSinceEpoch}',
            ownerName: ownerName,
            petName: petName,
            breed: _breedController.text.trim().isEmpty
                ? 'Belirtilmemiş'
                : _breedController.text.trim(),
            date: DateTime(_date!.year, _date!.month, _date!.day),
            time: time,
            durationMin: _duration,
            price: price,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            // Walker'ın elle eklediği kayıt doğrudan onaylı sayılır.
            status: WalkStatus.onaylandi,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$petName için yürüyüş eklendi 🐕')),
    );
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            Text('Yeni yürüyüş', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            TextField(
              controller: _petNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Köpek adı',
                hintText: 'Örn. Karamel',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _breedController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cins (isteğe bağlı)',
                hintText: 'Örn. Pomeranian',
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Sahip adı',
                hintText: 'Örn. Mert K.',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon (isteğe bağlı)',
                hintText: 'Örn. 0532 111 22 33',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Tarih + saat seçiciler.
            Row(
              children: [
                Expanded(
                  child: _PickerField(
                    label: 'Tarih',
                    icon: Icons.calendar_today_outlined,
                    value: _date == null ? 'Seç' : formatTrDayMonth(_date!),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerField(
                    label: 'Saat',
                    icon: Icons.schedule,
                    value: _timeLabel,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Süre seçimi.
            Text('Süre', style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            )),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (final d in _durations)
                  ButtonSegment(value: d, label: Text('$d dk')),
              ],
              selected: {_duration},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _duration = s.first),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ücret (₺)',
                hintText: 'Örn. 120',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                hintText: 'Mizaç, alışkanlık, rota tercihi…',
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
                child: const Text('Yürüyüş ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarih/saat seçim alanı (etiket + seçilen değer ya da yer tutucu).
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = value == 'Seç';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.forest),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: empty
                          ? AppColors.text.withValues(alpha: 0.5)
                          : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
