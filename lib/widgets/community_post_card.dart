import 'dart:io';

import 'package:flutter/material.dart';

import '../models/community_post.dart';
import '../theme/app_colors.dart';

/// Topluluk akışındaki tek bir gönderiyi gösteren kart.
///
/// Veriyi dışarıdan [CommunityPost] olarak alır. Beğen butonuna basılınca
/// [onLike], yorum butonuna basılınca [onComment] çağrılır (mantığı store
/// yürütür).
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: avatar + isim/zaman + (varsa) evcil hayvan etiketi.
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: post.avatarColor,
                child: Text(
                  post.initial,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author, style: theme.textTheme.titleMedium),
                    Text(
                      post.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (post.petTag != null) _PetTag(label: post.petTag!),
            ],
          ),
          // Metin varsa göster (fotoğraflı gönderilerde metin boş olabilir).
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          // Fotoğraf varsa metnin altında büyük görsel olarak göster.
          if (post.imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(post.imagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
                // Bozuk/silinmiş dosyada çökmeyi önle.
                errorBuilder: (_, _, _) => Container(
                  height: 180,
                  color: AppColors.text.withValues(alpha: 0.05),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.text.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Alt satır: beğen ve yorum.
          Row(
            children: [
              _ActionButton(
                icon: post.liked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                // Beğenildiyse terracotta dolu kalp; değilse soluk metin rengi.
                color: post.liked
                    ? AppColors.terracotta
                    : AppColors.text.withValues(alpha: 0.6),
                onTap: onLike,
              ),
              const SizedBox(width: 20),
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: '${post.commentCount}',
                color: AppColors.text.withValues(alpha: 0.6),
                // Dokununca yorum panelini açar.
                onTap: onComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gönderiye bağlı evcil hayvan etiketi (örn. "🐾 Pamuk").
class _PetTag extends StatelessWidget {
  const _PetTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pets, size: 14, color: AppColors.forest),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.forest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Beğen/yorum gibi alt eylem butonu: ikon + sayı. [onTap] null ise pasiftir.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
