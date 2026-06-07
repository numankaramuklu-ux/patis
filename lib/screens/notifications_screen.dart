import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../state/notification_store.dart';
import '../theme/app_colors.dart';
import '../widgets/notification_tile.dart';

/// Bildirimler ekranı (yol haritası: Bildirimler).
///
/// Ana Sayfa'daki "Bildirim" kutusundan açılır. Bildirimleri
/// [NotificationStore]'dan (Provider) okur; dokununca okundu işaretler, ilgili
/// sekmeye geçer ve üstteki eylemle hepsini birden okundu yapabilir.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.onSelectTab});

  /// İlgili alt menü sekmesine geçmek için MainScaffold'dan gelen geri-çağırım.
  /// (Bildirimler ekranı kapanıp o sekme açılır.)
  final ValueChanged<int> onSelectTab;

  /// Bildirim türünü alt menü sekme indeksine eşler. Sistem bildiriminin
  /// gideceği bir sekme yok → null (yalnızca okundu işaretlenir).
  int? _tabForKind(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.appointment:
        return 2; // Randevu
      case NotificationKind.lostPet:
        return 3; // Kayıp
      case NotificationKind.community:
        return 4; // Topluluk
      case NotificationKind.system:
        return null;
    }
  }

  /// Bir bildirime dokununca: okundu işaretle ve (sekmesi varsa) o sekmeye geç.
  void _onTapNotification(
    BuildContext context,
    NotificationStore store,
    AppNotification notification,
  ) {
    store.markAsRead(notification);
    final tab = _tabForKind(notification.kind);
    if (tab != null) {
      // Önce alttaki MainScaffold'u ilgili sekmeye geçir (henüz Bildirimler
      // ekranı üstte), sonra bu ekranı kapatınca o sekme görünür hale gelir.
      onSelectTab(tab);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu DİNLE: okundu işaretlenince ekran yeniden çizilir.
    final store = context.watch<NotificationStore>();
    final notifications = store.notifications;
    final hasUnread = store.unreadCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          // Okunmamış varsa "tümünü okundu işaretle" eylemini göster.
          if (hasUnread)
            TextButton(
              onPressed: store.markAllAsRead,
              child: const Text('Tümünü okundu'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: notifications.isEmpty
            ? _EmptyState(theme: theme)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final notification = notifications[i];
                  return NotificationTile(
                    notification: notification,
                    // Okundu işaretle + ilgili sekmeye geç.
                    onTap: () =>
                        _onTapNotification(context, store, notification),
                  );
                },
              ),
      ),
    );
  }
}

/// Hiç bildirim yokken gösterilen boş durum.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.text.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bildirim yok',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
