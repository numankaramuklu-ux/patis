/// İşletme (kuaför/veteriner) panelinde listelenen bir müşteri/hasta kaydı.
///
/// Hem kuaförün müşterisini hem veterinerin hastasını temsil eder; aradaki fark
/// yalnızca etiketlerde (örn. "Son bakım" / "Son ziyaret"). Şimdilik mock; ileride
/// Firebase'den gelecek.
class ClientRecord {
  const ClientRecord({
    required this.petName,
    required this.petBreed,
    required this.ownerName,
    required this.lastVisitLabel,
    this.tag,
  });

  /// Evcil hayvanın adı (örn. "Pamuk").
  final String petName;

  /// Cinsi (örn. "British Shorthair").
  final String petBreed;

  /// Sahibinin adı (örn. "Ayşe Y.").
  final String ownerName;

  /// Son ziyaret/bakım tarihi etiketi (örn. "5 Haziran").
  final String lastVisitLabel;

  /// İsteğe bağlı durum etiketi (örn. "Aşı zamanı", "Düzenli"). Yoksa rozet
  /// gösterilmez.
  final String? tag;
}
