import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lost_pet.dart';
import '../state/message_store.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';

/// Tek bir kayıp/bulundu ilanının tüm detayını gösteren ekran.
///
/// Kayıp listesindeki bir karta dokununca açılır. Durum rengine göre kapak
/// banner'ı, ad, durum/ödül rozetleri, tür/konum/tarih bilgileri, açıklama ve
/// iletişim aksiyonları gösterir. İletişim (ara/mesaj) ve harita aksiyonları
/// `url_launcher` ile dış uygulamada açılır.
class LostPetDetailScreen extends StatelessWidget {
  const LostPetDetailScreen({super.key, required this.lostPet});

  final LostPet lostPet;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// İlan sahibiyle iletişim: telefon varsa ara/mesaj seçeneklerini sunan alt
  /// paneli açar, yoksa bilgilendirir.
  void _openContact(BuildContext context) {
    final phone = lostPet.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'Bu ilan için iletişim bilgisi yok');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ContactSheet(lostPet: lostPet),
    );
  }

  /// Konumu dış harita uygulamasında (veya tarayıcıda) arar.
  Future<void> _openMap(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final query = Uri.encodeComponent(lostPet.location);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Harita açılamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = lostPet.status.color;
    final isLost = lostPet.status == LostPetStatus.kayip;

    return Scaffold(
      appBar: AppBar(
        title: Text(lostPet.status.label),
        actions: [
          IconButton(
            onPressed: () => _snack(context, 'Paylaşım bağlantısı kopyalandı'),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Kapak banner'ı: durum renginde gradient + tür ikonu ----
            _CoverBanner(lostPet: lostPet),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Durum + ödül rozetleri.
                  Row(
                    children: [
                      _StatusBadge(status: lostPet.status),
                      if (lostPet.hasReward) ...[
                        const SizedBox(width: 8),
                        const _RewardBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(lostPet.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 20),

                  // ---- Bilgi kartı ----
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.text.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: lostPet.species.icon,
                          label: 'Tür',
                          value: lostPet.species.label,
                        ),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Konum',
                          value: lostPet.location,
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: isLost ? 'Kaybolduğu tarih' : 'Bulunduğu tarih',
                          value: lostPet.dateLabel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Açıklama ----
                  Text('Açıklama', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    lostPet.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: AppColors.text.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Aksiyonlar ----
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openContact(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(isLost ? 'İlan sahibine ulaş' : 'Bulan kişiye ulaş'),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: AppColors.cream,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMap(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Haritada gör'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- İpucu notu ----
                  _TipNote(
                    text: isLost
                        ? 'Bu dostu gördüysen ilan sahibine ulaş; çekingen '
                            'olabilir, ani hareketlerden kaçın.'
                        : 'Sahibi olduğunu düşünüyorsan bulan kişiyle '
                            'iletişime geç ve tanımlayıcı bilgileri paylaş.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İlanın üstündeki kapak banner'ı — durum renginde gradient + büyük tür ikonu.
class _CoverBanner extends StatelessWidget {
  const _CoverBanner({required this.lostPet});

  final LostPet lostPet;

  @override
  Widget build(BuildContext context) {
    final accent = lostPet.status.color;

    // Fotoğraf varsa onu kapak olarak göster; yoksa durum renginde gradient
    // + büyük tür ikonu (önceki davranış).
    if (lostPet.photoPath != null) {
      return SizedBox(
        height: 240,
        width: double.infinity,
        child: Image.file(
          File(lostPet.photoPath!),
          fit: BoxFit.cover,
          // Dosya yüklenemezse gradient banner'a düş.
          errorBuilder: (_, _, _) => _gradientBanner(accent),
        ),
      );
    }
    return _gradientBanner(accent);
  }

  /// Fotoğraf yokken gösterilen durum renginde gradient + tür ikonu.
  Widget _gradientBanner(Color accent) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(
        child: Icon(
          lostPet.species.icon,
          size: 80,
          color: AppColors.cream.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Bilgi kartındaki tek bir satır (ikon + sabit genişlikli etiket + değer).
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
            width: 110,
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

/// Büyük durum rozeti (Kayıp / Bulundu).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LostPetStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: AppColors.cream),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ödüllü" rozeti.
class _RewardBadge extends StatelessWidget {
  const _RewardBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, size: 14, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(
            'Ödüllü',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// İletişim alt paneli: ilan sahibinin adı/telefonu + Ara ve Mesaj butonları.
class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.lostPet});

  final LostPet lostPet;

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

  /// İlan sahibiyle uygulama içi sohbeti açar; gerekirse oluşturur. Karşı taraf
  /// adı iletişim adı (yoksa hayvan adı) olur ki her ilan benzersiz thread alsın.
  void _openChat(BuildContext context) {
    final store = context.read<MessageStore>();
    final id = store.openThread(
      peerName: lostPet.contactName ?? lostPet.name,
      peerRole: '${lostPet.status.label} · ${lostPet.name}',
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
    final accent = lostPet.status.color;
    final phone = lostPet.phone ?? '';
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
          if (lostPet.contactName != null) ...[
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 20, color: AppColors.forest),
                const SizedBox(width: 10),
                Text(lostPet.contactName!, style: theme.textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 20, color: AppColors.forest),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phone,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Numarayı panoya kopyala (özellikle emülatörde arama/SMS
              // açılamadığında işe yarar).
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

/// Alttaki yardımcı ipucu kutusu.
class _TipNote extends StatelessWidget {
  const _TipNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 18, color: AppColors.forest),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
