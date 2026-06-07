import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../state/community_store.dart';
import '../theme/app_colors.dart';

/// "Yeni gönderi" oluşturma formu (alttan açılan panel).
///
/// Kaydedilince gönderiyi [CommunityStore]'a ekler ve paneli kapatır.
/// Diğer formlarla aynı deseni izler.
class NewPostSheet extends StatefulWidget {
  const NewPostSheet({super.key});

  /// Paneli açan kısa yardımcı. Topluluk ekranı bunu çağırır.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewPostSheet(),
    );
  }

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  final _contentController = TextEditingController();
  final _petController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _petController.dispose();
    super.dispose();
  }

  /// Formu doğrular ve geçerliyse gönderiyi depoya ekler.
  void _save() {
    final content = _contentController.text.trim();
    final pet = _petController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir şeyler yaz')),
      );
      return;
    }

    final store = context.read<CommunityStore>();
    // Avatar rengini paletten sırayla seç (mevcut gönderi sayısına göre).
    final color =
        communityAvatarColors[store.posts.length % communityAvatarColors.length];

    store.add(
      CommunityPost(
        author: 'Sen',
        timeAgo: 'Az önce',
        content: content,
        avatarColor: color,
        petTag: pet.isEmpty ? null : pet,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24,
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
          Text('Yeni gönderi', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _contentController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Ne paylaşmak istersin?',
              hintText: 'Dostunla ilgili bir an, soru ya da tavsiye...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _petController,
            decoration: const InputDecoration(
              labelText: 'Evcil hayvan etiketi (isteğe bağlı)',
              hintText: 'Örn. Pamuk',
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
              child: const Text('Paylaş'),
            ),
          ),
        ],
      ),
    );
  }
}
