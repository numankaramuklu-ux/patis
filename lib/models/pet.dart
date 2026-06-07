/// Bir evcil hayvanı temsil eden veri sınıfı.
///
/// Şimdilik sadece arayüzde gösterdiğimiz alanlar var. İleride Firebase'e
/// geçince bu sınıfa `fromJson` / `toJson` gibi metotlar ekleyip gerçek
/// veriyle dolduracağız.
class Pet {
  const Pet({
    required this.name,
    required this.breed,
    required this.ageLabel,
  });

  /// Hayvanın adı (örn. "Pamuk").
  final String name;

  /// Cinsi (örn. "British Shorthair").
  final String breed;

  /// Yaş etiketi (örn. "2 yaşında").
  final String ageLabel;
}
