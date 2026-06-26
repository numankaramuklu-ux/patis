import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sitter_review.dart';

/// Pet sitter'a bırakılan müşteri yorumlarını tutan depo.
///
/// Ortalama puan, yorum sayısı ve yıldız dağılımı buradan türetilir. Yeni yorum
/// eklenince dinleyen ekranlar güncellenir. Yorumlar `shared_preferences` ile
/// kalıcıdır. (İleride Firebase'e taşınabilir.)
class SitterReviewStore extends ChangeNotifier {
  SitterReviewStore() {
    _load();
  }

  static const _kReviews = 'sitter_reviews';

  // Başlangıç (mock) yorumları — en yeni en üstte.
  final List<SitterReview> _reviews = [
    SitterReview(
      id: 'r1',
      author: 'Merve T.',
      rating: 5,
      comment:
          'Pamuk\'a çok iyi baktı, her gün fotoğraf gönderdi. Kesinlikle tavsiye.',
      timeAgo: '3 gün önce',
    ),
    SitterReview(
      id: 'r2',
      author: 'Kerem A.',
      rating: 5,
      comment: 'İlgili ve güvenilir. Köpeğim ilk günden alıştı.',
      timeAgo: '1 hafta önce',
    ),
    SitterReview(
      id: 'r3',
      author: 'Zeynep B.',
      rating: 4,
      comment: 'İletişimi çok iyiydi, tekrar tercih ederim.',
      timeAgo: '2 hafta önce',
    ),
    SitterReview(
      id: 'r4',
      author: 'Onur K.',
      rating: 5,
      comment: 'Boncuk eve döndüğünde çok mutluydu. Teşekkürler!',
      timeAgo: '3 hafta önce',
    ),
  ];

  /// Yorum listesi (dışarıdan değiştirilemez kopya).
  List<SitterReview> get reviews => List.unmodifiable(_reviews);

  /// Toplam yorum sayısı.
  int get count => _reviews.length;

  /// Ortalama puan (0 yorum varsa 0).
  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold<int>(0, (s, r) => s + r.rating);
    return sum / _reviews.length;
  }

  /// Yıldız dağılımı: yıldız (1–5) → o puanı veren yorum sayısı.
  Map<int, int> get distribution {
    final map = {for (var s = 1; s <= 5; s++) s: 0};
    for (final r in _reviews) {
      final star = r.rating.clamp(1, 5);
      map[star] = (map[star] ?? 0) + 1;
    }
    return map;
  }

  /// Akışın en üstüne yeni bir yorum ekler.
  void add(SitterReview review) {
    _reviews.insert(0, review);
    notifyListeners();
    _persist();
  }

  /// Kayıtlı yorumları diskten yükler (varsa seed'in yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReviews);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => SitterReview.fromJson(e as Map<String, dynamic>))
        .toList();
    _reviews
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Yorum listesini JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kReviews,
      jsonEncode(_reviews.map((r) => r.toJson()).toList()),
    );
  }
}
