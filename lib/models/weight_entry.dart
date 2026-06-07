/// Tek bir kilo ölçümünü (tartımı) temsil eden veri sınıfı.
///
/// Kilo takibi grafiğinde her nokta bir [WeightEntry]'dir. Liste, en eskiden
/// en yeniye doğru sıralı tutulur; böylece grafikte soldan sağa zaman akar.
class WeightEntry {
  const WeightEntry({
    required this.kg,
    required this.dateLabel,
  });

  /// Ölçülen kilo (kilogram). Ondalıklı olabildiği için `double`.
  final double kg;

  /// Grafiğin altında görünecek kısa tarih etiketi (örn. "Oca", "Şub").
  final String dateLabel;
}
