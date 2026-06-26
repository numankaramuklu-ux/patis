import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/review.dart';

/// Tüm hizmet verenlere (gezdirici, veteriner, kuaför…) bırakılan yorumları
/// ortak tutan depo. Yorumlar [Review.targetId] ile gruplanır.
///
/// Ortalama puan ve yorum sayısı [targetId] bazında türetilir. Yeni yorum
/// eklenince dinleyen ekranlar güncellenir. Yorumlar `shared_preferences` ile
/// kalıcıdır. (İleride Firebase'e taşınabilir.)
class ReviewStore extends ChangeNotifier {
  ReviewStore() {
    _load();
  }

  static const _kReviews = 'service_reviews';

  final List<Review> _reviews = List.of(_seed());

  static List<Review> _seed() => const [
        // Gezdirici pw1 (Burak T.)
        Review(
          id: 'rv1',
          targetId: 'pw1',
          author: 'Merve T.',
          rating: 5,
          comment: 'Köpeğimi her gün yürüttü, konum paylaştı. Çok memnunuz.',
          timeAgo: '4 gün önce',
        ),
        Review(
          id: 'rv2',
          targetId: 'pw1',
          author: 'Kerem A.',
          rating: 4,
          comment: 'Dakik ve ilgili. Tekrar tercih ederim.',
          timeAgo: '2 hafta önce',
        ),
        // Gezdirici pw2 (Elif K.)
        Review(
          id: 'rv3',
          targetId: 'pw2',
          author: 'Zeynep B.',
          rating: 5,
          comment: 'Yaşlı köpeğime çok nazik davrandı, fotoğraf gönderdi.',
          timeAgo: '1 hafta önce',
        ),
      ];

  /// Belirli bir hedefin yorumları (en yeni en üstte).
  List<Review> forTarget(String targetId) =>
      List.unmodifiable(_reviews.where((r) => r.targetId == targetId));

  /// Bir hedefin yorum sayısı.
  int countFor(String targetId) =>
      _reviews.where((r) => r.targetId == targetId).length;

  /// Bir hedefin ortalama puanı (yorum yoksa 0).
  double averageFor(String targetId) {
    final list = _reviews.where((r) => r.targetId == targetId).toList();
    if (list.isEmpty) return 0;
    final sum = list.fold<int>(0, (s, r) => s + r.rating);
    return sum / list.length;
  }

  /// Bir hedefin yıldız dağılımı: yıldız (1–5) → yorum sayısı.
  Map<int, int> distributionFor(String targetId) {
    final map = {for (var s = 1; s <= 5; s++) s: 0};
    for (final r in _reviews.where((r) => r.targetId == targetId)) {
      final star = r.rating.clamp(1, 5);
      map[star] = (map[star] ?? 0) + 1;
    }
    return map;
  }

  /// Yeni bir yorum ekler (en üste).
  void add(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
    _persist();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReviews);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
    _reviews
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kReviews,
      jsonEncode(_reviews.map((r) => r.toJson()).toList()),
    );
  }
}
