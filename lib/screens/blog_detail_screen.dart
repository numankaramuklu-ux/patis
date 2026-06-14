import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';
import 'blog_screen.dart';

/// Tek bir blog yazısının tam metnini gösteren ekran (yol haritası #6).
///
/// Blog listesindeki bir karta dokununca açılır. Artık bir makale gibi
/// detaylı: okuma ilerleme çubuğu, kapak banner'ı, yazar bilgisi, giriş
/// paragrafı vurgusu, etiketler, geri bildirim ve ilgili yazılar.
class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key, required this.post});

  final BlogPost post;

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _scrollController = ScrollController();

  // Üstteki ince çubuğu doldurmak için okuma ilerlemesi (0..1).
  double _progress = 0;
  // App bar'daki kaydet (bookmark) durumu.
  bool _saved = false;
  // Alttaki geri bildirim: null = seçilmedi, true = faydalı, false = değil.
  bool? _helpful;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    setState(() {
      _progress = max > 0 ? (_scrollController.offset / max).clamp(0.0, 1.0) : 0;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  BlogPost get _post => widget.post;

  /// Aynı kategoriden (kendisi hariç) en fazla 2 ilgili yazı; yetmezse diğer
  /// kategorilerden tamamlanır.
  List<BlogPost> get _related {
    final others =
        BlogScreen.posts.where((p) => p.title != _post.title).toList();
    final sameCat =
        others.where((p) => p.category == _post.category).toList();
    final rest = others.where((p) => p.category != _post.category).toList();
    return [...sameCat, ...rest].take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _post.category.color;
    final paragraphs = _post.body.split('\n\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(_post.category.label),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _saved = !_saved);
              _snack(_saved ? 'Yazı kaydedildi' : 'Kayıt kaldırıldı');
            },
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'Kaydet',
          ),
          IconButton(
            onPressed: () => _snack('Paylaşım bağlantısı kopyalandı'),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Paylaş',
          ),
        ],
        // Okuma ilerleme çubuğu (app bar'ın altında ince şerit).
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 3,
            backgroundColor: AppColors.text.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          children: [
            // ---- Kapak banner'ı ----
            _CoverBanner(category: _post.category),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori + okuma süresi.
                  Row(
                    children: [
                      Icon(_post.category.icon, size: 16, color: accent),
                      const SizedBox(width: 5),
                      Text(
                        _post.category.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule,
                          size: 15,
                          color: AppColors.text.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        '${_post.readMinutes} dk okuma',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_post.title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 16),

                  // ---- Yazar satırı ----
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.forest,
                        child: const Icon(Icons.pets,
                            color: AppColors.cream, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patiş Editör',
                              style: theme.textTheme.titleSmall),
                          Text(
                            'Haziran 2026',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.text.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // ---- Gövde: ilk paragraf "giriş" olarak vurgulu ----
                  for (var i = 0; i < paragraphs.length; i++) ...[
                    Text(
                      paragraphs[i],
                      style: i == 0
                          ? theme.textTheme.titleMedium?.copyWith(
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            )
                          : theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: AppColors.text.withValues(alpha: 0.85),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ---- Etiketler ----
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _tagsFor(_post.category))
                        _TagChip(label: tag),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ---- Geri bildirim ----
                  _FeedbackBox(
                    helpful: _helpful,
                    onSelect: (value) {
                      setState(() => _helpful = value);
                      _snack(value
                          ? 'Geri bildirimin için teşekkürler! 🐾'
                          : 'Geri bildirimin için teşekkürler');
                    },
                  ),

                  // ---- İlgili yazılar ----
                  if (_related.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('İlgili yazılar', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final related in _related) ...[
                      _RelatedCard(
                        post: related,
                        // Yeni detay ekranı aç (geri tuşuyla bu yazıya dönülür).
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlogDetailScreen(post: related),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategoriye göre yazı etiketleri (mock).
  static List<String> _tagsFor(BlogCategory category) {
    switch (category) {
      case BlogCategory.bakim:
        return ['tüy bakımı', 'tarama', 'hijyen'];
      case BlogCategory.saglik:
        return ['aşı', 'koruyucu sağlık', 'veteriner'];
      case BlogCategory.beslenme:
        return ['mama', 'beslenme', 'kilo'];
      case BlogCategory.egitim:
        return ['eğitim', 'davranış', 'ödül'];
    }
  }
}

/// Yazının üstündeki kapak banner'ı — kategori renginde gradient + büyük ikon.
class _CoverBanner extends StatelessWidget {
  const _CoverBanner({required this.category});

  final BlogCategory category;

  @override
  Widget build(BuildContext context) {
    final accent = category.color;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.65)],
        ),
      ),
      child: Center(
        child: Icon(
          category.icon,
          size: 72,
          color: AppColors.cream.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Yazı sonundaki etiket çipi.
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          color: AppColors.text.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// "Bu yazı faydalı oldu mu?" geri bildirim kutusu.
class _FeedbackBox extends StatelessWidget {
  const _FeedbackBox({required this.helpful, required this.onSelect});

  /// Seçili geri bildirim: null = seçilmedi, true = evet, false = hayır.
  final bool? helpful;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text('Bu yazı faydalı oldu mu?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _VoteButton(
                icon: Icons.thumb_up_outlined,
                label: 'Evet',
                selected: helpful == true,
                color: AppColors.forest,
                onTap: () => onSelect(true),
              ),
              const SizedBox(width: 12),
              _VoteButton(
                icon: Icons.thumb_down_outlined,
                label: 'Hayır',
                selected: helpful == false,
                color: AppColors.terracotta,
                onTap: () => onSelect(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Geri bildirim kutusundaki tek bir oy butonu.
class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18, color: selected ? AppColors.cream : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.cream : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// İlgili yazılar bölümündeki kompakt kart.
class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.post, required this.onTap});

  final BlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = post.category.color;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(post.category.icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.category.label} • ${post.readMinutes} dk',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.text),
            ],
          ),
        ),
      ),
    );
  }
}
