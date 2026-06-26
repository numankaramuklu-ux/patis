import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sitter_profile.dart';
import '../models/sitter_review.dart';
import '../state/sitter_profile_store.dart';
import '../state/sitter_review_store.dart';
import '../theme/app_colors.dart';
import '../widgets/new_sitter_price_sheet.dart';
import '../widgets/new_sitter_review_sheet.dart';

/// Pet sitter'ın işletme bilgileri ekranı.
///
/// Üç bölüm: mekan fotoğrafları (galeriden yükle/sil), adres bilgileri
/// (düzenle + haritada gör) ve fiyat listesi (ekle/düzenle/sil). Veriler
/// [SitterProfileStore]'dan gelir.
class SitterProfileScreen extends StatelessWidget {
  const SitterProfileScreen({super.key});

  Future<void> _pickPhoto(BuildContext context) async {
    final store = context.read<SitterProfileStore>();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (picked != null) {
      store.addPhoto(picked.path);
    }
  }

  Future<void> _openMap(BuildContext context, String query) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
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
    final profile = context.watch<SitterProfileStore>().profile;
    final reviewStore = context.watch<SitterReviewStore>();
    final hasAddress =
        profile.district.isNotEmpty || profile.address.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('İşletme bilgileri')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ---- Mekan fotoğrafları ----
          _SectionHeader(
            title: 'Mekan fotoğrafları',
            actionLabel: 'Ekle',
            actionIcon: Icons.add_a_photo_outlined,
            onAction: () => _pickPhoto(context),
          ),
          const SizedBox(height: 12),
          if (profile.photoPaths.isEmpty)
            _EmptyHint(
              icon: Icons.photo_library_outlined,
              text: 'Henüz fotoğraf yok. Mekanını tanıtan kareler ekle.',
            )
          else
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profile.photoPaths.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final path = profile.photoPaths[i];
                  return _PhotoTile(
                    path: path,
                    onRemove: () => context
                        .read<SitterProfileStore>()
                        .removePhoto(path),
                  );
                },
              ),
            ),
          const SizedBox(height: 28),

          // ---- Adres bilgileri ----
          _SectionHeader(
            title: 'Adres bilgileri',
            actionLabel: 'Düzenle',
            actionIcon: Icons.edit_outlined,
            onAction: () => _AddressEditSheet.show(context, profile),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasAddress)
                  Text(
                    'Adres eklenmedi. Müşterilerin seni bulabilmesi için '
                    'adresini gir.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  )
                else ...[
                  if (profile.district.isNotEmpty)
                    _AddressRow(
                      icon: Icons.location_city_outlined,
                      text: profile.district,
                    ),
                  if (profile.address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _AddressRow(
                      icon: Icons.home_outlined,
                      text: profile.address,
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMap(context, profile.mapQuery),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Haritada gör'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forest,
                        side: BorderSide(
                            color: AppColors.forest.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ---- Fiyat listesi ----
          _SectionHeader(
            title: 'Fiyat listesi',
            actionLabel: 'Ekle',
            actionIcon: Icons.add,
            onAction: () => NewSitterPriceSheet.show(context),
          ),
          const SizedBox(height: 12),
          if (profile.priceItems.isEmpty)
            _EmptyHint(
              icon: Icons.payments_outlined,
              text: 'Henüz fiyat yok. Sunduğun hizmetleri ekle.',
            )
          else
            for (final item in profile.priceItems) ...[
              _PriceCard(
                item: item,
                onEdit: () =>
                    NewSitterPriceSheet.show(context, existing: item),
                onDelete: () => _confirmDelete(context, item),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 28),

          // ---- Müşteri yorumları ----
          _SectionHeader(
            title: 'Müşteri yorumları',
            actionLabel: 'Yorum ekle',
            actionIcon: Icons.rate_review_outlined,
            onAction: () => NewSitterReviewSheet.show(context),
          ),
          const SizedBox(height: 12),
          if (reviewStore.count == 0)
            _EmptyHint(
              icon: Icons.reviews_outlined,
              text: 'Henüz yorum yok. İlk yorumu beklerken hizmet vermeye '
                  'devam et.',
            )
          else ...[
            _RatingSummary(
              average: reviewStore.averageRating,
              count: reviewStore.count,
              distribution: reviewStore.distribution,
            ),
            const SizedBox(height: 16),
            for (final review in reviewStore.reviews) ...[
              _ReviewCard(review: review),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SitterPriceItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fiyatı sil'),
        content: Text('"${item.label}" kalemini silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SitterProfileStore>().deletePriceItem(item.id);
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// Bölüm başlığı + sağda küçük bir eylem butonu.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        TextButton.icon(
          onPressed: onAction,
          icon: Icon(actionIcon, size: 18),
          label: Text(actionLabel),
          style: TextButton.styleFrom(foregroundColor: AppColors.forest),
        ),
      ],
    );
  }
}

/// Mekan fotoğrafı küçük resmi + sağ üstte kaldır butonu.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(
            File(path),
            width: 180,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 180,
              height: 140,
              color: AppColors.text.withValues(alpha: 0.06),
              alignment: Alignment.center,
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.text.withValues(alpha: 0.3)),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Adres kartındaki tek bir satır (ikon + metin).
class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.forest),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fiyat listesindeki tek bir kart (ad, açıklama, ücret + düzenle/sil).
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final SitterPriceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${item.price} ₺ / ${item.unit}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.forest,
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.terracotta,
            tooltip: 'Sil',
          ),
        ],
      ),
    );
  }
}

