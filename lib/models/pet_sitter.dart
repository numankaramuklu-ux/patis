import 'package:flutter/material.dart';

/// Pet sitter'ın baktığı hayvan türü. Kartta küçük rozet olarak gösterilir.
///
/// Sahiplendirmedeki `AdoptionSpecies`'ten ayrı tuttuk: orası ilanın türünü,
/// burası sitter'ın "kabul ettiği" türleri (birden fazla olabilir) anlatıyor.
enum SitterPet {
  kedi(label: 'Kedi', icon: Icons.pets),
  kopek(label: 'Köpek', icon: Icons.pets);

  const SitterPet({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Pet sitter bulma ekranındaki tek bir bakıcı (yol haritası #4).
///
/// Örnek bakıcılar mock; kullanıcı kendi bakıcı ilanını da oluşturabilir.
/// Veriler [PetSitterStore]'da tutulur ve `shared_preferences` ile saklanır.
class PetSitter {
  const PetSitter({
    required this.id,
    required this.name,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.pricePerDay,
    required this.summary,
    required this.accepts,
    this.phone,
    this.photoPath,
    this.verified = false,
  });

  /// Bakıcıyı (örn. favorilerde) benzersiz tanımlayan kimlik.
  final String id;

  /// Bakıcının adı (örn. "Elif K.").
  final String name;

  /// Semt / bölge (örn. "Kadıköy, İstanbul").
  final String district;

  /// [district]'ten türetilen şehir (virgülden sonraki kısım, örn.
  /// "İstanbul"). Virgül yoksa tüm metin döner. Şehir filtresi bunu kullanır.
  String get city => district.contains(',')
      ? district.split(',').last.trim()
      : district.trim();

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

  /// İletişim telefonu (ara/mesaj için, isteğe bağlı).
  final String? phone;

  /// Profil fotoğrafının cihazdaki yolu (yoksa baş harf avatarı).
  final String? photoPath;

  /// Kimliği doğrulanmış bakıcı mı? `true` ise kartta "Onaylı" rozeti çıkar.
  final bool verified;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Kabul edilen
  /// türler enum adı listesi olarak yazılır.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'district': district,
    'rating': rating,
    'reviewCount': reviewCount,
    'pricePerDay': pricePerDay,
    'summary': summary,
    'accepts': accepts.map((p) => p.name).toList(),
    'phone': phone,
    'photoPath': photoPath,
    'verified': verified,
  };

  /// Saklanan Map'ten [PetSitter] üretir. Bilinmeyen tür adları atlanır.
  factory PetSitter.fromJson(Map<String, dynamic> json) => PetSitter(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    district: json['district'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? 0,
    summary: json['summary'] as String? ?? '',
    accepts: (json['accepts'] as List? ?? const [])
        .map((e) => SitterPet.values.where((p) => p.name == e))
        .expand((m) => m)
        .toList(),
    phone: json['phone'] as String?,
    photoPath: json['photoPath'] as String?,
    verified: json['verified'] as bool? ?? false,
  );
}
