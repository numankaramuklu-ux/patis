import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Topluluk akışındaki tek bir gönderi (yol haritası #7).
///
/// Beğeni durumu kullanıcı dokundukça değiştiği için [liked] ve [likeCount]
/// alanları `final` DEĞİL (değiştirilebilir). Bunları doğrudan elle değil,
/// her zaman `CommunityStore.toggleLike` üzerinden değiştiriyoruz ki ekran
/// otomatik güncellensin.
class CommunityPost {
  CommunityPost({
    required this.author,
    required this.timeAgo,
    required this.content,
    required this.avatarColor,
    this.petTag,
    this.likeCount = 0,
    List<Comment>? comments,
    this.liked = false,
  }) : comments = comments ?? [];

  /// Gönderiyi paylaşan kişinin adı.
  final String author;

  /// Ne kadar önce paylaşıldığı (örn. "2 saat önce"). Şimdilik hazır metin.
  final String timeAgo;

  /// Gönderi metni.
  final String content;

  /// Avatarın (baş harfli yuvarlağın) arka plan rengi — her kullanıcıyı
  /// görsel olarak ayırmak için.
  final Color avatarColor;

  /// İsteğe bağlı evcil hayvan etiketi (örn. "Pamuk"). Verilirse kartta
  /// küçük bir rozet olarak gösterilir.
  final String? petTag;

  /// Beğeni sayısı (değişebilir).
  int likeCount;

  /// Bu gönderiye yapılan yorumlar (değişebilir liste). Yeni yorumlar
  /// `CommunityStore.addComment` ile eklenir ki ekran otomatik güncellensin.
  final List<Comment> comments;

  /// Bu gönderiyi kullanıcı beğendi mi? (değişebilir)
  bool liked;

  /// Yorum sayısı — her zaman yorum listesinin uzunluğu.
  int get commentCount => comments.length;

  /// Avatarda gösterilecek baş harf.
  String get initial => author.characters.first;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir. Renk ARGB tam
  /// sayı olarak yazılır.
  Map<String, dynamic> toJson() => {
        'author': author,
        'timeAgo': timeAgo,
        'content': content,
        'avatarColor': avatarColor.toARGB32(),
        'petTag': petTag,
        'likeCount': likeCount,
        'liked': liked,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  /// Saklanan Map'ten [CommunityPost] üretir.
  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
        author: json['author'] as String? ?? '',
        timeAgo: json['timeAgo'] as String? ?? '',
        content: json['content'] as String? ?? '',
        avatarColor: Color(
          (json['avatarColor'] as num?)?.toInt() ??
              communityAvatarColors[0].toARGB32(),
        ),
        petTag: json['petTag'] as String?,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        liked: json['liked'] as bool? ?? false,
        comments: (json['comments'] as List? ?? const [])
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Bir gönderiye yapılan tek bir yorum.
class Comment {
  Comment({
    required this.author,
    required this.text,
    this.timeAgo = 'Az önce',
  });

  /// Yorumu yazan kişinin adı.
  final String author;

  /// Yorum metni.
  final String text;

  /// Ne kadar önce yazıldığı (örn. "1 saat önce").
  final String timeAgo;

  /// Avatarda gösterilecek baş harf.
  String get initial => author.characters.first;

  /// Cihazda saklamak için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'author': author,
        'text': text,
        'timeAgo': timeAgo,
      };

  /// Saklanan Map'ten [Comment] üretir.
  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        author: json['author'] as String? ?? '',
        text: json['text'] as String? ?? '',
        timeAgo: json['timeAgo'] as String? ?? 'Az önce',
      );
}

/// Yeni gönderi oluştururken avatar rengini sırayla seçmek için kullanılan
/// palet. Mevcut renklerimizden dönüşümlü olarak atanır.
const communityAvatarColors = <Color>[
  AppColors.forest,
  AppColors.terracotta,
  AppColors.gold,
];
