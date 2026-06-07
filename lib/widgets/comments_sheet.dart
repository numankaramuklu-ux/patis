import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../state/community_store.dart';
import '../theme/app_colors.dart';

/// Bir gönderinin yorumlarını gösteren ve yeni yorum eklemeyi sağlayan
/// alttan açılan panel (yol haritası #7).
///
/// Yorumları [CommunityStore]'dan DİNLER; yeni yorumu depo üzerinden ekler ki
/// hem bu panel hem de arkadaki kart anında güncellensin.
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.post});

  final CommunityPost post;

  /// Paneli açan kısa yardımcı. Gönderi kartı bunu çağırır.
  static void show(BuildContext context, CommunityPost post) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CommentsSheet(post: post),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Yorum metnini doğrular ve geçerliyse depoya ekler.
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<CommunityStore>().addComment(widget.post, text);
    _controller.clear();
    // Yazdıktan sonra klavyeyi kapat.
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu dinle ki yeni yorum eklenince liste anında uzasın.
    context.watch<CommunityStore>();
    final comments = widget.post.comments;

    return Padding(
      // Klavye açılınca panelin yukarı itilmesi için viewInsets ekliyoruz.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Yorumlar (${comments.length})',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Yorum listesi: çok uzarsa kaydırılabilir; ekranın yarısıyla sınırlı.
          Flexible(
            child: comments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Henüz yorum yok. İlk yorumu sen yaz!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: comments.length,
                    itemBuilder: (_, i) => _CommentTile(comment: comments[i]),
                  ),
          ),
          const Divider(height: 1),
          // Alt çubuk: yorum yazma alanı + gönder butonu.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Yorumunu yaz...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.cream,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek bir yorum satırı: avatar + isim/zaman + metin.
class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.forest.withValues(alpha: 0.15),
            child: Text(
              comment.initial,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: theme.textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
