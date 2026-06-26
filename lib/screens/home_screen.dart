import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/blog_post.dart';
import '../models/pet_service.dart';
import '../models/user_role.dart';
import '../state/appointment_store.dart';
import '../state/auth_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import '../state/salon_store.dart';
import '../state/sitter_booking_store.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_card.dart';
import '../widgets/salon_appointment_card.dart';
import '../widgets/section_title.dart';
import '../widgets/service_grid.dart';
import '../widgets/sitter_booking_card.dart';
import '../widgets/vet_appointment_card.dart';
import 'pet_sitter_dashboard_screen.dart';
import 'adoption_screen.dart';
import 'blog_detail_screen.dart';
import 'blog_screen.dart';
import 'notifications_screen.dart';
import 'pet_sitter_screen.dart';
import 'profile_screen.dart';
import 'salon_services_screen.dart';
import 'vet_prescriptions_screen.dart';
import 'vet_vaccine_schedule_screen.dart';

/// Uygulamanın açılış (Ana Sayfa) ekranı.
///
/// Artık kayıt sırasında seçilen role göre farklı bir içerik gösterir:
/// - Evcil hayvan sahibi: kendi dostunun kartı + tüketici hizmetleri.
/// - Pet kuaförü / Veteriner: işletme özeti + işletme hizmetleri + günün
///   müşteri randevuları.
/// Veriler şimdilik "mock" (sahte); ileride Firebase'den gelecek.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  /// Alt menüde bir sekmeye geçmek için çağrılır (MainScaffold'dan gelir).
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    // Rolü oku: kayıt yapılmadan girilirse (giriş kısa yolu) sahip kabul et.
    final auth = context.watch<AuthStore>();
    final role = auth.role ?? UserRole.kullanici;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: role == UserRole.kullanici
            ? _ownerBody(context, auth)
            : _businessBody(context, auth, role),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EVCİL HAYVAN SAHİBİ ana ekranı
  // ---------------------------------------------------------------------------
  List<Widget> _ownerBody(BuildContext context, AuthStore auth) {
    final name = auth.name?.split(' ').first ?? 'dostum';
    // Pasaport verisini DİNLE: sağlık özeti ve hatırlatıcılar buradan beslenir;
    // aşı eklenince / fotoğraf seçilince ana ekran da güncellenir.
    final passport = context.watch<PassportStore>();
    final unread = context.watch<NotificationStore>().unreadCount;

    final lastWeight =
        passport.weights.isNotEmpty ? passport.weights.last.kg : null;
    // Sonraki dozu olan ilk aşı (varsa) — hatırlatıcıda gösterilir.
    final upcomingVaccines =
        passport.vaccinations.where((v) => v.nextDueLabel != null).toList();
    final nextVacc = upcomingVaccines.isNotEmpty ? upcomingVaccines.first : null;
    // Aktif hayvanın ilk randevusu (varsa) — "Yaklaşanlar"da gösterilir.
    final petAppts =
        context.watch<AppointmentStore>().appointmentsFor(passport.selectedId);
    final nextAppt = petAppts.isNotEmpty ? petAppts.first : null;

    return [
      // Başlık + bildirim zili.
      Row(
        children: [
          Expanded(
            child: _GreetingHeader(
              title: 'Merhaba, $name 👋',
              subtitle: 'Bugün ${passport.pet.name} için ne yapalım?',
            ),
          ),
          _NotificationBell(
            count: unread,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(onSelectTab: onSelectTab),
              ),
            ),
          ),
          const _ProfileButton(),
        ],
      ),
      const SizedBox(height: 20),
      // Pet kartı — pasaport künyesi + fotoğrafıyla. Dokununca Pasaport'a geç.
      PetCard(
        pet: passport.pet,
        photoPath: passport.photoPath,
        onTap: () => onSelectTab(1),
      ),
      const SizedBox(height: 16),
      // Sağlık özeti (pasaporttan canlı).
      _HealthSummaryCard(
        weightLabel: lastWeight != null ? '$lastWeight kg' : '—',
        vaccineCount: passport.vaccinations.length,
        allergyCount: passport.allergies.length,
        onTap: () => onSelectTab(1),
      ),
      const SizedBox(height: 28),

      // Yaklaşanlar: aktif hayvanın randevusu + sıradaki aşısı. İkisi de yoksa
      // bölüm hiç gösterilmez (örn. yeni eklenen, kaydı boş bir dost).
      if (nextAppt != null || nextVacc != null) ...[
        const SectionTitle('Yaklaşanlar'),
        const SizedBox(height: 12),
        if (nextAppt != null)
          _ReminderCard(
            icon: Icons.event_outlined,
            accent: AppColors.gold,
            title: nextAppt.title,
            subtitle: nextAppt.place,
            trailing: nextAppt.dateLabel,
            onTap: () => onSelectTab(2),
          ),
        if (nextAppt != null && nextVacc != null) const SizedBox(height: 12),
        if (nextVacc != null)
          _ReminderCard(
            icon: Icons.vaccines_outlined,
            accent: AppColors.forest,
            title: '${nextVacc.name} aşısı',
            subtitle: 'Sıradaki doz',
            trailing: nextVacc.nextDueLabel!,
            onTap: () => onSelectTab(1),
          ),
        const SizedBox(height: 28),
      ],

      const SectionTitle('Tüm hizmetler'),
      const SizedBox(height: 12),
      ServiceGrid(services: _ownerServices(context)),
      const SizedBox(height: 28),

      // Senin için: blog ipuçları (yatay).
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SectionTitle('Senin için'),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BlogScreen()),
            ),
            child: const Text('Tümü'),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _BlogStrip(
        posts: BlogScreen.posts.take(3).toList(),
        onOpen: (post) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BlogDetailScreen(post: post)),
        ),
      ),
    ];
  }

  /// Hayvan sahibinin gördüğü hizmet kutuları.
  List<PetService> _ownerServices(BuildContext context) {
    return [
      PetService(
        icon: Icons.badge_outlined,
        label: 'Pasaport',
        color: AppColors.forest,
        onTap: () => onSelectTab(1),
      ),
      PetService(
        icon: Icons.event_outlined,
        label: 'Randevu',
        color: AppColors.gold,
        onTap: () => onSelectTab(2),
      ),
      PetService(
        icon: Icons.favorite_outline,
        label: 'Sahiplendirme',
        color: AppColors.terracotta,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdoptionScreen()),
        ),
      ),
      PetService(
        icon: Icons.handshake_outlined,
        label: 'Pet Sitter',
        color: AppColors.forest,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetSitterScreen()),
        ),
      ),
      PetService(
        icon: Icons.location_on_outlined,
        label: 'Kayıp',
        color: AppColors.terracotta,
        onTap: () => onSelectTab(3),
      ),
      PetService(
        icon: Icons.article_outlined,
        label: 'Blog',
        color: AppColors.gold,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BlogScreen()),
        ),
      ),
      PetService(
        icon: Icons.groups_outlined,
        label: 'Topluluk',
        color: AppColors.forest,
        onTap: () => onSelectTab(4),
      ),
      PetService(
        icon: Icons.notifications_outlined,
        label: 'Bildirim',
        color: AppColors.gold,
        badgeCount: context.watch<NotificationStore>().unreadCount,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(onSelectTab: onSelectTab),
          ),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // İŞLETME (Pet kuaförü / Veteriner) ana ekranı
  // ---------------------------------------------------------------------------
  List<Widget> _businessBody(
    BuildContext context,
    AuthStore auth,
    UserRole role,
  ) {
    final isVet = role == UserRole.veteriner;
    final isSitter = role == UserRole.petSitter;
    final businessName = auth.businessName ?? auth.name ?? role.label;
    // Özet sayılar ve günün kayıtları role göre ilgili depodan canlı gelir.
    final salon = role == UserRole.kuafor ? context.watch<SalonStore>() : null;
    final vet = isVet ? context.watch<VetStore>() : null;
    final sitter = isSitter ? context.watch<SitterBookingStore>() : null;
    // Sitter için "bugünkü" değer aktif konaklama sayısıdır.
    final todayValue =
        sitter?.activeCount ?? salon?.todayCount ?? vet?.todayCount ?? 0;
    final pendingValue =
        sitter?.pendingCount ?? salon?.pendingCount ?? vet?.pendingCount ?? 0;

    // Role göre selamlama emojisi ve alt başlık.
    final emoji = isVet ? '🩺' : (isSitter ? '🏠' : '✂️');
    final subtitle = isVet
        ? 'Bugünkü hastaların hazır'
        : (isSitter
            ? 'Konaklama taleplerin hazır'
            : 'Bugünkü randevuların hazır');
    final toolsTitle = isVet
        ? 'Klinik araçları'
        : (isSitter ? 'Sitter araçları' : 'Salon araçları');
    return [
      Row(
        children: [
          Expanded(
            child: _GreetingHeader(
              title: 'Merhaba, $businessName $emoji',
              subtitle: subtitle,
            ),
          ),
          const _ProfileButton(),
        ],
      ),
      const SizedBox(height: 20),
      _BusinessSummaryCard(
        role: role,
        todayValue: '$todayValue',
        pendingValue: '$pendingValue',
      ),
      const SizedBox(height: 28),
      SectionTitle(toolsTitle),
      const SizedBox(height: 12),
      ServiceGrid(services: _businessServices(context, role)),
      const SizedBox(height: 28),
      // Başlık + "Tümü" kısayolu (Randevu/Takvim sekmesine geçer).
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SectionTitle(isSitter ? 'Bugünkü konaklamalar' : 'Bugünkü randevular'),
          TextButton(
            onPressed: () => onSelectTab(2),
            child: const Text('Tümü'),
          ),
        ],
      ),
      const SizedBox(height: 4),
      // Günün kayıt kartları (dokununca ilgili sekmeye/panele geçer).
      if (salon != null)
        for (final appt in salon.todays) ...[
          SalonAppointmentCard(
            appointment: appt,
            onTap: () => onSelectTab(2),
          ),
          const SizedBox(height: 12),
        ],
      if (vet != null)
        for (final appt in vet.todays) ...[
          VetAppointmentCard(
            appointment: appt,
            onTap: () => onSelectTab(2),
          ),
          const SizedBox(height: 12),
        ],
      if (sitter != null) ...[
        if (sitter.todayCheckIns.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Bugün giriş yapan konaklama yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
            ),
          )
        else
          for (final b in sitter.todayCheckIns) ...[
            SitterBookingCard(
              booking: b,
              onTap: () => SitterBookingDetailSheet.show(context, b),
            ),
            const SizedBox(height: 12),
          ],
      ],
    ];
  }

  /// İşletme rollerine özel hizmet kutuları (role göre etiketler değişir).
  List<PetService> _businessServices(BuildContext context, UserRole role) {
    // Pet sitter'ın araç kutuları konaklama odaklı.
    if (role == UserRole.petSitter) {
      return [
        PetService(
          icon: Icons.event_note_outlined,
          label: 'Rezervasyonlar',
          color: AppColors.gold,
          onTap: () => onSelectTab(1),
        ),
        PetService(
          icon: Icons.calendar_month_outlined,
          label: 'Takvim',
          color: AppColors.forest,
          onTap: () => onSelectTab(2),
        ),
        PetService(
          icon: Icons.groups_outlined,
          label: 'Topluluk',
          color: AppColors.terracotta,
          onTap: () => onSelectTab(4),
        ),
        PetService(
          icon: Icons.article_outlined,
          label: 'Blog',
          color: AppColors.gold,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BlogScreen()),
          ),
        ),
        PetService(
          icon: Icons.notifications_outlined,
          label: 'Bildirim',
          color: AppColors.terracotta,
          badgeCount: context.watch<NotificationStore>().unreadCount,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NotificationsScreen(onSelectTab: onSelectTab),
            ),
          ),
        ),
      ];
    }
    final isVet = role == UserRole.veteriner;
    return [
      PetService(
        icon: Icons.event_available_outlined,
        label: 'Randevular',
        color: AppColors.gold,
        onTap: () => onSelectTab(2),
      ),
      PetService(
        icon: isVet ? Icons.pets_outlined : Icons.people_alt_outlined,
        label: isVet ? 'Hastalarım' : 'Müşterilerim',
        color: AppColors.forest,
        // Müşteri/Hasta listesi artık 1. sekme → o sekmeye geç.
        onTap: () => onSelectTab(1),
      ),
      PetService(
        icon: isVet ? Icons.vaccines_outlined : Icons.content_cut,
        label: isVet ? 'Aşı takvimi' : 'Hizmetlerim',
        color: AppColors.terracotta,
        // Kuaför: hizmet & fiyat listesi. Veteriner: klinik aşı takvimi.
        onTap: isVet
            ? () => _openVaccineSchedule(context)
            : () => _openSalonServices(context),
      ),
      PetService(
        icon: isVet
            ? Icons.receipt_long_outlined
            : Icons.price_change_outlined,
        label: isVet ? 'Reçeteler' : 'Fiyat listesi',
        color: AppColors.gold,
        // Veteriner: klinik geneli reçeteler. Kuaför: fiyat listesi (aynı
        // hizmet ekranını açar, fiyatlar orada).
        onTap: isVet
            ? () => _openPrescriptions(context)
            : () => _openSalonServices(context),
      ),
      PetService(
        icon: Icons.groups_outlined,
        label: 'Topluluk',
        color: AppColors.forest,
        onTap: () => onSelectTab(4),
      ),
      PetService(
        icon: Icons.article_outlined,
        label: 'Blog',
        color: AppColors.gold,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BlogScreen()),
        ),
      ),
      PetService(
        icon: Icons.notifications_outlined,
        label: 'Bildirim',
        color: AppColors.terracotta,
        badgeCount: context.watch<NotificationStore>().unreadCount,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(onSelectTab: onSelectTab),
          ),
        ),
      ),
    ];
  }

  /// Kuaförün hizmet & fiyat listesi ekranını açar.
  void _openSalonServices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalonServicesScreen()),
    );
  }

  /// Veterinerin klinik aşı takvimi ekranını açar.
  void _openVaccineSchedule(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VetVaccineScheduleScreen()),
    );
  }

  /// Veterinerin klinik geneli reçeteler ekranını açar.
  void _openPrescriptions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VetPrescriptionsScreen()),
    );
  }
}

