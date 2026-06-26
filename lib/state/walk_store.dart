import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dog_walk.dart';

/// Pet walker panelinin (dashboard) tüm köpek yürüyüşlerini tutan depo.
///
/// Dashboard, takvim ve özet kartı aynı kaynaktan beslendiği için veriler
/// tutarlı kalır. Bir yürüyüşün durumu değişince (onay/tamamla/iptal)
/// `notifyListeners()` ile dinleyen tüm ekranlar güncellenir. Yürüyüşler
/// `shared_preferences` ile kalıcıdır. (İleride Firebase'e taşınabilir.)
class WalkStore extends ChangeNotifier {
  WalkStore() {
    _load();
  }

  static const _kWalks = 'dog_walks';

  final List<DogWalk> _walks = _seed();

  /// Yürüyüşleri bugüne göreceli tarihlerle üretir; böylece "Bugün"/"Yarın"
  /// etiketleri her zaman güncel kalır (mock veri).
  static List<DogWalk> _seed() {
    final now = DateTime.now();
    DateTime day(int addDays) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: addDays));
    return [
      DogWalk(
        id: 'w1',
        ownerName: 'Mert K.',
        petName: 'Karamel',
        breed: 'Pomeranian',
        date: day(0),
        time: '09:00',
        durationMin: 30,
        price: 120,
        note: 'Sabah enerjisi yüksek, koşmayı sever.',
        phone: '0533 444 55 66',
        status: WalkStatus.onaylandi,
      ),
      DogWalk(
        id: 'w2',
        ownerName: 'Selin A.',
        petName: 'Lokum',
        breed: 'Maltese',
        date: day(0),
        time: '13:30',
        durationMin: 45,
        price: 160,
        phone: '0535 777 88 99',
        status: WalkStatus.bekliyor,
      ),
      DogWalk(
        id: 'w3',
        ownerName: 'Kaan M.',
        petName: 'Zeytin',
        breed: 'Golden Retriever',
        date: day(0),
        time: '18:00',
        durationMin: 60,
        price: 200,
        note: 'Diğer köpeklerle iyi anlaşır.',
        phone: '0537 555 66 77',
        status: WalkStatus.bekliyor,
      ),
      DogWalk(
        id: 'w4',
        ownerName: 'Zeynep A.',
        petName: 'Boncuk',
        breed: 'Terrier',
        date: day(-1),
        time: '10:00',
        durationMin: 30,
        price: 120,
        status: WalkStatus.tamamlandi,
      ),
      DogWalk(
        id: 'w5',
        ownerName: 'Onur B.',
        petName: 'Duman',
        breed: 'Husky',
        date: day(1),
        time: '08:30',
        durationMin: 60,
        price: 220,
        note: 'Çok enerjik, uzun yürüyüş gerekiyor.',
        phone: '0536 222 33 44',
        status: WalkStatus.onaylandi,
      ),
      DogWalk(
        id: 'w6',
        ownerName: 'Gizem D.',
        petName: 'Şila',
        breed: 'Poodle',
        date: day(2),
        time: '16:00',
        durationMin: 45,
        price: 160,
        status: WalkStatus.bekliyor,
      ),
    ];
  }

  /// Tüm yürüyüşler — gün ve saate göre sıralı (dışarıdan değiştirilemez).
  List<DogWalk> get walks {
    final list = List<DogWalk>.from(_walks)
      ..sort((a, b) {
        final byDay = a.date.compareTo(b.date);
        return byDay != 0 ? byDay : a.time.compareTo(b.time);
      });
    return List.unmodifiable(list);
  }

  /// Bugünkü yürüyüşler (ana ekran ve özet için).
  List<DogWalk> get todays =>
      walks.where((w) => w.dayLabel == 'Bugün').toList();

  /// Bugün iptal edilmemiş yürüyüş sayısı.
  int get todayCount =>
      todays.where((w) => w.status != WalkStatus.iptal).length;

  /// Onay bekleyen yürüyüş sayısı.
  int get pendingCount =>
      _walks.where((w) => w.status == WalkStatus.bekliyor).length;

  /// Onaylı + tamamlanmış yürüyüşlerden beklenen toplam kazanç (TL).
  int get projectedEarnings => _walks
      .where((w) =>
          w.status == WalkStatus.onaylandi ||
          w.status == WalkStatus.tamamlandi)
      .fold<int>(0, (sum, w) => sum + w.price);

  /// Yeni bir yürüyüş ekler.
  void add(DogWalk walk) {
    _walks.add(walk);
    notifyListeners();
    _persist();
  }

  /// Bir yürüyüşün durumunu değiştirir (onayla / tamamla / iptal).
  void updateStatus(String id, WalkStatus status) {
    final i = _walks.indexWhere((w) => w.id == id);
    if (i == -1) return;
    _walks[i] = _walks[i].copyWith(status: status);
    notifyListeners();
    _persist();
  }

  /// Kayıtlı yürüyüşleri diskten yükler (varsa seed'in yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kWalks);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => DogWalk.fromJson(e as Map<String, dynamic>))
        .toList();
    _walks
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Yürüyüş listesini JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kWalks,
      jsonEncode(_walks.map((w) => w.toJson()).toList()),
    );
  }
}
