import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

/// Bildirimlerin tutulduğu "depo" (store).
///
/// Diğer store'larla aynı mantık (ChangeNotifier): veri değişince
/// `notifyListeners()` çağırır, dinleyen ekran/rozet yeniden çizilir. Okundu
/// durumu `shared_preferences` ile kalıcıdır; ileride Firebase Cloud Messaging
/// ile gerçek anlık bildirimlere bağlanacak.
class NotificationStore extends ChangeNotifier {
  NotificationStore() {
    _load();
  }

  static const _kNotifications = 'notifications';

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
      kind: NotificationKind.booking,
      title: 'Yeni rezervasyon talebi',
      body: 'Mert K., Karamel için 26–29 Haziran konaklama talebinde bulundu.',
      timeAgo: '2 saat önce',
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

  /// Akışın en üstüne yeni bir bildirim ekler (okunmamış). Örn. yeni bir
  /// rezervasyon talebi gelince çağrılır; rozet ve liste otomatik güncellenir.
  void add(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
    _persist();
  }

  /// Tek bir bildirimi okundu olarak işaretler.
  void markAsRead(AppNotification notification) {
    if (notification.read) return;
    notification.read = true;
    notifyListeners();
    _persist();
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
    if (changed) {
      notifyListeners();
      _persist();
    }
  }

  /// Kayıtlı bildirimleri diskten yükler (varsa varsayılanların yerini alır).
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotifications);
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    _notifications
      ..clear()
      ..addAll(decoded);
    notifyListeners();
  }

  /// Bildirim listesini (okundu durumuyla) JSON olarak diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kNotifications,
      jsonEncode(_notifications.map((n) => n.toJson()).toList()),
    );
  }
}
