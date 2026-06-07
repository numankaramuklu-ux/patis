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
}

/// Yeni gönderi oluştururken avatar rengini sırayla seçmek için kullanılan
/// palet. Mevcut renklerimizden dönüşümlü olarak atanır.
const communityAvatarColors = <Color>[
  AppColors.forest,
  AppColors.terracotta,
  AppColors.gold,
];
