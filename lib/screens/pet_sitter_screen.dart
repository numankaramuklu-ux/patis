import 'package:flutter/material.dart';

import '../models/pet_sitter.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_sitter_card.dart';

/// Pet sitter bulma ekranı (yol haritası #4).
///
/// Ana Sayfa'daki "Pet Sitter" kutusundan açılır. Şimdilik tüm bakıcılar
/// mock (sahte) — ileride Firebase'den gerçek bakıcılarla değiştireceğiz.
class PetSitterScreen extends StatelessWidget {
  const PetSitterScreen({super.key});

  // ---- Mock (sahte) bakıcılar ----
  static const _sitters = <PetSitter>[
    PetSitter(
      name: 'Elif K.',
      district: 'Kadıköy, İstanbul',
      rating: 4.9,
      reviewCount: 47,
      pricePerDay: 250,
      summary: 'Veteriner teknikeri. Evimde küçük bahçe var, ilgi garanti.',
      accepts: [SitterPet.kedi, SitterPet.kopek],
      verified: true,
    ),
    PetSitter(
      name: 'Burak T.',
      district: 'Çankaya, Ankara',
      rating: 4.7,
      reviewCount: 23,
      pricePerDay: 200,
      summary: 'Köpek eğitmeni. Günde 2 kez uzun yürüyüş yaptırırım.',
      accepts: [SitterPet.kopek],
      verified: true,
    ),
    PetSitter(
      name: 'Selin A.',
      district: 'Konak, İzmir',
      rating: 4.6,
      reviewCount: 15,
      pricePerDay: 180,
      summary: 'Kedilerle aram çok iyi. Yaşlı ve çekingen kedilerde tecrübeliyim.',
      accepts: [SitterPet.kedi, SitterPet.kus],
    ),
    PetSitter(
      name: 'Deniz Y.',
      district: 'Nilüfer, Bursa',
      rating: 4.8,
      reviewCount: 31,
      pricePerDay: 160,
      summary: 'Hafta sonu ve tatil günleri için uygunum. Bol fotoğraf paylaşırım.',
      accepts: [SitterPet.kedi, SitterPet.kopek],
      verified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Sitter')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Güvenilir bakıcılar',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Sen yokken dostun emin ellerde',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final sitter in _sitters) ...[
              PetSitterCard(sitter: sitter),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