/// Boş bölüm ipucu kutusu.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.forest.withValues(alpha: 0.7), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Yorum özeti: büyük ortalama puan + yıldızlar + sayı + yıldız dağılımı.
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  final double average;
  final int count;
  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol: büyük ortalama + yıldızlar + sayı.
          Column(
            children: [
              Text(
                average.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
              _Stars(rating: average),
              const SizedBox(height: 4),
              Text(
                '$count yorum',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Sağ: yıldız dağılım çubukları (5★ → 1★).
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star_rounded,
                            size: 12, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: count == 0
                                  ? 0
                                  : (distribution[star] ?? 0) / count,
                              minHeight: 6,
                              backgroundColor:
                                  AppColors.text.withValues(alpha: 0.08),
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yıldız satırı: ondalık puana göre dolu yıldızları gösterir (yuvarlanmış).
class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rounded ? Icons.star_rounded : Icons.star_outline,
            size: 16,
            color: AppColors.gold,
          ),
      ],
    );
  }
}

/// Tek bir müşteri yorumu kartı: avatar + ad + yıldız + zaman + metin.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SitterReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.forest.withValues(alpha: 0.12),
                child: Text(
                  review.initial,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _Stars(rating: review.rating.toDouble()),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Adres düzenleme alt paneli (semt + açık adres).
class _AddressEditSheet extends StatefulWidget {
  const _AddressEditSheet({required this.profile});

  final SitterProfile profile;

  static void show(BuildContext context, SitterProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AddressEditSheet(profile: profile),
    );
  }

  @override
  State<_AddressEditSheet> createState() => _AddressEditSheetState();
}

class _AddressEditSheetState extends State<_AddressEditSheet> {
  late final TextEditingController _districtController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _districtController =
        TextEditingController(text: widget.profile.district);
    _addressController = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SitterProfileStore>().updateAddress(
          district: _districtController.text.trim(),
          address: _addressController.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adres güncellendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Text('Adres bilgileri', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _districtController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Semt / şehir',
              hintText: 'Örn. Kadıköy, İstanbul',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Açık adres',
              hintText: 'Mahalle, cadde, bina, kapı no…',
              prefixIcon: Icon(Icons.home_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
