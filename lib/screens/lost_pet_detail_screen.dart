import 'package:flutter/material.dart';

import '../models/lost_pet.dart';
import '../theme/app_colors.dart';

/// Tek bir kayıp/bulundu ilanının tüm detayını gösteren ekran.
///
/// Kayıp listesindeki bir karta dokununca açılır. Durum rengine göre kapak
/// banner'ı, ad, durum/ödül rozetleri, tür/konum/tarih bilgileri, açıklama ve
/// iletişim aksiyonları gösterir. Veriler şimdilik mock; iletişim/harita
/// aksiyonları ileride gerçek veriyle bağlanacak.
class LostPetDetailScreen extends StatelessWidget {
  const LostPetDetailScreen({super.key, required this.lostPet});

  final LostPet lostPet;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                      onPressed: () => _snack(
                        context,
                        'İletişim bilgileri yakında 🐾',
                      ),
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
                      onPressed: () =>
                          _snack(context, 'Harita görünümü yakında 🗺️'),
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
