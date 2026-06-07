import 'package:flutter/foundation.dart';

import '../models/community_post.dart';

/// Topluluk akışındaki gönderilerin tutulduğu "depo" (store).
///
/// Diğer store'larla aynı mantık (ChangeNotifier): veri değişince
/// `notifyListeners()` çağırır, dinleyen ekran yeniden çizilir. Şimdilik veriler
/// bellekte; ileride Firebase'e bağlanacak.
class CommunityStore extends ChangeNotifier {
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
      commentCount: 3,
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
      commentCount: 7,
    ),
    CommunityPost(
      author: 'Zeynep',
      timeAgo: 'Dün',
      content:
          'Yeni sahiplendiğimiz Boncuk eve çok çabuk alıştı. Sahiplendirme '
          'ilanlarına göz atmanızı tavsiye ederim ❤️',
      avatarColor: communityAvatarColors[2],
      likeCount: 45,
      commentCount: 11,
    ),
  ];

  /// Ekranların okuyacağı gönderi listesi (dışarıdan değiştirilemez kopya).
  List<CommunityPost> get posts => List.unmodifiable(_posts);

  /// Bir gönderinin beğeni durumunu tersine çevirir ve sayacı günceller.
  void toggleLike(CommunityPost post) {
    post.liked = !post.liked;
    post.likeCount += post.liked ? 1 : -1;
    notifyListeners();
  }

  /// Akışın en üstüne yeni bir gönderi ekler.
  void add(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }
}
