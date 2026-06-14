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
    this.species,
    this.gender,
    this.birthDateLabel,
    this.colorLabel,
    this.microchip,
    this.registrationNo,
  });

  /// Hayvanın adı (örn. "Pamuk").
  final String name;

  /// Cinsi (örn. "British Shorthair").
  final String breed;

  /// Yaş etiketi (örn. "2 yaşında").
  final String ageLabel;

  // ---- Künye (pasaport) alanları ----
  // Hepsi isteğe bağlı; yalnızca Dijital Pasaport ekranında doldurulur, ana
  // sayfa/pet kartı gibi yerlerde verilmez (o kullanımlar bozulmaz).

  /// Tür (örn. "Kedi", "Köpek").
  final String? species;

  /// Cinsiyet (örn. "Dişi", "Erkek").
  final String? gender;

  /// Doğum tarihi etiketi (örn. "14 Mart 2024").
  final String? birthDateLabel;

  /// Renk / desen (örn. "Beyaz").
  final String? colorLabel;

  /// Mikroçip numarası.
  final String? microchip;

  /// Pasaport / kayıt numarası.
  final String? registrationNo;
}
