import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/service_provider.dart';

/// Owner tarafında gezilen veteriner ve kuaförleri ortak tutan depo.
///
/// [PetSitterStore] / [PetWalkerStore] ile aynı mantık; favoriler ve örnek
/// kayıtlar `shared_preferences` ile kalıcıdır. Tek depo ile hem veterineri hem
/// kuaförü kapsar ([ProviderKind]).
class ServiceProviderStore extends ChangeNotifier {
  ServiceProviderStore() {
    _load();
  }

  static const _kProviders = 'service_providers';
  static const _kFavorites = 'service_provider_favorites';

  final List<ServiceProvider> _providers = List.of(_seed());
  final Set<String> _favoriteIds = {};

  static List<ServiceProvider> _seed() => const [
        // ---- Veterinerler ----
        ServiceProvider(
          id: 'vt1',
          kind: ProviderKind.veteriner,
          name: 'Patiş Veteriner Kliniği',
          district: 'Kadıköy, İstanbul',
          rating: 4.9,
          reviewCount: 64,
          priceFrom: 350,
          summary:
              '7/24 acil servis, dahiliye ve cerrahi. Deneyimli kadro, modern cihazlar.',
          phone: '0216 111 22 33',
          verified: true,
        ),
        ServiceProvider(
          id: 'vt2',
          kind: ProviderKind.veteriner,
          name: 'Dostlar Hayvan Hastanesi',
          district: 'Çankaya, Ankara',
          rating: 4.7,
          reviewCount: 38,
          priceFrom: 300,
          summary: 'Aşı, mikroçip ve check-up. Kedi dostu sakin muayene odaları.',
          phone: '0312 444 55 66',
          verified: true,
        ),
        ServiceProvider(
          id: 'vt3',
          kind: ProviderKind.veteriner,
          name: 'Minik Pati Vet',
          district: 'Konak, İzmir',
          rating: 4.6,
          reviewCount: 21,
          priceFrom: 250,
          summary: 'Egzotik hayvanlarda tecrübeli. Randevulu çalışır.',
          phone: '0232 777 88 99',
        ),
        // ---- Kuaförler ----
        ServiceProvider(
          id: 'gr1',
          kind: ProviderKind.kuafor,
          name: 'Minik Patiler Kuaför',
          district: 'Beşiktaş, İstanbul',
          rating: 4.8,
          reviewCount: 52,
          priceFrom: 200,
          summary:
              'Irk standardında tıraş, tüy bakımı ve tırnak kesimi. Stressiz ortam.',
          phone: '0216 222 33 44',
          verified: true,
        ),
        ServiceProvider(
          id: 'gr2',
          kind: ProviderKind.kuafor,
          name: 'Şirin Patiler Pet Spa',
          district: 'Nilüfer, Bursa',
          rating: 4.7,
          reviewCount: 29,
          priceFrom: 180,
          summary: 'Spa banyo, tüy düğümü açma ve parfüm. Küçük ırk uzmanı.',
          phone: '0224 555 66 77',
        ),
        ServiceProvider(
          id: 'gr3',
          kind: ProviderKind.kuafor,
          name: 'Lüks Pati Salon',
          district: 'Çankaya, Ankara',
          rating: 4.5,
          reviewCount: 17,
          priceFrom: 220,
          summary: 'El ile makaslı kesim, hipoalerjenik şampuan seçenekleri.',
          phone: '0312 888 99 00',
        ),
      ];

  /// Belirli türdeki hizmet verenler (değiştirilemez).
  List<ServiceProvider> byKind(ProviderKind kind) =>
      List.unmodifiable(_providers.where((p) => p.kind == kind));

  /// Kimliğe göre hizmet vereni bulur (yoksa null).
  ServiceProvider? byId(String id) {
    for (final p in _providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---- Favoriler ----

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

    final raw = prefs.getString(_kProviders);
    if (raw != null) {
      final decoded = (jsonDecode(raw) as List)
          .map((e) => ServiceProvider.fromJson(e as Map<String, dynamic>))
          .toList();
      _providers
        ..clear()
        ..addAll(decoded);
    }

    final favRaw = prefs.getString(_kFavorites);
    if (favRaw != null) {
      _favoriteIds
        ..clear()
        ..addAll((jsonDecode(favRaw) as List).cast<String>());
    }

    if (raw != null || favRaw != null) notifyListeners();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(_favoriteIds.toList()));
  }
}
