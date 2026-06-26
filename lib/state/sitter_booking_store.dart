import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sitter_booking.dart';

/// Pet sitter panelinin (dashboard) tüm konaklama rezervasyonlarını tutan depo.
///
/// Dashboard, takvim ve özet kartı aynı kaynaktan beslendiği için veriler
/// tutarlı kalır. Bir rezervasyonun durumu değişince (onay/tamamla/iptal)
/// `notifyListeners()` ile dinleyen tüm ekranlar güncellenir. Rezervasyonlar
/// `shared_preferences` ile kalıcıdır. (İleride Firebase'e taşınabilir.)
class SitterBookingStore extends ChangeNotifier {
  SitterBookingStore() {
    _load();
  }

  static const _kBookings = 'sitter_bookings';

  final List<SitterBooking> _bookings = _seed();

  /// Rezervasyonları bugüne göreceli tarihlerle üretir; böylece "Bugün"/"Yarın"
  /// etiketleri her zaman güncel kalır (mock veri).
  static List<SitterBooking> _seed() {
    final now = DateTime.now();
    DateTime day(int addDays) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: addDays));
    return [
      SitterBooking(
        id: 'b1',
        ownerName: 'Ayşe Y.',
        petName: 'Pamuk',
        breed: 'British Shorthair',
        species: 'Kedi',
        startDate: day(-1),
        endDate: day(2),
        pricePerNight: 250,
        note: 'Sabah ve akşam mama. Islak mamayı çok seviyor.',
        phone: '0532 111 22 33',
        status: SitterBookingStatus.onaylandi,
      ),
      SitterBooking(
        id: 'b2',
        ownerName: 'Mert K.',
        petName: 'Karamel',
        breed: 'Pomeranian',
        species: 'Köpek',
        startDate: day(0),
        endDate: day(3),
        pricePerNight: 300,
        note: 'Günde 2 kez yürüyüş gerekiyor.',
        phone: '0533 444 55 66',
        status: SitterBookingStatus.bekliyor,
      ),
      SitterBooking(
        id: 'b3',
        ownerName: 'Selin A.',
        petName: 'Lokum',
        breed: 'Maltese',
        species: 'Köpek',
        startDate: day(2),
        endDate: day(6),
        pricePerNight: 280,
        note: 'Akşamları sakinleştirici tablet veriliyor.',
        phone: '0535 777 88 99',
        status: SitterBookingStatus.bekliyor,
      ),
      SitterBooking(
        id: 'b4',
        ownerName: 'Zeynep A.',
        petName: 'Boncuk',
        breed: 'Tekir',
        species: 'Kedi',
        startDate: day(-5),
        endDate: day(-2),
        pricePerNight: 220,
        phone: '0536 222 33 44',
        status: SitterBookingStatus.tamamlandi,
      ),
      SitterBooking(
        id: 'b5',
        ownerName: 'Kaan M.',
        petName: 'Zeytin',
        breed: 'Golden Retriever',
        species: 'Köpek',
        startDate: day(5),
        endDate: day(9),
        pricePerNight: 350,
        note: 'Çok enerjik, bahçeli ev tercih sebebi.',
        phone: '0537 555 66 77',
        status: SitterBookingStatus.onaylandi,
      ),
      SitterBooking(
        id: 'b6',
        ownerName: 'Derya T.',
        petName: 'Maviş',
        breed: 'Scottish Fold',
        species: 'Kedi',
        startDate: day(8),
        endDate: day(12),
        pricePerNight: 240,
        status: SitterBookingStatus.bekliyor,
      ),
    ];
  }

  /// Tüm rezervasyonlar — başlangıç tarihine göre sıralı (dışarıdan değiştirilemez).
  List<SitterBooking> get bookings {
    final list = List<SitterBooking>.from(_bookings)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return List.unmodifiable(list);
  }

  /// Bugün başlayan rezervasyonlar (giriş günü = bugün).
  List<SitterBooking> get todayCheckIns =>
      bookings.where((b) => b.dayLabel == 'Bugün').toList();

  /// Şu an süren (aktif) konaklama sayısı — özet kartındaki "aktif konaklama".
  int get activeCount => _bookings.where((b) => b.isActiveToday).length;

  /// Onay bekleyen talep sayısı.
  int get pendingCount => _bookings
      .where((b) => b.status == SitterBookingStatus.bekliyor)
      .length;

  /// Onaylı + tamamlanmış rezervasyonlardan beklenen toplam kazanç (TL).
  int get projectedEarnings => _bookings
      .where((b) =>
          b.status == SitterBookingStatus.onaylandi ||
          b.status == SitterBookingStatus.tamamlandi)
      .fold<int>(0, (sum, b) => sum + b.total);

  /// Yeni bir rezervasyon ekler. Liste her okumada başlangıç tarihine göre
  /// sıralandığı için doğru güne otomatik düşer.
  void add(SitterBooking booking) {
    _bookings.add(booking);
    notifyListeners();
    _persist();
  }

  // Demo amaçlı "gelen talep" havuzu. Backend olmadığından, gerçek bir sahibin
  // talep göndermesini simüle etmek için sırayla bu kayıtlardan biri eklenir.
  static const _incomingPool = [
    ('Selin A.', 'Lokum', 'Maltese', 'Köpek', 280, '0533 444 55 66'),
    ('Onur B.', 'Duman', 'Pomeranian', 'Köpek', 300, '0535 777 88 99'),
    ('Gizem D.', 'Şila', 'Poodle', 'Köpek', 320, '0536 222 33 44'),
    ('Emre S.', 'Maviş', 'Scottish Fold', 'Kedi', 240, '0537 555 66 77'),
  ];
  int _incomingIndex = 0;

  /// Yeni bir "gelen rezervasyon talebi" simüle eder: havuzdan bir kayıt alıp
  /// bekleyen (onay bekleyen) bir rezervasyon olarak ekler ve eklenen kaydı
  /// döndürür. Çağıran taraf buna karşılık bir bildirim oluşturabilir.
  SitterBooking receiveIncomingRequest() {
    final now = DateTime.now();
    final p = _incomingPool[_incomingIndex % _incomingPool.length];
    _incomingIndex++;
    // Yakın bir tarih aralığı üret (3–6 gün sonra başlayan birkaç gecelik).
    final startOffset = 3 + (_incomingIndex % 4);
    final start =
        DateTime(now.year, now.month, now.day).add(Duration(days: startOffset));
    final booking = SitterBooking(
      id: 'in${DateTime.now().millisecondsSinceEpoch}',
      ownerName: p.$1,
      petName: p.$2,
      breed: p.$3,
      species: p.$4,
      startDate: start,
      endDate: start.add(const Duration(days: 3)),
      pricePerNight: p.$5,
      phone: p.$6,
      status: SitterBookingStatus.bekliyor,
    );
    _bookings.add(booking);
    notifyListeners();
    _persist();
    return booking;
  }

  /// Bir rezervasyonun durumunu değiştirir (onayla / tamamla / iptal).
  void updateStatus(String id, SitterBookingStatus status) {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) return;
    _bookings[i] = _bookings[i].copyWith(status: status);
    notifyListeners();
    _persist();
  }

  /// Kayıtlı rezervasyonları diskten yükler (varsa seed'in yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookings);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => SitterBooking.fromJson(e as Map<String, dynamic>))
        .toList();
    _bookings
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Rezervasyon listesini JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kBookings,
      jsonEncode(_bookings.map((b) => b.toJson()).toList()),
    );
  }
}
