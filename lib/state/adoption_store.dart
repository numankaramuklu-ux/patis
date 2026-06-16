import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adoption_listing.dart';

/// Sahiplendirme ekranındaki veriyi tutan "depo".
///
/// İlanları (örnek + kullanıcının açtıkları) ve favori kimliklerini saklar.
/// Her ikisi de `shared_preferences` ile kalıcıdır — uygulama yeniden
/// açıldığında geri yüklenir. İlanlar şimdilik yereldir; ileride Firebase'e
/// taşınabilir.
class AdoptionStore extends ChangeNotifier {
  AdoptionStore() {
    _load();
  }

  static const _kFavorites = 'adoption_favorites';
  static const _kListings = 'adoption_listings';

  final Set<String> _favoriteIds = {};

  // İlk açılışta örnek ilanlarla başlar; kullanıcı ilan açınca başa eklenir.
  // List.of ile büyütülebilir (growable) kopya — addListing ekleme yapabilsin.
  final List<AdoptionListing> _listings = List.of(_seedListings());

  static List<AdoptionListing> _seedListings() => const [
    AdoptionListing(
      id: 'ad1',
      name: 'Zeytin',
      breed: 'Tekir',
      ageLabel: '3 aylık',
      city: 'İstanbul',
      summary: 'Oyuncu, insana çok düşkün bir yavru. Aşıları yapıldı.',
      species: AdoptionSpecies.kedi,
      gender: PetGender.disi,
    ),
    AdoptionListing(
      id: 'ad2',
      name: 'Karamel',
      breed: 'Golden Retriever',
      ageLabel: '1 yaşında',
      city: 'Ankara',
      summary: 'Sakin ve eğitimli. Çocuklu ailelere çok uygun.',
      species: AdoptionSpecies.kopek,
      gender: PetGender.erkek,
    ),
    AdoptionListing(
      id: 'ad3',
      name: 'Pofuduk',
      breed: 'British Shorthair',
      ageLabel: '8 aylık',
      city: 'İzmir',
      summary: 'Uysal ve kucağa düşkün. Diğer kedilerle iyi anlaşır.',
      species: AdoptionSpecies.kedi,
      gender: PetGender.erkek,
    ),
    AdoptionListing(
      id: 'ad4',
      name: 'Maya',
      breed: 'Terrier kırması',
      ageLabel: '2 yaşında',
      city: 'Bursa',
      summary: 'Enerjik ve sadık. Bahçeli evler için ideal.',
      species: AdoptionSpecies.kopek,
      gender: PetGender.disi,
    ),
  ];

  /// Tüm ilanlar (kullanıcının açtıkları en üstte; dışarıdan değiştirilemez).
  List<AdoptionListing> get listings => List.unmodifiable(_listings);

  /// Yeni bir ilan ekler (listenin başına).
  void addListing(AdoptionListing listing) {
    _listings.insert(0, listing);
    notifyListeners();
    _persistListings();
  }

  /// Favori ilan kimlikleri (dışarıdan değiştirilemez).
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Favori sayısı (rozet/başlık için).
  int get favoriteCount => _favoriteIds.length;

  /// Bir ilan favoride mi?
  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Favoriye ekler/çıkarır.
  void toggleFavorite(String id) {
    if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
    notifyListeners();
    _persist();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final favRaw = prefs.getString(_kFavorites);
    if (favRaw != null) {
      _favoriteIds
        ..clear()
        ..addAll((jsonDecode(favRaw) as List).cast<String>());
    }

    final listRaw = prefs.getString(_kListings);
    if (listRaw != null) {
      final decoded = (jsonDecode(listRaw) as List)
          .map((e) => AdoptionListing.fromJson(e as Map<String, dynamic>))
          .toList();
      _listings
        ..clear()
        ..addAll(decoded);
    }

    if (favRaw != null || listRaw != null) notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(_favoriteIds.toList()));
  }

  Future<void> _persistListings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kListings,
      jsonEncode(_listings.map((l) => l.toJson()).toList()),
    );
  }
}
