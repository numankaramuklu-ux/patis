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

  /// Verilen alanları değiştirip yeni bir [Pet] üretir (düzenleme formu için).
  /// Boş string geçirilen isteğe bağlı alanlar null'a çevrilir ki künyede
  /// boş satır görünmesin.
  Pet copyWith({
    String? name,
    String? breed,
    String? ageLabel,
    String? species,
    String? gender,
    String? birthDateLabel,
    String? colorLabel,
    String? microchip,
    String? registrationNo,
  }) {
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return Pet(
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageLabel: ageLabel ?? this.ageLabel,
      species: species != null ? clean(species) : this.species,
      gender: gender != null ? clean(gender) : this.gender,
      birthDateLabel:
          birthDateLabel != null ? clean(birthDateLabel) : this.birthDateLabel,
      colorLabel: colorLabel != null ? clean(colorLabel) : this.colorLabel,
      microchip: microchip != null ? clean(microchip) : this.microchip,
      registrationNo:
          registrationNo != null ? clean(registrationNo) : this.registrationNo,
    );
  }

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'name': name,
        'breed': breed,
        'ageLabel': ageLabel,
        'species': species,
        'gender': gender,
        'birthDateLabel': birthDateLabel,
        'colorLabel': colorLabel,
        'microchip': microchip,
        'registrationNo': registrationNo,
      };

  /// Saklanan Map'ten [Pet] üretir.
  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        name: json['name'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        ageLabel: json['ageLabel'] as String? ?? '',
        species: json['species'] as String?,
        gender: json['gender'] as String?,
        birthDateLabel: json['birthDateLabel'] as String?,
        colorLabel: json['colorLabel'] as String?,
        microchip: json['microchip'] as String?,
        registrationNo: json['registrationNo'] as String?,
      );
}