/// Üstteki karşılama bölümü: başlık + alt açıklama. İçeriği role göre değiştiği
/// için artık metinleri dışarıdan alır.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.text.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Başlıktaki profil düğmesi — dokununca hesap (profil) ekranını açar.
class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Hesabım',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.forest.withValues(alpha: 0.12),
        child: const Icon(Icons.person_outline, color: AppColors.forest),
      ),
    );
  }
}

/// Başlıktaki bildirim zili — okunmamış sayısını rozet olarak gösterir.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.text,
          tooltip: 'Bildirimler',
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.cream, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Dostun sağlık özeti (forest zeminli): kilo, aşı kaydı ve alerji sayısı.
/// Pasaport verisinden beslenir; dokununca Pasaport sekmesine geçer.
class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({
    required this.weightLabel,
    required this.vaccineCount,
    required this.allergyCount,
    required this.onTap,
  });

  final String weightLabel;
  final int vaccineCount;
  final int allergyCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.forest,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_outline,
                      color: AppColors.cream.withValues(alpha: 0.9), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sağlık özeti',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      color: AppColors.cream.withValues(alpha: 0.7)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MiniStat(value: weightLabel, label: 'güncel kilo'),
                  _miniDivider(),
                  _MiniStat(value: '$vaccineCount', label: 'aşı kaydı'),
                  _miniDivider(),
                  _MiniStat(value: '$allergyCount', label: 'alerji'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniDivider() => Container(
        width: 1,
        height: 30,
        color: AppColors.cream.withValues(alpha: 0.2),
      );
}

