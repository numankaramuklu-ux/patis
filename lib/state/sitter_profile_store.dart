import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sitter_profile.dart';

/// Pet sitter'ın işletme/profil bilgisini (adres, mekan fotoğrafları, fiyat
/// listesi) tutan depo. Tekil bir [SitterProfile] tutar; değişiklikler
/// `shared_preferences` ile kalıcıdır. (İleride Firebase'e taşınabilir.)
class SitterProfileStore extends ChangeNotifier {
  SitterProfileStore() {
    _load();
  }

  static const _kProfile = 'sitter_profile';

  // Başlangıç (mock) profili — örnek adres ve fiyat listesiyle.
  SitterProfile _profile = const SitterProfile(
    district: 'Kadıköy, İstanbul',
    address: 'Caferağa Mah. Moda Cad. No:12',
    priceItems: [
      SitterPriceItem(
        id: 'p1',
        label: 'Gecelik konaklama',
        price: 250,
        unit: 'gece',
        note: 'Evde birebir bakım, sabah-akşam besleme',
      ),
      SitterPriceItem(
        id: 'p2',
        label: 'Gündüz bakımı',
        price: 150,
        unit: 'gün',
      ),
      SitterPriceItem(
        id: 'p3',
        label: 'Köpek yürüyüşü',
        price: 80,
        unit: 'yürüyüş',
        note: '30-45 dakika',
      ),
    ],
  );

  /// Okunan profil (dışarıdan değiştirilemez referans).
  SitterProfile get profile => _profile;

  /// Adres bilgilerini günceller.
  void updateAddress({required String district, required String address}) {
    _profile = _profile.copyWith(district: district, address: address);
    notifyListeners();
    _persist();
  }

  /// Mekan fotoğrafı ekler (yolunu listeye katar).
  void addPhoto(String path) {
    _profile =
        _profile.copyWith(photoPaths: [..._profile.photoPaths, path]);
    notifyListeners();
    _persist();
  }

  /// Bir mekan fotoğrafını listeden çıkarır.
  void removePhoto(String path) {
    _profile = _profile.copyWith(
      photoPaths: _profile.photoPaths.where((p) => p != path).toList(),
    );
    notifyListeners();
    _persist();
  }

  /// Yeni bir fiyat kalemi ekler.
  void addPriceItem(SitterPriceItem item) {
    _profile =
        _profile.copyWith(priceItems: [..._profile.priceItems, item]);
    notifyListeners();
    _persist();
  }

  /// Var olan bir fiyat kalemini günceller (aynı id'linin yerine yazar).
  void updatePriceItem(SitterPriceItem item) {
    _profile = _profile.copyWith(
      priceItems: [
        for (final p in _profile.priceItems)
          if (p.id == item.id) item else p,
      ],
    );
    notifyListeners();
    _persist();
  }

  /// Bir fiyat kalemini siler.
  void deletePriceItem(String id) {
    _profile = _profile.copyWith(
      priceItems: _profile.priceItems.where((p) => p.id != id).toList(),
    );
    notifyListeners();
    _persist();
  }

  /// Kayıtlı profili diskten yükler (varsa seed'in yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null) return;
    _profile = SitterProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    notifyListeners();
  }

  /// Profili JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(_profile.toJson()));
  }
}
