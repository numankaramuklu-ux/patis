import 'health_record.dart';
import 'pet.dart';
import 'vaccination.dart';
import 'weight_entry.dart';

/// Tek bir evcil hayvanın tüm pasaport verisini bir arada tutan paket.
///
/// Künye ([pet]), profil fotoğrafı ve sağlık kayıtları (aşı/alerji/ilaç/kilo)
/// burada toplanır. [PassportStore] artık bunlardan bir liste tutar; böylece
/// kullanıcı birden çok dostunu ekleyip aralarında geçiş yapabilir.
class PetProfile {
  PetProfile({
    required this.id,
    required this.pet,
    this.photoPath,
    List<Vaccination>? vaccinations,
    List<HealthRecord>? allergies,
    List<HealthRecord>? medications,
    List<WeightEntry>? weights,
  })  : vaccinations = vaccinations ?? [],
        allergies = allergies ?? [],
        medications = medications ?? [],
        weights = weights ?? [];

  /// Listede bulmak/seçmek için benzersiz kimlik.
  final String id;

  /// Hayvanın künyesi (ad, cins, mikroçip…). Düzenlenince değişir.
  Pet pet;

  /// Profil fotoğrafının cihazdaki yolu (yoksa null).
  String? photoPath;

  final List<Vaccination> vaccinations;
  final List<HealthRecord> allergies;
  final List<HealthRecord> medications;
  final List<WeightEntry> weights;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'id': id,
        'pet': pet.toJson(),
        'photoPath': photoPath,
        'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
        'allergies': allergies.map((a) => a.toJson()).toList(),
        'medications': medications.map((m) => m.toJson()).toList(),
        'weights': weights.map((w) => w.toJson()).toList(),
      };

  /// Saklanan Map'ten [PetProfile] üretir.
  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
        id: json['id'] as String? ?? '',
        pet: Pet.fromJson(json['pet'] as Map<String, dynamic>),
        photoPath: json['photoPath'] as String?,
        vaccinations: (json['vaccinations'] as List? ?? const [])
            .map((e) => Vaccination.fromJson(e as Map<String, dynamic>))
            .toList(),
        allergies: (json['allergies'] as List? ?? const [])
            .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
        medications: (json['medications'] as List? ?? const [])
            .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
        weights: (json['weights'] as List? ?? const [])
            .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
