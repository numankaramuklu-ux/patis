/// Basit bir sağlık kaydını temsil eden ortak veri sınıfı.
///
/// Hem "Alerjiler" hem "İlaçlar" bölümünde kullanılır; ikisi de aynı şekle
/// (bir başlık + bir açıklama notu) sahip olduğu için tek model yeterli.
/// Böylece her bölüm için ayrı sınıf yazmaktan kurtuluyoruz.
class HealthRecord {
  const HealthRecord({
    required this.title,
    required this.note,
  });

  /// Kaydın adı.
  /// - Alerji için: alerjenin adı (örn. "Tavuk proteini").
  /// - İlaç için: ilacın adı (örn. "Frontline").
  final String title;

  /// Kısa açıklama notu.
  /// - Alerji için: belirti/şiddet (örn. "Ciltte kaşıntı yapıyor").
  /// - İlaç için: doz ve zaman (örn. "Ayda 1 damla • boyun arkası").
  final String note;
}
