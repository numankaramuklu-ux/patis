import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../models/sitter_booking.dart';
import '../state/notification_store.dart';
import '../state/sitter_booking_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import '../widgets/new_sitter_booking_sheet.dart';
import '../widgets/sitter_booking_card.dart';
import 'notifications_screen.dart';

/// Pet sitter rolünün 1. sekmesi: "Rezervasyonlar" paneli (dashboard).
///
/// Üstte özet istatistik kartı (aktif konaklama, bekleyen talep, beklenen
/// kazanç), altında onay bekleyen talepler ile yaklaşan konaklamalar. Karta
/// dokununca aksiyon paneli ([SitterBookingDetailSheet]) açılır. Veriler
/// [SitterBookingStore]'dan canlı gelir.
class PetSitterDashboardScreen extends StatelessWidget {
  const PetSitterDashboardScreen({super.key, this.onSelectTab});

  /// Bildirime dokununca ilgili sekmeye geçmek için (MainScaffold'dan gelir).
  final ValueChanged<int>? onSelectTab;

  /// Yeni bir gelen rezervasyon talebini simüle eder: bekleyen rezervasyon
  /// olarak ekler ve buna karşılık okunmamış bir bildirim oluşturur. Backend
  /// bağlanınca bu akış gerçek "gelen talep" olayıyla beslenecek.
  void _receiveRequest(BuildContext context) {
    final booking = context.read<SitterBookingStore>().receiveIncomingRequest();
    context.read<NotificationStore>().add(
          AppNotification(
            kind: NotificationKind.booking,
            title: 'Yeni rezervasyon talebi',
            body:
                '${booking.ownerName}, ${booking.petName} için ${booking.rangeLabel} '
                'konaklama talebinde bulundu.',
            timeAgo: 'Az önce',
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${booking.petName} için yeni talep geldi 🔔')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<SitterBookingStore>();
    final unread = context.watch<NotificationStore>().unreadCount;
    final all = store.bookings;

    // Onay bekleyenleri öne al; ardından kalan rezervasyonlar tarih sırasında.
    final pending = all
        .where((b) => b.status == SitterBookingStatus.bekliyor)
        .toList();
    final others = all
        .where((b) => b.status != SitterBookingStatus.bekliyor)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Başlık + bildirim zili + "gelen talep" (demo) butonu.
            Row(
              children: [
                Expanded(
                  child: Text('Rezervasyonlar',
                      style: theme.textTheme.headlineMedium),
                ),
                _NotificationBell(
                  count: unread,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                        onSelectTab: onSelectTab ?? (_) {},
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _receiveRequest(context),
                  icon: const Icon(Icons.move_to_inbox_outlined),
                  color: AppColors.forest,
                  tooltip: 'Yeni talep al (demo)',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              active: store.activeCount,
              pending: store.pendingCount,
              earnings: store.projectedEarnings,
            ),
            const SizedBox(height: 24),

            // Onay bekleyen talepler bölümü.
            if (pending.isNotEmpty) ...[
              Row(
                children: [
                  Text('Onay bekleyenler', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pending.length}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final b in pending) ...[
                SitterBookingCard(
                  booking: b,
                  onTap: () => SitterBookingDetailSheet.show(context, b),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
            ],

            // Diğer rezervasyonlar (onaylı / tamamlanmış / iptal).
            Text('Tüm konaklamalar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (others.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    'Henüz konaklama yok',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              for (final b in others) ...[
                SitterBookingCard(
                  booking: b,
                  onTap: () => SitterBookingDetailSheet.show(context, b),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewSitterBookingSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Yeni konaklama'),
      ),
    );
  }
}

/// Başlıktaki bildirim zili (okunmamış sayısını rozet olarak gösterir).
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.text,
          tooltip: 'Bildirimler',
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.cream, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Üstteki özet istatistik kartı (forest zeminli): aktif konaklama, bekleyen
/// talep, beklenen kazanç.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.active,
    required this.pending,
    required this.earnings,
  });

  final int active;
  final int pending;
  final int earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Stat(value: '$active', label: 'aktif konaklama'),
          _divider(),
          _Stat(value: '$pending', label: 'bekleyen talep'),
          _divider(),
          _Stat(
            value: '${(earnings / 1000).toStringAsFixed(1)}k₺',
            label: 'beklenen kazanç',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: AppColors.cream.withValues(alpha: 0.2),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rezervasyon detayını ve duruma göre aksiyon butonlarını gösteren alt panel.
///
/// Salon randevu detay paneliyle aynı deseni izler; pet sitter panelinin hem
/// dashboard hem de takvim ekranı bunu kullanır.
class SitterBookingDetailSheet extends StatelessWidget {
  const SitterBookingDetailSheet({super.key, required this.booking});

  final SitterBooking booking;

  static void show(BuildContext context, SitterBooking booking) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SitterBookingDetailSheet(booking: booking),
    );
  }

  /// Durumu değiştirir, kullanıcıya kısa bilgi verir ve paneli kapatır.
  void _setStatus(
    BuildContext context,
    SitterBookingStatus status,
    String msg,
  ) {
    context.read<SitterBookingStore>().updateStatus(booking.id, status);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = booking;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
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
            Row(
              children: [
                Expanded(
                  child: Text('${b.petName} • ${b.breed}',
                      style: theme.textTheme.titleLarge),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: b.status.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    b.status.label,
                    style: TextStyle(
                      color: b.status.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
                icon: Icons.person_outline, label: 'Sahibi', value: b.ownerName),
            _DetailRow(icon: Icons.pets, label: 'Tür', value: b.species),
            _DetailRow(
              icon: Icons.date_range_outlined,
              label: 'Tarih',
              value:
                  '${formatTrDate(b.startDate)} – ${formatTrDate(b.endDate)}',
            ),
            _DetailRow(
                icon: Icons.bedtime_outlined,
                label: 'Süre',
                value: '${b.nights} gece'),
            _DetailRow(
              icon: Icons.payments_outlined,
              label: 'Ücret',
              value: '${b.total} ₺  (${b.pricePerNight} ₺/gece)',
            ),
            if (b.note != null && b.note!.isNotEmpty)
              _DetailRow(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Not',
                  value: b.note!),
            if (b.phone != null && b.phone!.isNotEmpty)
              _PhoneRow(phone: b.phone!),
            const SizedBox(height: 24),
            ..._actions(context),
          ],
        ),
      ),
    );
  }

  /// Mevcut duruma göre uygun aksiyon butonlarını üretir.
  List<Widget> _actions(BuildContext context) {
    switch (booking.status) {
      case SitterBookingStatus.bekliyor:
        return [
          _PrimaryButton(
            label: 'Rezervasyonu onayla',
            color: AppColors.forest,
            icon: Icons.check_circle_outline,
            onPressed: () => _setStatus(
                context, SitterBookingStatus.onaylandi, 'Rezervasyon onaylandı'),
          ),
          const SizedBox(height: 10),
          _TextAction(
            label: 'Talebi reddet',
            color: AppColors.terracotta,
            onPressed: () => _setStatus(
                context, SitterBookingStatus.iptal, 'Talep reddedildi'),
          ),
        ];
      case SitterBookingStatus.onaylandi:
        return [
          _PrimaryButton(
            label: 'Konaklamayı tamamla',
            color: const Color(0xFF5B8C7B),
            icon: Icons.done_all,
            onPressed: () => _setStatus(context,
                SitterBookingStatus.tamamlandi, 'Konaklama tamamlandı'),
          ),
          const SizedBox(height: 10),
          _TextAction(
            label: 'Rezervasyonu iptal et',
            color: AppColors.terracotta,
            onPressed: () => _setStatus(
                context, SitterBookingStatus.iptal, 'Rezervasyon iptal edildi'),
          ),
        ];
      case SitterBookingStatus.tamamlandi:
        return [
          _InfoNote(
            icon: Icons.done_all,
            text: 'Bu konaklama tamamlandı.',
            color: const Color(0xFF5B8C7B),
          ),
        ];
      case SitterBookingStatus.iptal:
        return [
          _TextAction(
            label: 'İptali geri al (bekliyor)',
            color: AppColors.forest,
            onPressed: () => _setStatus(
                context, SitterBookingStatus.bekliyor, 'Talep geri alındı'),
          ),
        ];
    }
  }
}

/// Detay panelindeki tek bir bilgi satırı (ikon + etiket + değer).
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.forest),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Telefon satırı — kopyalama butonuyla (emülatörde arama açılamadığında işe yarar).
class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined, size: 20, color: AppColors.forest),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              'Telefon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
            color: AppColors.forest,
            tooltip: 'Numarayı kopyala',
          ),
        ],
      ),
    );
  }
}

/// Dolgu (filled) ana aksiyon butonu.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// İkincil metin aksiyonu (örn. iptal).
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: color),
        child: Text(label),
      ),
    );
  }
}

/// Aksiyon gerektirmeyen durumlarda gösterilen bilgi notu.
class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
