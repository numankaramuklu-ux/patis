import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../theme/app_colors.dart';

/// Bildirim listesindeki tek bir bildirimi gösteren kart.
///
/// Veriyi dışarıdan [AppNotification] olarak alır. Dokununca [onTap] çağrılır
/// (okundu işaretleme mantığını store yürütür). Okunmamış bildirimler hafif
/// renkli zemin ve sağda küçük bir nokta ile vurgulanır.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !notification.read;
    return Material(
      // Okunmamışsa hafif yeşilimsi zemin, okunmuşsa düz kart rengi.
      color: unread
          ? AppColors.forest.withValues(alpha: 0.06)
          : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Türe göre renkli ikon kutusu.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        // Okunmamışsa başlık biraz daha belirgin.
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.3,
                        color: AppColors.text.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Okunmamış göstergesi: küçük terracotta nokta.
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
