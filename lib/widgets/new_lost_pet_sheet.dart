import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/adoption_listing.dart';
import '../models/lost_pet.dart';
import '../state/lost_pet_store.dart';
import '../theme/app_colors.dart';

/// "Kayıp bildir" formu (alttan açılan panel).
///
/// Kullanıcı girişi zaman içinde değiştiği için [StatefulWidget]. Kaydedilince
/// ilanı [LostPetStore]'a ekler ve paneli kapatır. Randevu formuyla aynı
/// deseni izler.
class NewLostPetSheet extends StatefulWidget {
  const NewLostPetSheet({super.key});

  /// Paneli açan kısa yardımcı. Kayıp ekranı bunu çağırır.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true, // klavye açılınca panel yukarı kayabilsin
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewLostPetSheet(),
    );
  }

  @override
  State<NewLostPetSheet> createState() => _NewLostPetSheetState();
}

class _NewLostPetSheetState extends State<NewLostPetSheet> {
  // Türkçe ay isimleri — seçilen tarihi "5 Haziran" gibi etikete çevirmek için.
  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form üzerinde o an seçili değerler.
  LostPetStatus _status = LostPetStatus.kayip;
  AdoptionSpecies _species = AdoptionSpecies.kedi;
  bool _hasReward = false;
  DateTime? _date;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Seçilen tarihi "5 Haziran" biçiminde metne çevirir.
  String _formatDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]}';

  /// Tarih seçtiren sistem diyaloğunu açar. Kayıp/bulunma geçmişte de
  /// olabileceği için 1 yıl öncesine kadar seçime izin veriyoruz.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (date == null) return; // kullanıcı vazgeçti
    setState(() => _date = date);
  }

  /// Formu doğrular ve geçerliyse ilanı depoya ekler.
  void _save() {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    // Yer, açıklama ve tarih zorunlu; ad boş bırakılabilir ("İsimsiz" olur).
    if (location.isEmpty || description.isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yer, açıklama ve tarihi doldur')),
      );
      return;
    }

    context.read<LostPetStore>().add(
          LostPet(
            name: name.isEmpty ? 'İsimsiz' : name,
            species: _species,
            status: _status,
            location: location,
            dateLabel: _formatDate(_date!),
            description: description,
            hasReward: _hasReward,
          ),
        );
    Navigator.of(context).pop(); // paneli kapat
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      // Form uzun olduğu için küçük ekranlarda taşmasın diye kaydırılabilir.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aşağı çekme tutamağı (ortalı).
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
            Text('Kayıp bildir', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            // Durum: Kayıp mı Bulundu mu?
            SegmentedButton<LostPetStatus>(
              segments: const [
                ButtonSegment(
                  value: LostPetStatus.kayip,
                  label: Text('Kayıp'),
                  icon: Icon(Icons.error_outline),
                ),
                ButtonSegment(
                  value: LostPetStatus.bulundu,
                  label: Text('Bulundu'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (selection) {
                setState(() => _status = selection.first);
              },
            ),
            const SizedBox(height: 16),
            // Tür: Kedi / Köpek.
            SegmentedButton<AdoptionSpecies>(
              segments: const [
                ButtonSegment(
                  value: AdoptionSpecies.kedi,
                  label: Text('Kedi'),
                  icon: Icon(Icons.pets),
                ),
                ButtonSegment(
                  value: AdoptionSpecies.kopek,
                  label: Text('Köpek'),
                  icon: Icon(Icons.pets),
                ),
              ],
              selected: {_species},
              onSelectionChanged: (selection) {
                setState(() => _species = selection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad (isteğe bağlı)',
                hintText: 'Örn. Boncuk',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Yer',
                hintText: 'Örn. Beşiktaş, İstanbul',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Renk, tasma, davranış gibi ayırt edici özellikler',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            // Ödül anahtarı.
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.gold,
              title: const Text('Ödül var'),
              value: _hasReward,
              onChanged: (value) => setState(() => _hasReward = value),
            ),
            // Tarih seçici satırı.
            Row(
              children: [
                Expanded(
                  child: Text(
                    _date == null ? 'Tarih seçilmedi' : _formatDate(_date!),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _date == null
                          ? AppColors.text.withValues(alpha: 0.5)
                          : AppColors.text,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Tarih seç'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('İlanı yayınla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
