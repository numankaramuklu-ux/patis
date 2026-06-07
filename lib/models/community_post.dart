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
    this.commentCount = 0,
    this.liked = false,
  });

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

  /// Yorum sayısı.
  final int commentCount;

  /// Bu gönderiyi kullanıcı beğendi mi? (değişebilir)
  bool liked;

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
