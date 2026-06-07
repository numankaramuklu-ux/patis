import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

/// Bildirimlerin tutulduğu "depo" (store).
///
/// Diğer store'larla aynı mantık (ChangeNotifier): veri değişince
/// `notifyListeners()` çağırır, dinleyen ekran/rozet yeniden çizilir. Şimdilik
/// veriler bellekte (uygulama kapanınca sıfırlanır); ileride Firebase Cloud
/// Messaging ile gerçek anlık bildirimlere bağlanacak.
class NotificationStore extends ChangeNotifier {
  // Başlangıç (mock) bildirimleri — en yeni en üstte.
  final List<AppNotification> _notifications = [
    AppNotification(
      kind: NotificationKind.appointment,
      title: 'Yaklaşan randevu',
      body: 'Pamuk\'un aşı kontrolü 12 Haziran 14:30\'da. Unutma!',
      timeAgo: '1 saat önce',
    ),
    AppNotification(
      kind: NotificationKind.community,
      title: 'Gönderine yorum geldi',
      body: 'Mert, paylaşımına yorum yaptı: "Hangi fırçayı kullandın?"',
      timeAgo: '3 saat önce',
    ),
    AppNotification(
      kind: NotificationKind.lostPet,
      title: 'Yakınında kayıp ilanı',
      body: 'Çankaya\'da kaybolan "Boncuk" için yardım aranıyor.',
      timeAgo: 'Dün',
    ),
    AppNotification(
      kind: NotificationKind.system,
      title: 'Patiş\'e hoş geldin 🐾',
      body: 'Dostunun bakımını kolaylaştırmak için buradayız.',
      timeAgo: '3 gün önce',
      read: true,
    ),
  ];

  /// Ekranların okuyacağı bildirim listesi (dışarıdan değiştirilemez kopya).
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Okunmamış bildirim sayısı (Ana Sayfa'daki rozet bunu kullanır).
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Tek bir bildirimi okundu olarak işaretler.
  void markAsRead(AppNotification notification) {
    if (notification.read) return;
    notification.read = true;
    notifyListeners();
  }

  /// Tüm bildirimleri okundu olarak işaretler.
  void markAllAsRead() {
    var changed = false;
    for (final n in _notifications) {
      if (!n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
