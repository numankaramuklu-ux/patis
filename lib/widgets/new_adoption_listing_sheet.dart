import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/adoption_listing.dart';
import '../state/adoption_store.dart';
import '../theme/app_colors.dart';

/// Yeni sahiplendirme ilanı oluşturma formu (alttan açılan panel).
///
/// Kullanıcı yuva arayan bir dost için ad, cins, yaş, şehir, tür/cinsiyet ve
/// kısa bir tanıtım girer. Kaydedilince ilan [AdoptionStore]'a eklenir ve
/// listenin başında görünür.
class NewAdoptionListingSheet extends StatefulWidget {
  const NewAdoptionListingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewAdoptionListingSheet(),
    );
  }

  @override
  State<NewAdoptionListingSheet> createState() =>
      _NewAdoptionListingSheetState();
}

class _NewAdoptionListingSheetState extends State<NewAdoptionListingSheet> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _summaryController = TextEditingController();

  AdoptionSpecies _species = AdoptionSpecies.kedi;
  PetGender _gender = PetGender.disi;

  // Seçilen fotoğrafın cihazdaki yolu (yoksa tür ikonu gösterilir).
  String? _photoPath;

  /// Galeriden bir fotoğraf seçtirir ve önizleme için saklar.
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

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final summary = _summaryController.text.trim();

    if (name.isEmpty || city.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad, şehir ve tanıtım zorunlu')),
      );
      return;
    }

    context.read<AdoptionStore>().addListing(
      AdoptionListing(
        id: 'ad${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        breed: _breedController.text.trim().isEmpty
            ? _species.label
            : _breedController.text.trim(),
        ageLabel: _ageController.text.trim().isEmpty
            ? 'Belirtilmemiş'
            : _ageController.text.trim(),
        city: city,
        summary: summary,
        species: _species,
        gender: _gender,
        photoPath: _photoPath,
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name için ilan yayınlandı 🐾')));
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
            Text('Sahiplendirme ilanı', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Fotoğraf seçici (isteğe bağlı).
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
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
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.forest,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fotoğraf ekle',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.forest,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            // Fotoğraf seçildiyse değiştir/kaldır seçenekleri.
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

            // Tür seçimi.
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
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _species = s.first),
            ),
            const SizedBox(height: 12),

            // Cinsiyet seçimi.
            SegmentedButton<PetGender>(
              segments: const [
                ButtonSegment(
                  value: PetGender.disi,
                  label: Text('Dişi'),
                  icon: Icon(Icons.female),
                ),
                ButtonSegment(
                  value: PetGender.erkek,
                  label: Text('Erkek'),
                  icon: Icon(Icons.male),
                ),
              ],
              selected: {_gender},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ad',
                hintText: 'Örn. Zeytin',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _breedController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cins',
                      hintText: 'Örn. Tekir',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Yaş',
                      hintText: 'Örn. 3 aylık',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Şehir',
                hintText: 'Örn. İstanbul',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _summaryController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tanıtım',
                hintText: 'Karakteri, sağlık durumu, neden yuva aradığı…',
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
