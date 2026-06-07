import 'package:flutter/material.dart';

/// Pet sitter'ın baktığı hayvan türü. Kartta küçük rozet olarak gösterilir.
///
/// Sahiplendirmedeki `AdoptionSpecies`'ten ayrı tuttuk: orası ilanın türünü,
/// burası sitter'ın "kabul ettiği" türleri (birden fazla olabilir) anlatıyor.
enum SitterPet {
  kedi(label: 'Kedi', icon: Icons.pets),
  kopek(label: 'Köpek', icon: Icons.pets),
  kus(label: 'Kuş', icon: Icons.flutter_dash);

  const SitterPet({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Pet sitter bulma ekranındaki tek bir bakıcı (yol haritası #4).
///
/// Şimdilik veriler mock (sahte) — ileride Firebase'den gerçek bakıcılarla
/// değiştireceğiz.
class PetSitter {
  const PetSitter({
    required this.name,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.pricePerDay,
    required this.summary,
    required this.accepts,
    this.verified = false,
  });

  /// Bakıcının adı (örn. "Elif K.").
  final String name;

  /// Semt / bölge (örn. "Kadıköy, İstanbul").
  final String district;

  /// Ortalama puan (örn. 4.8). 0–5 arası.
  final double rating;

  /// Değerlendirme (yorum) sayısı.
  final int reviewCount;

  /// Günlük ücret (TL).
  final int pricePerDay;

  /// Kısa tanıtım yazısı.
  final String summary;

  /// Kabul ettiği hayvan türleri. Kartta küçük rozetler olarak görünür.
  final List<SitterPet> accepts;

  /// Kimliği doğrulanmış bakıcı mı? `true` ise kartta "Onaylı" rozeti çıkar.
  final bool verified;
}
