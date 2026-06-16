/// Pet salonunun (kuaför) sunduğu tek bir hizmet kalemi.
///
/// "Hizmetlerim / Fiyat listesi" ekranında listelenir: ad, tahmini süre ve
/// ücret. İsteğe bağlı kısa bir açıklama taşıyabilir (örn. "uzun tüylü ırklar
/// için"). Model immutable; düzenlerken [copyWith] ile yeni kopya üretilir.
class SalonService {
  const SalonService({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.price,
    this.note,
  });

  /// Listede bulup güncellemek/silmek için benzersiz kimlik.
  final String id;

  /// Hizmet adı (örn. "Tıraş & Banyo").
  final String name;

  /// Tahmini süre (dakika).
  final int durationMin;

  /// Ücret (TL).
  final int price;

  /// İsteğe bağlı kısa açıklama. Yoksa kartta gösterilmez.
  final String? note;

  SalonService copyWith({
    String? name,
    int? durationMin,
    int? price,
    String? note,
  }) {
    return SalonService(
      id: id,
      name: name ?? this.name,
      durationMin: durationMin ?? this.durationMin,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationMin': durationMin,
        'price': price,
        'note': note,
      };

  /// Saklanan Map'ten [SalonService] üretir.
  factory SalonService.fromJson(Map<String, dynamic> json) => SalonService(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toInt() ?? 0,
        note: json['note'] as String?,
      );
}
