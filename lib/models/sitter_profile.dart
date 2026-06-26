/// Pet sitter'ın fiyat listesindeki tek bir kalem (örn. "Gecelik konaklama").
///
/// Model immutable; düzenlerken [copyWith] ile yeni kopya üretilir.
class SitterPriceItem {
  const SitterPriceItem({
    required this.id,
    required this.label,
    required this.price,
    this.unit = 'gece',
    this.note,
  });

  /// Listede bulup güncellemek/silmek için benzersiz kimlik.
  final String id;

  /// Hizmet adı (örn. "Gecelik konaklama", "Gündüz bakımı").
  final String label;

  /// Ücret (TL).
  final int price;

  /// Birim (örn. "gece", "gün", "saat", "yürüyüş"). Kartta "₺/birim" gösterilir.
  final String unit;

  /// İsteğe bağlı kısa açıklama.
  final String? note;

  SitterPriceItem copyWith({
    String? label,
    int? price,
    String? unit,
    String? note,
  }) {
    return SitterPriceItem(
      id: id,
      label: label ?? this.label,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'price': price,
        'unit': unit,
        'note': note,
      };

  factory SitterPriceItem.fromJson(Map<String, dynamic> json) => SitterPriceItem(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        unit: json['unit'] as String? ?? 'gece',
        note: json['note'] as String?,
      );
}

/// Pet sitter'ın işletme/profil bilgisi: adres, mekan fotoğrafları ve fiyat
/// listesi. Tek bir kullanıcının kendi profili olduğu için store içinde tekil
/// tutulur ve `shared_preferences` ile saklanır.
class SitterProfile {
  const SitterProfile({
    this.district = '',
    this.address = '',
    this.photoPaths = const [],
    this.priceItems = const [],
  });

  /// Semt / bölge (örn. "Kadıköy, İstanbul"). Harita aramasında kullanılır.
  final String district;

  /// Açık adres (sokak, bina, kapı no vb.).
  final String address;

  /// Mekan fotoğraflarının cihazdaki yolları.
  final List<String> photoPaths;

  /// Fiyat listesi kalemleri.
  final List<SitterPriceItem> priceItems;

  /// Harita aramasında kullanılacak metin (adres + semt, boş olanlar atlanır).
  String get mapQuery =>
      [address, district].where((s) => s.trim().isNotEmpty).join(', ');

  SitterProfile copyWith({
    String? district,
    String? address,
    List<String>? photoPaths,
    List<SitterPriceItem>? priceItems,
  }) {
    return SitterProfile(
      district: district ?? this.district,
      address: address ?? this.address,
      photoPaths: photoPaths ?? this.photoPaths,
      priceItems: priceItems ?? this.priceItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'district': district,
        'address': address,
        'photoPaths': photoPaths,
        'priceItems': priceItems.map((p) => p.toJson()).toList(),
      };

  factory SitterProfile.fromJson(Map<String, dynamic> json) => SitterProfile(
        district: json['district'] as String? ?? '',
        address: json['address'] as String? ?? '',
        photoPaths: (json['photoPaths'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
        priceItems: (json['priceItems'] as List? ?? const [])
            .map((e) => SitterPriceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
