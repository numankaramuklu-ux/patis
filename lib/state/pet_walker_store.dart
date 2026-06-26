import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_walker.dart';

/// Köpek gezdirme bulma ekranındaki veriyi tutan "depo".
///
/// [PetSitterStore] ile aynı mantık: örnek + kullanıcının eklediği gezdiriciler
/// ve favori kimlikleri `shared_preferences` ile kalıcıdır.
class PetWalkerStore extends ChangeNotifier {
  PetWalkerStore() {
    _load();
  }

  static const _kWalkers = 'pet_walkers';
  static const _kFavorites = 'pet_walker_favorites';

  final List<PetWalker> _walkers = List.of(_seedWalkers());
  final Set<String> _favoriteIds = {};

  static List<PetWalker> _seedWalkers() => const [
        PetWalker(
          id: 'pw1',
          name: 'Burak T.',
          district: 'Çankaya, Ankara',
          rating: 4.8,
          reviewCount: 36,
          pricePerWalk: 120,
          summary:
              'Köpek eğitmeni. Enerjik ırklarda tecrübeliyim, uzun parkur yaptırırım.',
          phone: '0533 444 55 66',
          verified: true,
        ),
        PetWalker(
          id: 'pw2',
          name: 'Elif K.',
          district: 'Kadıköy, İstanbul',
          rating: 4.9,
          reviewCount: 52,
          pricePerWalk: 150,
          summary:
              'Her yürüyüşte konum ve fotoğraf paylaşırım. Yaşlı köpeklerde nazik tempo.',
          phone: '0532 111 22 33',
          verified: true,
        ),
        PetWalker(
          id: 'pw3',
          name: 'Mert S.',
          district: 'Konak, İzmir',
          rating: 4.6,
          reviewCount: 18,
          pricePerWalk: 100,
          summary: 'Sabah erken ve akşam geç saatlerde uygunum. Çekingen köpeklerde sabırlı.',
          phone: '0535 777 88 99',
        ),
        PetWalker(
          id: 'pw4',
          name: 'Deniz A.',
          district: 'Nilüfer, Bursa',
          rating: 4.7,
          reviewCount: 27,
          pricePerWalk: 110,
          summary: 'Hafta içi her gün düzenli yürüyüş. Grup yürüyüşü de yapıyorum.',
          phone: '0536 222 33 44',
          verified: true,
        ),
      ];

  /// Tüm gezdiriciler (kullanıcının eklediği en üstte; değiştirilemez).
  List<PetWalker> get walkers => List.unmodifiable(_walkers);

  /// Yeni bir gezdirici ilanı ekler (listenin başına).
  void addWalker(PetWalker walker) {
    _walkers.insert(0, walker);
    notifyListeners();
    _persistWalkers();
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

    final walkersRaw = prefs.getString(_kWalkers);
    if (walkersRaw != null) {
      final decoded = (jsonDecode(walkersRaw) as List)
          .map((e) => PetWalker.fromJson(e as Map<String, dynamic>))
          .toList();
      _walkers
        ..clear()
        ..addAll(decoded);
    }

    final favRaw = prefs.getString(_kFavorites);
    if (favRaw != null) {
      _favoriteIds
        ..clear()
        ..addAll((jsonDecode(favRaw) as List).cast<String>());
    }

    if (walkersRaw != null || favRaw != null) notifyListeners();
  }

  Future<void> _persistWalkers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kWalkers,
      jsonEncode(_walkers.map((w) => w.toJson()).toList()),
    );
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(_favoriteIds.toList()));
  }
}
