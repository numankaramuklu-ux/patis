import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// İlandaki hayvanın türü. Kartın vurgu rengini ve ikonunu belirler.
///
/// `appointment.dart`'taki gibi "gelişmiş enum" (enhanced enum): sınırlı bir
/// seçenek listesi ama her seçeneğe etiket/ikon/renk bağlıyoruz. Böylece
/// kartta tür başına `if` yazmadan `listing.species.color` diyebiliyoruz.
enum AdoptionSpecies {
  kedi(label: 'Kedi', icon: Icons.pets, color: AppColors.terracotta),
  kopek(label: 'Köpek', icon: Icons.pets, color: AppColors.forest);

  const AdoptionSpecies({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// İlandaki hayvanın cinsiyeti. Kartta küçük bir rozet olarak gösterilir.
enum PetGender {
  disi(label: 'Dişi', icon: Icons.female),
  erkek(label: 'Erkek', icon: Icons.male);

  const PetGender({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Sahiplendirme ekranında gösterilen tek bir ilan (yol haritası #3).
///
/// Şimdilik veriler mock (sahte) — ileride Firebase'den gerçek ilanlarla
/// değiştireceğiz. Bu sınıf yalnızca bir ilanın taşıdığı bilgiyi tutar.
class AdoptionListing {
  const AdoptionListing({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageLabel,
    required this.city,
    required this.summary,
    required this.species,
    required this.gender,
  });

  /// İlanı (örn. favorilerde) benzersiz tanımlayan kimlik.
  final String id;

  /// Hayvanın adı (örn. "Zeytin").
  final String name;

  /// Cins bilgisi (örn. "Tekir", "Golden Retriever").
  final String breed;

  /// Yaş etiketi (örn. "3 aylık", "2 yaşında").
  final String ageLabel;

  /// İlanın bulunduğu şehir (örn. "İstanbul").
  final String city;

  /// Kısa tanıtım yazısı (örn. "Oyuncu ve insana çok düşkün.").
  final String summary;

  /// Tür — kartın ikon ve vurgu rengini belirler.
  final AdoptionSpecies species;

  /// Cinsiyet — kartta küçük rozet olarak gösterilir.
  final PetGender gender;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Tür ve cinsiyet
  /// enum adı olarak yazılır.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'breed': breed,
    'ageLabel': ageLabel,
    'city': city,
    'summary': summary,
    'species': species.name,
    'gender': gender.name,
  };

  /// Saklanan Map'ten [AdoptionListing] üretir. Bilinmeyen tür/cinsiyet
  /// makul bir varsayılana düşer.
  factory AdoptionListing.fromJson(Map<String, dynamic> json) =>
      AdoptionListing(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        ageLabel: json['ageLabel'] as String? ?? '',
        city: json['city'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        species: AdoptionSpecies.values.firstWhere(
          (s) => s.name == json['species'],
          orElse: () => AdoptionSpecies.kedi,
        ),
        gender: PetGender.values.firstWhere(
          (g) => g.name == json['gender'],
          orElse: () => PetGender.disi,
        ),
      );
}
