import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_record.dart';
import '../models/journal_entry.dart';
import '../models/pet.dart';
import '../models/pet_profile.dart';
import '../models/vaccination.dart';
import '../models/weight_entry.dart';

/// Dijital Pasaport verilerinin tutulduğu "depo" (store).
///
/// Artık birden çok evcil hayvanı destekler: her dost bir [PetProfile]'dır
/// (künye + fotoğraf + aşı/alerji/ilaç/kilo). Aralarından biri "seçili" olur;
/// `pet`, `vaccinations` gibi getter'lar seçili hayvanın verisini döndürür,
/// böylece ekranlar tek hayvan varmış gibi çalışmaya devam eder.
///
/// Tüm veri `shared_preferences` ile kalıcıdır; uygulama yeniden açıldığında
/// geri yüklenir (ileride Firebase'e taşınabilir).
class PassportStore extends ChangeNotifier {
  PassportStore() {
    _load();
  }

  // shared_preferences anahtarları (çoklu hayvan).
  static const _kPets = 'passport_pets';
  static const _kSelected = 'passport_selected';

  // Eski tek-hayvan anahtarları (yalnızca tek seferlik göç/migration için).
  static const _kLegacyPet = 'passport_pet';
  static const _kLegacyVaccinations = 'passport_vaccinations';
  static const _kLegacyAllergies = 'passport_allergies';
  static const _kLegacyMedications = 'passport_medications';
  static const _kLegacyWeights = 'passport_weights';
  static const _kLegacyPhoto = 'passport_photo';

  // Varsayılan (ilk) hayvan: künye + örnek sağlık kayıtlarıyla.
  final List<PetProfile> _pets = [_defaultProfile()];

  // Şu an seçili hayvanın kimliği.
  String _selectedId = 'p1';

  static PetProfile _defaultProfile() => PetProfile(
        id: 'p1',
        pet: const Pet(
          name: 'Pamuk',
          breed: 'British Shorthair',
          ageLabel: '2 yaşında',
          species: 'Kedi',
          gender: 'Dişi',
          birthDateLabel: '14 Mart 2024',
          colorLabel: 'Beyaz',
          microchip: 'TR 985 112 003 456 789',
          registrationNo: 'PT-2024-0142',
        ),
        vaccinations: [
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
        ],
        allergies: [
          const HealthRecord(
            title: 'Tavuk proteini',
            note: 'Ciltte kaşıntı ve kızarıklık yapıyor',
          ),
          const HealthRecord(title: 'Polen', note: 'İlkbaharda hapşırık'),
        ],
        medications: [
          const HealthRecord(
            title: 'Frontline',
            note: 'Ayda 1 damla • boyun arkası',
          ),
          const HealthRecord(
            title: 'Omega-3 takviyesi',
            note: 'Günde 1 kapsül • mama ile',
          ),
        ],
        weights: [
          const WeightEntry(kg: 3.8, dateLabel: 'Oca'),
          const WeightEntry(kg: 4.0, dateLabel: 'Şub'),
          const WeightEntry(kg: 4.1, dateLabel: 'Mar'),
          const WeightEntry(kg: 4.0, dateLabel: 'Nis'),
          const WeightEntry(kg: 4.3, dateLabel: 'May'),
          const WeightEntry(kg: 4.2, dateLabel: 'Haz'),
        ],
        journal: [
          const JournalEntry(
            id: 'j1',
            dateLabel: '14 Haziran',
            mood: PetMood.oyuncu,
            text: 'Bütün gün yeni kuş tüyü oyuncağıyla oynadı, çok enerjikti.',
          ),
          const JournalEntry(
            id: 'j2',
            dateLabel: '10 Haziran',
            mood: PetMood.keyifsiz,
            text: 'Mama iştahı azaldı, biraz halsizdi. Takip ediyoruz.',
          ),
          const JournalEntry(
            id: 'j3',
            dateLabel: '5 Haziran',
            mood: PetMood.mutlu,
            text: 'Pencere kenarında güneşlenmeyi çok sevdi, mırlayıp durdu.',
          ),
        ],
      );

  // ---- Seçili hayvan ve liste erişimi ----

  /// Tüm hayvanlar (seçici için; dışarıdan değiştirilemez).
  List<PetProfile> get pets => List.unmodifiable(_pets);

  /// Seçili hayvanın kimliği.
  String get selectedId => _selectedId;

  /// Şu an seçili hayvan profili. Kimlik bulunamazsa ilk hayvana düşer.
  PetProfile get current =>
      _pets.firstWhere((p) => p.id == _selectedId, orElse: () => _pets.first);

  // ---- Seçili hayvana yönlenen getter'lar (ekranlar bunları kullanır) ----

  Pet get pet => current.pet;
  String? get photoPath => current.photoPath;
  List<Vaccination> get vaccinations => List.unmodifiable(current.vaccinations);
  List<HealthRecord> get allergies => List.unmodifiable(current.allergies);
  List<HealthRecord> get medications => List.unmodifiable(current.medications);
  List<WeightEntry> get weights => List.unmodifiable(current.weights);
  List<JournalEntry> get journal => List.unmodifiable(current.journal);

  // ---- Hayvan yönetimi ----

