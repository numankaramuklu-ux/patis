import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sitter_booking.dart';
import '../state/sitter_booking_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Pet sitter'ın yeni bir konaklama rezervasyonu (kayıt) oluşturma formu.
///
/// Hayvan/sahip bilgisi, tür, tarih aralığı ve gecelik ücret alınır; toplam
/// ücret gece sayısından otomatik hesaplanır. Kaydedilince rezervasyon
/// [SitterBookingStore]'a "Onaylı" olarak eklenir (sitter'ın kendi eklediği
/// kayıt zaten kabul edilmiş demektir).
class NewSitterBookingSheet extends StatefulWidget {
  const NewSitterBookingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewSitterBookingSheet(),
    );
  }

  @override
  State<NewSitterBookingSheet> createState() => _NewSitterBookingSheetState();
}

class _NewSitterBookingSheetState extends State<NewSitterBookingSheet> {
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  String _species = 'Kedi';
  DateTime? _startDate;
  DateTime? _endDate;

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

  /// Gece sayısı (giriş–çıkış); ikisi de seçili değilse 0.
  int get _nights {
    if (_startDate == null || _endDate == null) return 0;
    final n = _endDate!.difference(_startDate!).inDays;
    return n < 1 ? 1 : n;
  }

  /// Giriş tarihini seçtirir. Çıkış tarihi giriş öncesinde kalıyorsa sıfırlanır.
  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;
    setState(() {
      _startDate = date;
      if (_endDate != null && !_endDate!.isAfter(date)) _endDate = null;
    });
  }

  /// Çıkış tarihini seçtirir (en erken giriş gününün ertesi günü).
  Future<void> _pickEnd() async {
    final base = _startDate ?? DateTime.now();
    final first = base.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? first,
      firstDate: first,
      lastDate: DateTime(base.year + 2),
    );
    if (date == null) return;
    setState(() => _endDate = date);
  }

  void _save() {
    final petName = _petNameController.text.trim();
    final ownerName = _ownerController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (petName.isEmpty || ownerName.isEmpty) {
      _error('Hayvan adı ve sahip adı zorunlu');
      return;
    }
    if (_startDate == null || _endDate == null) {
      _error('Giriş ve çıkış tarihini seç');
      return;
    }
    if (price <= 0) {
      _error('Gecelik ücreti gir');
      return;
    }

    context.read<SitterBookingStore>().add(
          SitterBooking(
            id: 'sb${DateTime.now().millisecondsSinceEpoch}',
            ownerName: ownerName,
            petName: petName,
            breed: _breedController.text.trim().isEmpty
                ? _species
                : _breedController.text.trim(),
            species: _species,
            startDate: _startDate!,
            endDate: _endDate!,
            pricePerNight: price,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            // Sitter'ın elle eklediği kayıt doğrudan onaylı sayılır.
            status: SitterBookingStatus.onaylandi,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$petName için konaklama eklendi 🏠')),
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
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final total = _nights * price;
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
            Text('Yeni konaklama', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Tür seçimi.
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Kedi',
                  label: Text('Kedi'),
                  icon: Icon(Icons.pets),
                ),
                ButtonSegment(
                  value: 'Köpek',
                  label: Text('Köpek'),
                  icon: Icon(Icons.pets),
                ),
              ],
              selected: {_species},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _species = s.first),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _petNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Hayvan adı',
                hintText: 'Örn. Pamuk',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _breedController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cins (isteğe bağlı)',
                hintText: 'Örn. British Shorthair',
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Sahip adı',
                hintText: 'Örn. Ayşe Y.',
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

            // Tarih aralığı: giriş + çıkış.
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Giriş',
                    value: _startDate,
                    onTap: _pickStart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Çıkış',
                    value: _endDate,
                    onTap: _pickEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gecelik ücret (toplam canlı hesaplanır).
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Gecelik ücret (₺)',
                hintText: 'Örn. 250',
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
                hintText: 'Mama saati, ilaç, alışkanlıklar…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Toplam ücret özeti (gece × gecelik).
            if (_nights > 0 && price > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_nights gece × $price ₺',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Toplam $total ₺',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                child: const Text('Konaklama ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarih seçim alanı (etiket + seçilen tarih ya da yer tutucu, dokununca picker).
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.forest),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value == null ? 'Seç' : formatTrDayMonth(value!),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: value == null
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
