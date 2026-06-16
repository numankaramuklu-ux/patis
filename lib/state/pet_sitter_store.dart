import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_sitter.dart';

/// Pet sitter ekranındaki veriyi tutan "depo".
///
/// Bakıcıları (örnek + kullanıcının eklediği) ve favori kimliklerini saklar.
/// Her ikisi de `shared_preferences` ile kalıcıdır. Bakıcılar şimdilik yerel;
/// ileride Firebase'e taşınabilir.
class PetSitterStore extends ChangeNotifier {
  PetSitterStore() {
    _load();
  }

  static const _kSitters = 'pet_sitters';
  static const _kFavorites = 'pet_sitter_favorites';

  // İlk açılışta örnek bakıcılarla başlar; kullanıcı eklerse başa eklenir.
  // List.of ile büyütülebilir kopya — addSitter ekleme yapabilsin.
  final List<PetSitter> _sitters = List.of(_seedSitters());

  final Set<String> _favoriteIds = {};

  static List<PetSitter> _seedSitters() => const [
    PetSitter(
      id: 'ps1',
      name: 'Elif K.',
      district: 'Kadıköy, İstanbul',
      rating: 4.9,
      reviewCount: 47,
      pricePerDay: 250,
      summary: 'Veteriner teknikeri. Evimde küçük bahçe var, ilgi garanti.',
      accepts: [SitterPet.kedi, SitterPet.kopek],
      phone: '0532 111 22 33',
      verified: true,
    ),
    PetSitter(
      id: 'ps2',
      name: 'Burak T.',
      district: 'Çankaya, Ankara',
      rating: 4.7,
      reviewCount: 23,
      pricePerDay: 200,
      summary: 'Köpek eğitmeni. Günde 2 kez uzun yürüyüş yaptırırım.',
      accepts: [SitterPet.kopek],
      phone: '0533 444 55 66',
      verified: true,
    ),
    PetSitter(
      id: 'ps3',
      name: 'Selin A.',
      district: 'Konak, İzmir',
      rating: 4.6,
      reviewCount: 15,
      pricePerDay: 180,
      summary:
          'Kedilerle aram çok iyi. Yaşlı ve çekingen kedilerde tecrübeliyim.',
      accepts: [SitterPet.kedi, SitterPet.kus],
      phone: '0535 777 88 99',
    ),
    PetSitter(
      id: 'ps4',
      name: 'Deniz Y.',
      district: 'Nilüfer, Bursa',
      rating: 4.8,
      reviewCount: 31,
      pricePerDay: 160,
      summary:
          'Hafta sonu ve tatil günleri için uygunum. Bol fotoğraf paylaşırım.',
      accepts: [SitterPet.kedi, SitterPet.kopek],
      phone: '0536 222 33 44',
      verified: true,
    ),
  ];

  /// Tüm bakıcılar (kullanıcının eklediği en üstte; değiştirilemez).
  List<PetSitter> get sitters => List.unmodifiable(_sitters);

  /// Yeni bir bakıcı ilanı ekler (listenin başına).
  void addSitter(PetSitter sitter) {
    _sitters.insert(0, sitter);
    notifyListeners();
    _persistSitters();
  }

  // ---- Favoriler ----

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get favoriteCount => _favoriteIds.length;
  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
    notifyListeners();
    _persistFavorites();
  }

  // ---- Kalıcılık ----

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final sittersRaw = prefs.getString(_kSitters);
    if (sittersRaw != null) {
      final decoded = (jsonDecode(sittersRaw) as List)
          .map((e) => PetSitter.fromJson(e as Map<String, dynamic>))
          .toList();
      _sitters
        ..clear()
        ..addAll(decoded);
    }

    final favRaw = prefs.getString(_kFavorites);
    if (favRaw != null) {
      _favoriteIds
        ..clear()
        ..addAll((jsonDecode(favRaw) as List).cast<String>());
    }

    if (sittersRaw != null || favRaw != null) notifyListeners();
  }

  Future<void> _persistSitters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSitters,
      jsonEncode(_sitters.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(_favoriteIds.toList()));
  }
}
