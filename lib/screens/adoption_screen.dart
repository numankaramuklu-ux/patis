import 'package:flutter/material.dart';

import '../models/adoption_listing.dart';
import '../theme/app_colors.dart';
import '../widgets/adoption_card.dart';

/// Sahiplendirme ilanları ekranı (yol haritası #3).
///
/// Ana Sayfa'daki "Sahiplendirme" kutusundan açılır. Şimdilik tüm ilanlar
/// mock (sahte) — ileride Firebase'den gerçek ilanlarla değiştireceğiz.
class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  // ---- Mock (sahte) ilanlar ----
  static const _listings = <AdoptionListing>[
    AdoptionListing(
      name: 'Zeytin',
      breed: 'Tekir',
      ageLabel: '3 aylık',
      city: 'İstanbul',
      summary: 'Oyuncu, insana çok düşkün bir yavru. Aşıları yapıldı.',
      species: AdoptionSpecies.kedi,
      gender: PetGender.disi,
    ),
    AdoptionListing(
      name: 'Karamel',
      breed: 'Golden Retriever',
      ageLabel: '1 yaşında',
      city: 'Ankara',
      summary: 'Sakin ve eğitimli. Çocuklu ailelere çok uygun.',
      species: AdoptionSpecies.kopek,
      gender: PetGender.erkek,
    ),
    AdoptionListing(
      name: 'Pofuduk',
      breed: 'British Shorthair',
      ageLabel: '8 aylık',
      city: 'İzmir',
      summary: 'Uysal ve kucağa düşkün. Diğer kedilerle iyi anlaşır.',
      species: AdoptionSpecies.kedi,
      gender: PetGender.erkek,
    ),
    AdoptionListing(
      name: 'Maya',
      breed: 'Terrier kırması',
      ageLabel: '2 yaşında',
      city: 'Bursa',
      summary: 'Enerjik ve sadık. Bahçeli evler için ideal.',
      species: AdoptionSpecies.kopek,
      gender: PetGender.disi,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Bu ekran bir alt sekme değil, üstüne açılan ayrı bir sayfa olduğu için
      // geri dönülebilmesi adına AppBar koyuyoruz.
      appBar: AppBar(title: const Text('Sahiplendirme')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Yuva arayan dostlar',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Bir patiye sıcak bir yuva ol',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Her ilanı karta dönüştürüp aralarına boşluk koyuyoruz.
            for (final listing in _listings) ...[
              AdoptionCard(listing: listing),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
