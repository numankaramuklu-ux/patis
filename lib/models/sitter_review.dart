/// Pet sitter'a bırakılmış tek bir müşteri yorumu ve puanı.
///
/// Puan 1–5 yıldız arası tam sayıdır. Model immutable; saklanırken JSON'a
/// çevrilir.
class SitterReview {
  const SitterReview({
    required this.id,
    required this.author,
    required this.rating,
    required this.comment,
    this.timeAgo = 'Az önce',
  });

  /// Benzersiz kimlik.
  final String id;

  /// Yorumu yazan müşterinin adı.
  final String author;

  /// 1–5 arası yıldız puanı.
  final int rating;

  /// Yorum metni.
  final String comment;

  /// Ne kadar önce yazıldığı (örn. "2 gün önce").
  final String timeAgo;

  /// Avatarda gösterilecek baş harf.
  String get initial => author.isEmpty ? '?' : author.substring(0, 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'rating': rating,
        'comment': comment,
        'timeAgo': timeAgo,
      };

  factory SitterReview.fromJson(Map<String, dynamic> json) => SitterReview(
        id: json['id'] as String? ?? '',
        author: json['author'] as String? ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        comment: json['comment'] as String? ?? '',
        timeAgo: json['timeAgo'] as String? ?? '',
      );
}
