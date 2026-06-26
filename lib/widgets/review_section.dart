import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/review.dart';
import '../state/auth_store.dart';
import '../state/review_store.dart';
import '../theme/app_colors.dart';

/// Bir hizmet verenin yorum bölümü: ortalama puan özeti, yorum listesi ve
/// "Değerlendir" düğmesi. [targetId] yorumların kime ait olduğunu belirler.
///
/// Tüm rollerde (gezdirici, veteriner, kuaför…) ortak kullanılabilir; veriler
/// [ReviewStore]'dan canlı gelir.
class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.targetId,
    required this.targetName,
    this.showAddButton = true,
    this.title = 'Yorumlar',
  });

  /// Yorumların ait olduğu hizmet verenin kimliği.
  final String targetId;

  /// Değerlendirme panelinde gösterilecek ad (örn. "Elif K.").
  final String targetName;

  /// "Değerlendir" düğmesini göster. İşletme kendi panelinde yorumlarını
  /// görüntülerken `false` verilir (kendi kendini değerlendiremez).
  final bool showAddButton;

  /// Bölüm başlığı (örn. "Yorumlar" / "Müşteri yorumların").
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<ReviewStore>();
    final reviews = store.forTarget(targetId);
    final avg = store.averageFor(targetId);
    final count = store.countFor(targetId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const Spacer(),
            if (showAddButton)
              TextButton.icon(
                onPressed: () =>
                    _AddReviewSheet.show(context, targetId, targetName),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Değerlendir'),
                style: TextButton.styleFrom(foregroundColor: AppColors.forest),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (count > 0) ...[
          Row(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(width: 8),
              _Stars(rating: avg.round()),
              const SizedBox(width: 8),
              Text(
                '($count yorum)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in reviews) ...[
            _ReviewCard(review: r),
            const SizedBox(height: 10),
          ],
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              showAddButton
                  ? 'Henüz yorum yok. İlk değerlendirmeyi sen yap 🐾'
                  : 'Henüz müşteri yorumu yok.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}

/// Yıldız satırı (dolu/boş), verilen tam sayı puana göre.
class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 18});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: AppColors.gold,
          ),
      ],
    );
  }
}

/// Tek bir yorum kartı: yazar + yıldız + metin.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

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
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.forest.withValues(alpha: 0.18),
                child: Text(
                  review.initial,
                  style: const TextStyle(
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _Stars(rating: review.rating, size: 15),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Yıldız seçip yorum yazmak için alt panel.
class _AddReviewSheet extends StatefulWidget {
  const _AddReviewSheet({required this.targetId, required this.targetName});

  final String targetId;
  final String targetName;

  static void show(BuildContext context, String targetId, String targetName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          _AddReviewSheet(targetId: targetId, targetName: targetName),
    );
  }

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    final author = context.read<AuthStore>().name ?? 'Bir müşteri';
    context.read<ReviewStore>().add(
          Review(
            id: 'rv${DateTime.now().millisecondsSinceEpoch}',
            targetId: widget.targetId,
            author: author,
            rating: _rating,
            comment: comment,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Değerlendirmen için teşekkürler 🐾')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.forest;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
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
          Text('${widget.targetName} değerlendir',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          // Yıldız seçici.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  iconSize: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.gold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Yorumun',
              hintText: 'Deneyimini birkaç cümleyle anlat',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Yorumu gönder'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
