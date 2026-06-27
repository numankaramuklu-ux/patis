import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_notification.dart';
import '../models/pet_sitter.dart';
import '../models/sitter_booking.dart';
import '../state/auth_store.dart';
import '../state/message_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import '../state/pet_sitter_store.dart';
import '../state/sitter_booking_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import 'chat_screen.dart';

/// Tek bir pet sitter'ın detay ekranı.
///
/// Profil başlığı (foto/avatar, ad, onaylı rozeti, semt, puan), bilgi kutuları,
/// kabul ettiği türler, tanıtım ve örnek yorumlar. Altta "Rezervasyon iste"
/// (tarih aralığı seçtirir) ve "Ara/Mesaj" (telefon varsa `url_launcher` ile)
/// aksiyonları. Favori durumu [PetSitterStore]'dan canlı gelir.
class PetSitterDetailScreen extends StatelessWidget {
  const PetSitterDetailScreen({super.key, required this.sitter});

  final PetSitter sitter;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Telefon varsa ara/mesaj seçeneklerini sunan paneli açar.
  void _openContact(BuildContext context) {
    final phone = sitter.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'Bu bakıcı için iletişim bilgisi yok');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ContactSheet(sitter: sitter),
    );
  }

  /// Tarih aralığı seçtirir; seçilince talebi bakıcının rezervasyon listesine
  /// "onay bekliyor" olarak ekler ve bir bildirim oluşturur. Böylece bakıcı
  /// tarafında otomatik olarak "Onay bekleyenler"e düşer.
  Future<void> _requestBooking(BuildContext context) async {
    final now = DateTime.now();
    // Talebi göndermeden önce gerekli depoları/verileri al (await sonrası
    // context kullanımını azaltmak için).
    final bookingStore = context.read<SitterBookingStore>();
    final notificationStore = context.read<NotificationStore>();
    final pet = context.read<PassportStore>().pet;
    final ownerName = context.read<AuthStore>().name ?? 'Bir müşteri';

    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      helpText: '${sitter.name} için tarih seç',
      saveText: 'Talep et',
    );
    if (range == null || !context.mounted) return;

    final booking = SitterBooking(
      id: 'req${DateTime.now().millisecondsSinceEpoch}',
      ownerName: ownerName,
      petName: pet.name,
      breed: pet.breed,
      species: pet.species ?? '',
      startDate: range.start,
      endDate: range.end,
      pricePerNight: sitter.pricePerDay,
      status: SitterBookingStatus.bekliyor,
    );
    // Otomatik olarak bekleyen rezervasyonlara ekle.
    bookingStore.add(booking);
    // Bakıcıya bildirim oluştur.
    notificationStore.add(
      AppNotification(
        kind: NotificationKind.booking,
        title: 'Yeni rezervasyon talebi',
        body: '$ownerName, ${pet.name} için ${booking.rangeLabel} '
            'konaklama talebinde bulundu.',
        timeAgo: 'Az önce',
      ),
    );

    _snack(
      context,
      '${formatTrDayMonth(range.start)} – ${formatTrDayMonth(range.end)} '
      '(${booking.nights} gece • ₺${booking.total}) rezervasyon talebin '
      'gönderildi 🐾',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<PetSitterStore>();
    final isFav = store.isFavorite(sitter.id);
    const accent = AppColors.forest;

    return Scaffold(
      appBar: AppBar(
        title: Text(sitter.name),
        actions: [
          IconButton(
            onPressed: () => store.toggleFavorite(sitter.id),
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
                      image: sitter.photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(sitter.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: sitter.photoPath != null
                        ? null
                        : Text(
                            sitter.name.characters.first,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: accent,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sitter.name, style: theme.textTheme.headlineSmall),
                      if (sitter.verified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: accent, size: 22),
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
                        sitter.district,
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
                  value: '${sitter.rating}',
                  label: 'puan',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.payments_outlined,
                  value: '₺${sitter.pricePerDay}',
                  label: 'günlük',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.reviews_outlined,
                  value: '${sitter.reviewCount}',
                  label: 'yorum',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Kabul ettiği türler ----
            Text('Baktığı dostlar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pet in sitter.accepts)
                  Chip(
                    avatar: Icon(pet.icon, size: 18, color: accent),
                    label: Text(pet.label),
                    backgroundColor: accent.withValues(alpha: 0.1),
                    side: BorderSide(color: accent.withValues(alpha: 0.3)),
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
                sitter.summary,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Örnek yorumlar (mock) ----
            Text('Yorumlar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final review in _mockReviews) ...[
              _ReviewCard(review: review),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),

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
                      side: const BorderSide(color: accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _requestBooking(context),
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Rezervasyon'),
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

/// Detaydaki örnek yorumlar (mock; ileride gerçek değerlendirmeler gelir).
const _mockReviews = <_Review>[
  _Review(
    author: 'Merve T.',
    rating: 5,
    text:
        'Pamuk\'a çok iyi baktı, her gün fotoğraf gönderdi. Kesinlikle tavsiye.',
  ),
  _Review(
    author: 'Kerem A.',
    rating: 5,
    text: 'İlgili ve güvenilir. Köpeğim ilk günden alıştı.',
  ),
  _Review(
    author: 'Zeynep B.',
    rating: 4,
    text: 'İletişimi çok iyiydi, tekrar tercih ederim.',
  ),
];

/// Tek bir mock yorum.
class _Review {
  const _Review({
    required this.author,
    required this.rating,
    required this.text,
  });

  final String author;
  final int rating;
  final String text;
}

/// Yorum kartı: yazar + yıldız + metin.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.author,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              for (var i = 0; i < 5; i++)
                Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline,
                  size: 16,
                  color: AppColors.gold,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detaydaki tek bir bilgi kutusu (ikon + değer + etiket).
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

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
            Icon(icon, color: AppColors.forest, size: 22),
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

/// İletişim alt paneli: bakıcı adı/telefonu + Ara ve Mesaj butonları.
class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.sitter});

  final PetSitter sitter;

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

  /// Uygulama içi sohbeti açar (gerekirse oluşturur).
  void _openChat(BuildContext context) {
    final store = context.read<MessageStore>();
    final id = store.openThread(
      peerName: sitter.name,
      peerRole: 'Pet sitter',
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
    const accent = AppColors.forest;
    final phone = sitter.phone ?? '';
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
              const Icon(Icons.person_outline, size: 20, color: accent),
              const SizedBox(width: 10),
              Text(sitter.name, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 20, color: accent),
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
                  // Numarayı panoya kopyala (emülatörde arama/SMS açılamazsa).
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