/// Sağlık özeti kartındaki tek bir istatistik (büyük değer + küçük etiket).
class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Yaklaşanlar" bölümündeki tek bir hatırlatıcı kartı (randevu / aşı).
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailing,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Senin için" bölümündeki yatay blog ipucu şeridi.
class _BlogStrip extends StatelessWidget {
  const _BlogStrip({required this.posts, required this.onOpen});

  final List<BlogPost> posts;
  final ValueChanged<BlogPost> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _BlogMiniCard(
          post: posts[i],
          onTap: () => onOpen(posts[i]),
        ),
      ),
    );
  }
}

/// Yatay şeritteki tek bir blog yazısı kartı.
class _BlogMiniCard extends StatelessWidget {
  const _BlogMiniCard({required this.post, required this.onTap});

  final BlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = post.category;
    return SizedBox(
      width: 220,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori etiketi.
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14, color: cat.color),
                      const SizedBox(width: 4),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: cat.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    post.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14,
                        color: AppColors.text.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${post.readMinutes} dk okuma',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İşletme rollerinin ana ekranındaki özet kartı (forest zeminli).
///
/// Rol etiketi + günün özet sayıları (bugünkü randevu, bekleyen talep). Sayılar
/// şimdilik mock; ileride [AppointmentStore]'dan türetilecek.
class _BusinessSummaryCard extends StatelessWidget {
  const _BusinessSummaryCard({
    required this.role,
    required this.todayValue,
    required this.pendingValue,
  });

  final UserRole role;

  /// Bugünkü randevu/hasta sayısı (özet için, dışarıdan verilir).
  final String todayValue;

  /// Onay bekleyen talep sayısı.
  final String pendingValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVet = role == UserRole.veteriner;
    final isSitter = role == UserRole.petSitter;
    final todayLabel = isVet
        ? 'bugünkü hasta'
        : (isSitter ? 'aktif konaklama' : 'bugünkü randevu');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(role.icon, color: AppColors.cream, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                role.label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _Stat(
                value: todayValue,
                label: todayLabel,
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.cream.withValues(alpha: 0.2),
              ),
              _Stat(
                value: pendingValue,
                label: 'bekleyen talep',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// İşletme özet kartındaki tek bir istatistik sütunu (büyük sayı + etiket).
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
