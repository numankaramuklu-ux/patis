/// Bir müşterinin geçmiş tek bir salon ziyareti (detay ekranındaki geçmiş
/// listesinde gösterilir).
class SalonVisit {
  const SalonVisit({
    required this.dateLabel,
    required this.service,
    required this.price,
  });

  final String dateLabel;
  final String service;
  final int price;
}

/// Pet salonunun zengin müşteri kaydı.
///
/// Liste ekranındaki [SalonClientCard] ve detay ekranı bunu kullanır. Sahibin
/// iletişim bilgisi, ziyaret istatistikleri, tercih edilen hizmetler ve geçmiş
/// burada toplanır. Şimdilik mock; ileride Firebase'den gelecek.
class SalonClient {
  const SalonClient({
    required this.id,
    required this.petName,
    required this.breed,
    required this.species,
    required this.ownerName,
    required this.phone,
    required this.lastVisitLabel,
    required this.totalVisits,
    required this.totalSpent,
    required this.preferredServices,
    required this.history,
    this.note,
    this.tag,
  });

  final String id;
  final String petName;
  final String breed;

  /// Tür (örn. "Kedi", "Köpek").
  final String species;

  final String ownerName;
  final String phone;

  /// Son ziyaret tarihi etiketi (örn. "5 Haziran").
  final String lastVisitLabel;

  /// Toplam ziyaret sayısı.
  final int totalVisits;

  /// Bugüne kadarki toplam harcama (TL).
  final int totalSpent;

  /// Sık tercih ettiği hizmetler (chip olarak gösterilir).
  final List<String> preferredServices;

  /// Geçmiş ziyaretler (en yeniden en eskiye).
  final List<SalonVisit> history;

  /// Salon notu (örn. "Su sesinden ürküyor").
  final String? note;

  /// Durum etiketi (örn. "VIP", "Düzenli"). Yoksa rozet gösterilmez.
  final String? tag;
}
