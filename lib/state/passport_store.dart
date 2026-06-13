import 'package:flutter/foundation.dart';

import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/weight_entry.dart';

/// Dijital Pasaport verilerinin tutulduğu "depo" (store).
///
/// Aşılar, alerjiler, ilaçlar ve kilo ölçümleri burada toplanır. Diğer
/// store'larla aynı mantık (ChangeNotifier): veri değişince `notifyListeners()`
/// çağırır, Pasaport ekranı kendini yeniden çizer. Şimdilik bellekte; ileride
/// Firebase'e bağlanacak.
class PassportStore extends ChangeNotifier {
  final List<Vaccination> _vaccinations = [
    const Vaccination(
      name: 'Kuduz',
      dateLabel: '10 Mart 2026',
      nextDueLabel: '10 Mart 2027',
    ),
    const Vaccination(
      name: 'Karma (4\'lü)',
      dateLabel: '2 Şubat 2026',
      nextDueLabel: '2 Şubat 2027',
    ),
    const Vaccination(name: 'İç-Dış Parazit', dateLabel: '15 Mayıs 2026'),
  ];

  final List<HealthRecord> _allergies = [
    const HealthRecord(
      title: 'Tavuk proteini',
      note: 'Ciltte kaşıntı ve kızarıklık yapıyor',
    ),
    const HealthRecord(title: 'Polen', note: 'İlkbaharda hapşırık'),
  ];

  final List<HealthRecord> _medications = [
    const HealthRecord(
      title: 'Frontline',
      note: 'Ayda 1 damla • boyun arkası',
    ),
    const HealthRecord(
      title: 'Omega-3 takviyesi',
      note: 'Günde 1 kapsül • mama ile',
    ),
  ];

  // Hayvanın profil fotoğrafının cihazdaki dosya yolu. null ise varsayılan
  // ikon gösterilir. Şimdilik bellekte; ileride Firebase Storage'a yüklenecek.
  String? _photoPath;

  // En eskiden en yeniye sıralı tartımlar (grafik soldan sağa zaman akışı).
  final List<WeightEntry> _weights = [
    const WeightEntry(kg: 3.8, dateLabel: 'Oca'),
    const WeightEntry(kg: 4.0, dateLabel: 'Şub'),
    const WeightEntry(kg: 4.1, dateLabel: 'Mar'),
    const WeightEntry(kg: 4.0, dateLabel: 'Nis'),
    const WeightEntry(kg: 4.3, dateLabel: 'May'),
    const WeightEntry(kg: 4.2, dateLabel: 'Haz'),
  ];

  // Ekranların okuyacağı, dışarıdan değiştirilemez listeler.
  List<Vaccination> get vaccinations => List.unmodifiable(_vaccinations);
  List<HealthRecord> get allergies => List.unmodifiable(_allergies);
  List<HealthRecord> get medications => List.unmodifiable(_medications);
  List<WeightEntry> get weights => List.unmodifiable(_weights);

  /// Hayvanın seçili profil fotoğrafının yolu (yoksa null).
  String? get photoPath => _photoPath;

  /// Yeni aşıyı listenin başına ekler (en güncel en üstte).
  void addVaccination(Vaccination vaccination) {
    _vaccinations.insert(0, vaccination);
    notifyListeners();
  }

  /// Yeni alerji kaydı ekler.
  void addAllergy(HealthRecord allergy) {
    _allergies.add(allergy);
    notifyListeners();
  }

  /// Yeni ilaç kaydı ekler.
  void addMedication(HealthRecord medication) {
    _medications.add(medication);
    notifyListeners();
  }

  /// Yeni tartımı sonuna ekler (grafikte en sağda, en güncel nokta olarak).
  void addWeight(WeightEntry entry) {
    _weights.add(entry);
    notifyListeners();
  }

  /// Hayvanın profil fotoğrafını günceller (seçilen dosyanın yolu).
  void setPhoto(String path) {
    _photoPath = path;
    notifyListeners();
  }
}
