/// Bir hastanın aşı kartındaki tek bir kayıt.
class VetVaccination {
  const VetVaccination({
    required this.name,
    required this.dateLabel,
    this.nextDueLabel,
  });

  final String name;
  final String dateLabel;

  /// Bir sonraki doz tarihi (varsa). null ise tek seferlik / tekrar gerekmez.
  final String? nextDueLabel;
}

/// Geçmiş tek bir tedavi/işlem kaydı (hasta detayındaki geçmiş listesi).
class VetTreatment {
  const VetTreatment({
    required this.dateLabel,
    required this.title,
    this.note,
  });

  final String dateLabel;
  final String title;
  final String? note;
}

/// Veteriner kliniğinin zengin hasta kaydı.
///
/// Liste ve detay ekranı bunu kullanır: hayvan bilgisi, sahibin iletişimi,
/// aşı kartı, tedavi geçmişi, alerjiler ve klinik notu. Şimdilik mock.
class VetPatient {
  const VetPatient({
    required this.id,
    required this.petName,
    required this.species,
    required this.breed,
    required this.ageLabel,
    required this.weightKg,
    required this.ownerName,
    required this.phone,
    required this.lastVisitLabel,
    required this.totalVisits,
    required this.vaccinations,
    required this.treatments,
    this.nextVaccineLabel,
    this.allergies = const [],
    this.note,
    this.tag,
  });

  final String id;
  final String petName;
  final String species;
  final String breed;
  final String ageLabel;

  /// Güncel kilo (kg).
  final double weightKg;

  final String ownerName;
  final String phone;
  final String lastVisitLabel;
  final int totalVisits;

  /// Yaklaşan aşı tarihi (özet/istatistik için). Yoksa null.
  final String? nextVaccineLabel;

  /// Bilinen alerji/kronik durumlar (chip olarak gösterilir).
  final List<String> allergies;

  /// Aşı kartı (en yeni en üstte).
  final List<VetVaccination> vaccinations;

  /// Tedavi/işlem geçmişi (en yeni en üstte).
  final List<VetTreatment> treatments;

  /// Klinik notu (örn. "İğneden çok korkuyor").
  final String? note;

  /// Durum etiketi (örn. "Kronik", "Düzenli"). Yoksa rozet gösterilmez.
  final String? tag;
}
