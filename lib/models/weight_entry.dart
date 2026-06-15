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

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'kg': kg,
        'dateLabel': dateLabel,
      };

  /// Saklanan Map'ten [WeightEntry] üretir.
  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        kg: (json['kg'] as num?)?.toDouble() ?? 0,
        dateLabel: json['dateLabel'] as String? ?? '',
      );
}