  /// Aktif hayvanı değiştirir.
  void selectPet(String id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
    _persistSelected();
  }

  /// Yeni bir hayvan ekler ve onu aktif yapar. Sağlık kayıtları boş başlar.
  void addPet(Pet pet) {
    final id = 'pet_${DateTime.now().microsecondsSinceEpoch}';
    _pets.add(PetProfile(id: id, pet: pet));
    _selectedId = id;
    notifyListeners();
    _persistPets();
    _persistSelected();
  }

  /// Bir hayvanı siler. Son hayvan silinemez (en az bir dost kalmalı). Seçili
  /// hayvan silinirse listedeki ilk hayvana geçilir.
  void deletePet(String id) {
    if (_pets.length <= 1) return;
    _pets.removeWhere((p) => p.id == id);
    if (_selectedId == id) _selectedId = _pets.first.id;
    notifyListeners();
    _persistPets();
    _persistSelected();
  }

  /// Seçili hayvanın künyesini günceller.
  void updatePet(Pet pet) {
    current.pet = pet;
    notifyListeners();
    _persistPets();
  }

  /// Seçili hayvanın profil fotoğrafını günceller.
  void setPhoto(String path) {
    current.photoPath = path;
    notifyListeners();
    _persistPets();
  }

  // ---- Seçili hayvanın sağlık kayıtları ----

  /// Yeni aşıyı listenin başına ekler (en güncel en üstte).
  void addVaccination(Vaccination vaccination) {
    current.vaccinations.insert(0, vaccination);
    notifyListeners();
    _persistPets();
  }

  /// Yeni alerji kaydı ekler.
  void addAllergy(HealthRecord allergy) {
    current.allergies.add(allergy);
    notifyListeners();
    _persistPets();
  }

  /// Yeni ilaç kaydı ekler.
  void addMedication(HealthRecord medication) {
    current.medications.add(medication);
    notifyListeners();
    _persistPets();
  }

  /// Yeni tartımı sonuna ekler (grafikte en sağda, en güncel nokta olarak).
  void addWeight(WeightEntry entry) {
    current.weights.add(entry);
    notifyListeners();
    _persistPets();
  }

  /// Yeni günlük kaydını başa ekler (en yeni en üstte).
  void addJournalEntry(JournalEntry entry) {
    current.journal.insert(0, entry);
    notifyListeners();
    _persistPets();
  }

  /// Bir günlük kaydını siler.
  void deleteJournalEntry(String id) {
    current.journal.removeWhere((j) => j.id == id);
    notifyListeners();
    _persistPets();
  }

  // ---- Kalıcılık ----

  /// Kayıtlı hayvanları diskten yükler. Yeni format yoksa eski tek-hayvan
  /// verisinden bir profil oluşturur (göç); o da yoksa varsayılan kalır.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPets);
    if (raw != null) {
      final decoded = (jsonDecode(raw) as List)
          .map((e) => PetProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      if (decoded.isNotEmpty) {
        _pets
          ..clear()
          ..addAll(decoded);
        final saved = prefs.getString(_kSelected);
        _selectedId =
            _pets.any((p) => p.id == saved) ? saved! : _pets.first.id;
        notifyListeners();
      }
      return;
    }
    await _migrateLegacy(prefs);
  }

  /// Eski (tek hayvan) anahtarlarında veri varsa onu yeni formata taşır;
  /// böylece daha önce eklenen kayıtlar kaybolmaz.
  Future<void> _migrateLegacy(SharedPreferences prefs) async {
    final petRaw = prefs.getString(_kLegacyPet);
    final hasLegacy = petRaw != null ||
        prefs.getString(_kLegacyVaccinations) != null ||
        prefs.getString(_kLegacyWeights) != null ||
        prefs.getString(_kLegacyPhoto) != null;
    if (!hasLegacy) return;

    List<T> readList<T>(String key, T Function(Map<String, dynamic>) from) {
      final raw = prefs.getString(key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => from(e as Map<String, dynamic>))
          .toList();
    }

    final migrated = PetProfile(
      id: 'p1',
      pet: petRaw != null
          ? Pet.fromJson(jsonDecode(petRaw) as Map<String, dynamic>)
          : _defaultProfile().pet,
      photoPath: prefs.getString(_kLegacyPhoto),
      vaccinations:
          readList(_kLegacyVaccinations, (j) => Vaccination.fromJson(j)),
      allergies: readList(_kLegacyAllergies, (j) => HealthRecord.fromJson(j)),
      medications:
          readList(_kLegacyMedications, (j) => HealthRecord.fromJson(j)),
      weights: readList(_kLegacyWeights, (j) => WeightEntry.fromJson(j)),
    );
    _pets
      ..clear()
      ..add(migrated);
    _selectedId = migrated.id;
    notifyListeners();
    // Yeni formatta yaz; eski anahtarları temizle.
    await _persistPets();
    await _persistSelected();
    for (final k in [
      _kLegacyPet,
      _kLegacyVaccinations,
      _kLegacyAllergies,
      _kLegacyMedications,
      _kLegacyWeights,
      _kLegacyPhoto,
    ]) {
      await prefs.remove(k);
    }
  }

  Future<void> _persistPets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPets,
      jsonEncode(_pets.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> _persistSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelected, _selectedId);
  }
}
