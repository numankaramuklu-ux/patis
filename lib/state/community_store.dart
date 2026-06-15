import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/community_post.dart';

/// Topluluk akışındaki gönderilerin tutulduğu "depo" (store).
///
/// Diğer store'larla aynı mantık (ChangeNotifier): veri değişince
/// `notifyListeners()` çağırır, dinleyen ekran yeniden çizilir. Gönderiler,
/// beğeniler ve yorumlar `shared_preferences` ile kalıcıdır; ileride Firebase'e.
class CommunityStore extends ChangeNotifier {
  CommunityStore() {
    _load();
  }

  static const _kPosts = 'community_posts';

  // Başlangıç (mock) gönderileri.
  final List<CommunityPost> _posts = [
    CommunityPost(
      author: 'Ayşe',
      timeAgo: '2 saat önce',
      content:
          'Pamuk bugün ilk kez fırçalanırken hiç huysuzlanmadı! Blogdaki '
          'ipuçları gerçekten işe yaradı 🐱',
      avatarColor: communityAvatarColors[0],
      petTag: 'Pamuk',
      likeCount: 12,
      comments: [
        Comment(author: 'Mert', text: 'Hangi fırçayı kullandın?', timeAgo: '1 saat önce'),
        Comment(author: 'Zeynep', text: 'Çok tatlı 🐱', timeAgo: '1 saat önce'),
        Comment(author: 'Ayşe', text: 'Yumuşak kıllı olanı, blogda link var!', timeAgo: '40 dakika önce'),
      ],
    ),
    CommunityPost(
      author: 'Mert',
      timeAgo: '5 saat önce',
      content:
          'Karamel ile sabah yürüyüşü 🌳 Ankara\'da hava bugün harika. '
          'Birlikte yürüyecek dostlar arıyoruz!',
      avatarColor: communityAvatarColors[1],
      petTag: 'Karamel',
      likeCount: 28,
      comments: [
        Comment(author: 'Ayşe', text: 'Biz de katılmak isteriz!', timeAgo: '4 saat önce'),
        Comment(author: 'Can', text: 'Hangi parkta buluşuyorsunuz?', timeAgo: '3 saat önce'),
      ],
    ),
    CommunityPost(
      author: 'Zeynep',
      timeAgo: 'Dün',
      content:
          'Yeni sahiplendiğimiz Boncuk eve çok çabuk alıştı. Sahiplendirme '
          'ilanlarına göz atmanızı tavsiye ederim ❤️',
      avatarColor: communityAvatarColors[2],
      likeCount: 45,
      comments: [
        Comment(author: 'Mert', text: 'Boncuk\'a hoş geldin dileklerimi ilet ❤️', timeAgo: 'Dün'),
        Comment(author: 'Ayşe', text: 'Sahiplenmek en güzeli, helal olsun!', timeAgo: 'Dün'),
      ],
    ),
  ];

  /// Ekranların okuyacağı gönderi listesi (dışarıdan değiştirilemez kopya).
  List<CommunityPost> get posts => List.unmodifiable(_posts);

  /// Bir gönderinin beğeni durumunu tersine çevirir ve sayacı günceller.
  void toggleLike(CommunityPost post) {
    post.liked = !post.liked;
    post.likeCount += post.liked ? 1 : -1;
    notifyListeners();
    _persist();
  }

  /// Akışın en üstüne yeni bir gönderi ekler.
  void add(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
    _persist();
  }

  /// Bir gönderiye yeni yorum ekler ve sayacı günceller.
  void addComment(CommunityPost post, String text) {
    post.comments.add(Comment(author: 'Sen', text: text));
    notifyListeners();
    _persist();
  }

  /// Kayıtlı gönderileri diskten yükler (varsa varsayılanların yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPosts);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();
    _posts
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Gönderi listesini (beğeni + yorumlarıyla) JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPosts,
      jsonEncode(_posts.map((p) => p.toJson()).toList()),
    );
  }
}
