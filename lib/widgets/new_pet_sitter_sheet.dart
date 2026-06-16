import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/pet_sitter.dart';
import '../state/pet_sitter_store.dart';
import '../theme/app_colors.dart';

/// Yeni pet sitter (bakıcı) ilanı oluşturma formu (alttan açılan panel).
///
/// Kullanıcı bakıcı olarak ad, semt, günlük ücret, baktığı türler, iletişim ve
/// kısa bir tanıtım girer. Kaydedilince ilan [PetSitterStore]'a eklenir ve
/// listenin başında görünür. Kullanıcı ilanları "Onaylı" değildir.
class NewPetSitterSheet extends StatefulWidget {
  const NewPetSitterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewPetSitterSheet(),
    );
  }

  @override
  State<NewPetSitterSheet> createState() => _NewPetSitterSheetState();
}

class _NewPetSitterSheetState extends State<NewPetSitterSheet> {
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _summaryController = TextEditingController();

  // Kabul edilen türler (en az biri seçilmeli).
  final Set<SitterPet> _accepts = {SitterPet.kedi};
  String? _photoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    final district = _districtController.text.trim();
    final summary = _summaryController.text.trim();
    final price = int.tryParse(_priceController.text.trim());

    if (name.isEmpty || district.isEmpty || summary.isEmpty) {
      _error('Ad, semt ve tanıtım zorunlu');
      return;
    }
    if (price == null) {
      _error('Geçerli bir günlük ücret gir');
      return;
    }
    if (_accepts.isEmpty) {
      _error('En az bir hayvan türü seç');
      return;
    }

    final phone = _phoneController.text.trim();
    context.read<PetSitterStore>().addSitter(
      PetSitter(
        id: 'ps${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        district: district,
        rating: 0,
        reviewCount: 0,
        pricePerDay: price,
        summary: summary,
        accepts: _accepts.toList(),
        phone: phone.isEmpty ? null : phone,
        photoPath: _photoPath,
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name bakıcı ilanı yayınlandı 🐾')));
  }

  void _error(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            Text('Bakıcı ilanı', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Fotoğraf seçici (isteğe bağlı).
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.forest.withValues(alpha: 0.3),
                    ),
                    image: _photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(_photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoPath != null
                      ? null
                      : const Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.forest,
                          size: 26,
                        ),
                ),
              ),
            ),
            if (_photoPath != null)
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _photoPath = null),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Fotoğrafı kaldır'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.terracotta,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ad',
                hintText: 'Örn. Elif K.',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _districtController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Semt / şehir',
                hintText: 'Örn. Kadıköy, İstanbul',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Günlük ücret (₺)',
                      hintText: 'Örn. 200',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      hintText: '05xx…',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baktığı türler (çoklu seçim).
            Text(
              'Baktığı türler',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pet in SitterPet.values)
                  FilterChip(
                    avatar: Icon(
                      pet.icon,
                      size: 18,
                      color: _accepts.contains(pet)
                          ? AppColors.cream
                          : AppColors.forest,
                    ),
                    label: Text(pet.label),
                    selected: _accepts.contains(pet),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _accepts.add(pet);
                      } else {
                        _accepts.remove(pet);
                      }
                    }),
                    selectedColor: AppColors.forest,
                    labelStyle: TextStyle(
                      color: _accepts.contains(pet)
                          ? AppColors.cream
                          : AppColors.text,
                    ),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _summaryController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tanıtım',
                hintText: 'Deneyimin, uygunluğun, evcil dostlara yaklaşımın…',
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
                child: const Text('İlanı yayınla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
