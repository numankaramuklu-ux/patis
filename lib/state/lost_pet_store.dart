import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adoption_listing.dart';
import '../models/lost_pet.dart';

/// Kayıp/Bulundu ilanlarının tutulduğu "depo" (store).
///
/// `AppointmentStore` ile aynı mantık: veri değişince `notifyListeners()`
/// çağırır, dinleyen ekranlar otomatik yeniden çizilir. İlanlar
/// `shared_preferences` ile kalıcıdır; ileride Firebase'e bağlanacak.
class LostPetStore extends ChangeNotifier {
  LostPetStore() {
    _load();
  }

  static const _kLostPets = 'lost_pets';

  // Başlangıç (mock) ilanları.
  final List<LostPet> _lostPets = [
    const LostPet(
      name: 'Boncuk',
      species: AdoptionSpecies.kedi,
      status: LostPetStatus.kayip,
      location: 'Beşiktaş, İstanbul',
      dateLabel: '5 Haziran',
      description: 'Gri tekir, kırmızı tasmalı. Çekingen, korkunca kaçar.',
      hasReward: true,
    ),
    const LostPet(
      name: 'Çakıl',
      species: AdoptionSpecies.kopek,
      status: LostPetStatus.kayip,
      location: 'Karşıyaka, İzmir',
      dateLabel: '3 Haziran',
      description: 'Kahverengi, orta boy. Sağ kulağında küçük bir çentik var.',
    ),
    const LostPet(
      name: 'İsimsiz (siyah kedi)',
      species: AdoptionSpecies.kedi,
      status: LostPetStatus.bulundu,
      location: 'Çankaya, Ankara',
      dateLabel: '6 Haziran',
      description: 'Tasmasız, sağlıklı görünüyor. Geçici olarak bende kalıyor.',
    ),
  ];

  /// Ekranların okuyacağı ilan listesi (dışarıdan değiştirilemez kopya).
  List<LostPet> get lostPets => List.unmodifiable(_lostPets);

  /// Listeye yeni bir ilan ekler ve dinleyicileri uyarır. En üstte görünsün
  /// diye başa ekliyoruz.
  void add(LostPet lostPet) {
    _lostPets.insert(0, lostPet);
    notifyListeners();
    _persist();
  }

  /// Kayıtlı ilanları diskten yükler (varsa varsayılanların yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLostPets);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => LostPet.fromJson(e as Map<String, dynamic>))
        .toList();
    _lostPets
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// İlan listesini JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLostPets,
      jsonEncode(_lostPets.map((p) => p.toJson()).toList()),
    );
  }
}
