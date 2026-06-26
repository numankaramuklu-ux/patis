import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sitter_review.dart';
import '../state/sitter_review_store.dart';
import '../theme/app_colors.dart';

/// Müşteri yorumu yazma formu (alttan açılan panel).
///
/// Yıldız puanı (1–5), ad ve yorum metni alınır; kaydedilince
/// [SitterReviewStore]'a eklenir. (Backend gelince gerçek müşteri oturumuyla
/// beslenecek.)
class NewSitterReviewSheet extends StatefulWidget {
  const NewSitterReviewSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewSitterReviewSheet(),
    );
  }

  @override
  State<NewSitterReviewSheet> createState() => _NewSitterReviewSheetState();
}

class _NewSitterReviewSheetState extends State<NewSitterReviewSheet> {
  final _authorController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _authorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _save() {
    final author = _authorController.text.trim();
    final comment = _commentController.text.trim();

    if (author.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad ve yorum zorunlu')),
      );
      return;
    }

    context.read<SitterReviewStore>().add(
          SitterReview(
            id: 'r${DateTime.now().millisecondsSinceEpoch}',
            author: author,
            rating: _rating,
            comment: comment,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yorumun eklendi ⭐')),
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
          Text('Yorum yaz', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          // Yıldız seçici.
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? Icons.star_rounded : Icons.star_outline,
                      color: AppColors.gold,
                      size: 36,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _authorController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Adın',
              hintText: 'Örn. Ayşe Y.',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Yorumun',
              hintText: 'Deneyimini birkaç cümleyle anlat…',
              prefixIcon: Icon(Icons.rate_review_outlined),
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
              child: const Text('Yorumu gönder'),
            ),
          ),
        ],
      ),
    );
  }
}
