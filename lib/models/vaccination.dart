/// Bir aşı kaydını temsil eden veri sınıfı.
///
/// Dijital Pasaport'taki "Aşılar" bölümünde her satır bir [Vaccination].
/// Şimdilik sadece ekranda gösterdiğimiz alanlar var; ileride Firebase'e
/// geçince tarih alanlarını gerçek `DateTime` tipine çevirip `fromJson` /
/// `toJson` ekleyebiliriz.
class Vaccination {
  const Vaccination({
    required this.name,
    required this.dateLabel,
    this.nextDueLabel,
  });

  /// Aşının adı (örn. "Kuduz", "Karma").
  final String name;

  /// Yapıldığı tarih etiketi (örn. "10 Mart 2026").
  final String dateLabel;

  /// Bir sonraki doz ne zaman? (örn. "10 Mart 2027").
  ///
  /// Tekrar gerektirmeyen aşılar için `null` olabilir; o yüzden zorunlu değil.
  final String? nextDueLabel;
}
