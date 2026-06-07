import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/community_store.dart';
import '../theme/app_colors.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/community_post_card.dart';
import '../widgets/new_post_sheet.dart';

/// Topluluk akışı ekranı (yol haritası #7).
///
/// Alt menüdeki "Topluluk" sekmesi. Gönderileri [CommunityStore]'dan (Provider)
/// okur; beğeni dokunuşlarını ve yeni gönderi eklemeyi depo üzerinden yapar.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu DİNLE: beğeni veya yeni gönderi olunca ekran yeniden çizilir.
    final store = context.watch<CommunityStore>();
    final posts = store.posts;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Topluluk', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Patiş ailesinden paylaşımlar',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final post in posts) ...[
              CommunityPostCard(
                post: post,
                // Beğeni mantığını depo yürütür; kart sadece haber verir.
                onLike: () => store.toggleLike(post),
                // Yorum butonu yorum panelini açar.
                onComment: () => CommentsSheet.show(context, post),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewPostSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Paylaş'),
      ),
    );
  }
}
