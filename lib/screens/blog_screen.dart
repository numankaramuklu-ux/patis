import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';
import '../widgets/blog_card.dart';
import 'blog_detail_screen.dart';

/// Blog ekranı (yol haritası #6).
///
/// Ana Sayfa'daki "Blog" kutusundan açılır. Yazılar şimdilik mock (sahte) ve
/// elle yazılı — ileride Firebase'den gerçek içeriklerle değiştireceğiz.
class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  // ---- Mock (sahte) yazılar ----
  // Ana ekrandaki "Senin için" bölümü de bu listeyi kullandığı için public.
  static const posts = <BlogPost>[
    BlogPost(
      title: 'Kedinizin tüy bakımı için 5 ipucu',
      category: BlogCategory.bakim,
      readMinutes: 4,
      excerpt:
          'Düzenli tarama hem tüy yumaklarını azaltır hem de kedinizle '
          'aranızdaki bağı güçlendirir. İşte evde uygulayabileceğiniz pratik '
          'öneriler.',
      body:
          'Düzenli tüy bakımı, kedinizin sağlığı için göründüğünden çok daha '
          'önemlidir. Taranan tüyler hem tüy yumağı oluşumunu azaltır hem de '
          'derinin nefes almasını sağlar.\n\n'
          '1. Haftada en az 2-3 kez yumuşak bir fırçayla tarayın. Uzun tüylü '
          'ırklarda bu sıklığı artırın.\n\n'
          '2. Tarama sırasında cildi kontrol edin; kızarıklık, pire ya da '
          'yara varsa veterinerinize danışın.\n\n'
          '3. Banyoyu abartmayın. Kediler kendilerini temizler; ayda birden '
          'sık banyo cildi kurutabilir.\n\n'
          '4. Tırnak bakımını ihmal etmeyin ve tüy bakımıyla aynı rutine '
          'ekleyin.\n\n'
          '5. Bakımı keyifli bir ana çevirin; ödül ve sevgiyle kedinizin bunu '
          'sevmesini sağlayın.',
    ),
    BlogPost(
      title: 'Köpeklerde aşı takvimi neden önemli?',
      category: BlogCategory.saglik,
      readMinutes: 6,
      excerpt:
          'Zamanında yapılan aşılar, köpeğinizi ölümcül hastalıklardan korur. '
          'Yavru ve yetişkin dönemde dikkat etmeniz gerekenleri derledik.',
      body:
          'Aşılar, köpeğinizin bağışıklık sistemini ciddi hastalıklara karşı '
          'hazırlar. Özellikle yavru dönemde takvime uymak hayati önem taşır.'
          '\n\n'
          'Karma aşı genellikle 6-8 haftalıkken başlar ve birkaç tekrarla '
          'sürer. Kuduz aşısı ise çoğu yerde yasal olarak zorunludur.\n\n'
          'Yetişkinlikte rapel (tekrar) aşıları unutmayın. Patiş\'te aşı '
          'kayıtlarınızı Dijital Pasaport bölümünden takip edebilir, sonraki '
          'tarihleri kaçırmazsınız.\n\n'
          'Her köpek farklıdır; kesin takvim için mutlaka veterinerinizle '
          'birlikte plan yapın.',
    ),
    BlogPost(
      title: 'Doğru mama seçimi: etikette nelere bakmalı?',
      category: BlogCategory.beslenme,
      readMinutes: 5,
      excerpt:
          'Mamanın içindekiler listesi, dostunuzun sağlığının anahtarıdır. '
          'İlk sıradaki malzemeden tahıl oranına kadar bilmeniz gerekenler.',
      body:
          'Kaliteli bir mama seçimi, evcil hayvanınızın uzun ve sağlıklı bir '
          'yaşam sürmesinin temelidir.\n\n'
          'İçindekiler listesinin ilk sırasında gerçek bir et kaynağı (tavuk, '
          'kuzu, somon vb.) olmasına dikkat edin.\n\n'
          'Yaşa uygun mama seçin: yavru, yetişkin ve yaşlı dönem ihtiyaçları '
          'farklıdır.\n\n'
          'Ani mama değişiklikleri sindirim sorunlarına yol açabilir; yeni '
          'mamaya 7-10 günde kademeli olarak geçin.',
    ),
    BlogPost(
      title: 'Yavru köpeğe tuvalet eğitimi',
      category: BlogCategory.egitim,
      readMinutes: 7,
      excerpt:
          'Sabır ve tutarlılıkla tuvalet eğitimi birkaç haftada tamamlanır. '
          'Ödül temelli, cezasız bir yöntemle adım adım anlattık.',
      body:
          'Tuvalet eğitimi, yeni bir yavruyla yaşamın en sık sorulan '
          'konularından biridir. İyi haber: tutarlılıkla kısa sürede sonuç '
          'alırsınız.\n\n'
          'Yavruyu düzenli aralıklarla (uyandığında, yemekten sonra, oyundan '
          'sonra) aynı noktaya götürün.\n\n'
          'Doğru yere yaptığında hemen ödüllendirin. Ödül zamanlaması, '
          'davranışı pekiştirmenin anahtarıdır.\n\n'
          'Kazalarda asla cezalandırmayın; bu yalnızca korku ve gizlenmeye yol '
          'açar. Sakince temizleyip rutine devam edin.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Patiş rehberi', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Dostun için faydalı bilgiler',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final post in posts) ...[
              BlogCard(
                post: post,
                // Karta dokununca o yazının detay ekranını aç.
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlogDetailScreen(post: post),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
