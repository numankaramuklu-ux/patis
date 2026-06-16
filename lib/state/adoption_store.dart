import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sahiplendirme ekranındaki kullanıcı durumunu tutan "depo".
///
/// Şimdilik yalnızca favori ilanları (kimlik kümesi) saklar; ilanların kendisi
/// ekranda mock olarak duruyor. Favoriler `shared_preferences` ile kalıcıdır —
/// uygulama yeniden açıldığında geri yüklenir.
class AdoptionStore extends ChangeNotifier {
  AdoptionStore() {
    _load();
  }

  static const _kFavorites = 'adoption_favorites';

  final Set<String> _favoriteIds = {};

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
    final raw = prefs.getString(_kFavorites);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List).cast<String>();
    _favoriteIds
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(_favoriteIds.toList()));
  }
}
