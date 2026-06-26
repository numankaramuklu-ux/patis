/// Köpek gezdirme (pet walker) bulma ekranındaki tek bir gezdirici.
///
/// [PetSitter] ile aynı mantıkta ama hizmet birimi "yürüyüş" (günlük değil).
/// Örnek gezdiriciler mock; veriler [PetWalkerStore]'da `shared_preferences`
/// ile saklanır. Sahip, bir gezdiriciye dokununca detay ekranından gerçek bir
/// yürüyüş talebi ([DogWalk]) oluşturur.
class PetWalker {
  const PetWalker({
    required this.id,
    required this.name,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.pricePerWalk,
    required this.summary,
    this.phone,
    this.photoPath,
    this.verified = false,
  });

  /// Gezdiriciyi (örn. favorilerde) benzersiz tanımlayan kimlik.
  final String id;

  /// Gezdiricinin adı (örn. "Burak T.").
  final String name;

  /// Semt / bölge (örn. "Kadıköy, İstanbul").
  final String district;

  /// [district]'ten türetilen şehir (virgülden sonraki kısım). Şehir filtresi
  /// bunu kullanır.
  String get city => district.contains(',')
      ? district.split(',').last.trim()
      : district.trim();

  /// Ortalama puan (0–5 arası, örn. 4.8).
  final double rating;

  /// Değerlendirme (yorum) sayısı.
  final int reviewCount;

  /// Tek yürüyüş ücreti (TL).
  final int pricePerWalk;

  /// Kısa tanıtım yazısı.
  final String summary;

  /// İletişim telefonu (ara/mesaj için, isteğe bağlı).
  final String? phone;

  /// Profil fotoğrafının cihazdaki yolu (yoksa baş harf avatarı).
  final String? photoPath;

  /// Kimliği doğrulanmış gezdirici mi? `true` ise kartta "Onaylı" rozeti çıkar.
  final bool verified;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'district': district,
        'rating': rating,
        'reviewCount': reviewCount,
        'pricePerWalk': pricePerWalk,
        'summary': summary,
        'phone': phone,
        'photoPath': photoPath,
        'verified': verified,
      };

  /// Saklanan Map'ten [PetWalker] üretir.
  factory PetWalker.fromJson(Map<String, dynamic> json) => PetWalker(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        district: json['district'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        pricePerWalk: (json['pricePerWalk'] as num?)?.toInt() ?? 0,
        summary: json['summary'] as String? ?? '',
        phone: json['phone'] as String?,
        photoPath: json['photoPath'] as String?,
        verified: json['verified'] as bool? ?? false,
      );
}
