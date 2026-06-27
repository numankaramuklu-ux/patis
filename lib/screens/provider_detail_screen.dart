import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../models/service_provider.dart';
import '../state/appointment_store.dart';
import '../state/message_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import '../state/review_store.dart';
import '../state/service_provider_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import '../widgets/review_section.dart';
import 'chat_screen.dart';

/// Tek bir veteriner/kuaförün yorumlu detay ekranı.
///
/// Profil başlığı, bilgi kutuları (canlı puan/yorum), tanıtım, yorum bölümü
/// ([ReviewSection]) ve altta "İletişim" + "Randevu al" aksiyonları. Randevu
/// alınca [AppointmentStore]'a kayıt düşer ve bir bildirim oluşur.
class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key, required this.provider});

  final ServiceProvider provider;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openContact(BuildContext context) {
    final phone = provider.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'Bu işletme için iletişim bilgisi yok');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ContactSheet(provider: provider),
    );
  }

  /// Gün + saat seçtirir; seçilince randevuyu [AppointmentStore]'a ekler ve
  /// bir bildirim oluşturur.
  Future<void> _requestAppointment(BuildContext context) async {
    final apptStore = context.read<AppointmentStore>();
    final notifications = context.read<NotificationStore>();
    final passport = context.read<PassportStore>();
    final petId = passport.current.id;
    final petName = passport.pet.name;

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      helpText: '${provider.name} için gün seç',
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Randevu saati',
    );
    if (time == null || !context.mounted) return;

    final isVet = provider.kind == ProviderKind.veteriner;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final dateLabel = '${formatTrDayMonth(date)}, $h:$m';

    apptStore.add(
      Appointment(
        title: isVet ? 'Veteriner muayenesi' : 'Tüy bakımı & tıraş',
        place: provider.name,
        dateLabel: dateLabel,
        type: isVet ? AppointmentType.veteriner : AppointmentType.kuafor,
        petId: petId,
      ),
    );
    notifications.add(
      AppNotification(
        kind: NotificationKind.appointment,
        title: 'Randevu oluşturuldu',
        body: '$petName için ${provider.name} • $dateLabel randevun alındı.',
        timeAgo: 'Az önce',
      ),
    );
    _snack(context, '$dateLabel randevun oluşturuldu 🐾');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<ServiceProviderStore>();
    final isFav = store.isFavorite(provider.id);
    final reviewStore = context.watch<ReviewStore>();
    final reviewCount = reviewStore.countFor(provider.id);
    final avgRating = reviewCount > 0
        ? reviewStore.averageFor(provider.id).toStringAsFixed(1)
        : '${provider.rating}';
    final accent = provider.kind.accent;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.name),
        actions: [
          IconButton(
            onPressed: () => store.toggleFavorite(provider.id),
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? AppColors.terracotta : null,
            tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Başlık ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(provider.kind.icon, color: accent, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          provider.name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (provider.verified) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.verified, color: accent, size: 22),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.district,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Bilgi kutuları ----
            Row(
              children: [
                _InfoBox(
                  icon: Icons.star_rounded,
                  value: avgRating,
                  label: 'puan',
                  accent: accent,
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.payments_outlined,
                  value: provider.priceFrom != null
                      ? '₺${provider.priceFrom}'
                      : '—',
                  label: 'başlangıç',
                  accent: accent,
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.reviews_outlined,
                  value: '$reviewCount',
                  label: 'yorum',
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Tanıtım ----
            Text('Hakkında', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.text.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                provider.summary,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Yorumlar ----
            ReviewSection(targetId: provider.id, targetName: provider.name),
            const SizedBox(height: 24),

            // ---- Aksiyonlar ----
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openContact(context),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('İletişim'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _requestAppointment(context),
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Randevu al'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.cream,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Detaydaki tek bir bilgi kutusu.
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İletişim alt paneli: işletme adı/telefonu + Ara ve Mesaj butonları.
class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.provider});

  final ServiceProvider provider;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await launchUrl(uri);
    if (ok) {
      navigator.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('İşlem başlatılamadı')),
      );
    }
  }

  /// Uygulama içi sohbeti açar (gerekirse oluşturur). Karşı tarafın rolü
  /// işletme türünden gelir (Veteriner / Kuaför).
  void _openChat(BuildContext context) {
    final store = context.read<MessageStore>();
    final id = store.openThread(
      peerName: provider.name,
      peerRole: provider.kind.label,
    );
    final thread = store.threads.firstWhere((t) => t.id == id);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = provider.kind.accent;
    final phone = provider.phone ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('İletişim', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(provider.name, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phone,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numara kopyalandı')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: accent,
                tooltip: 'Numarayı kopyala',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _launch(context, Uri(scheme: 'tel', path: phone)),
                  icon: const Icon(Icons.call),
                  label: const Text('Ara'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.cream,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Mesaj'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
