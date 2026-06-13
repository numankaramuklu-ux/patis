import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/pet.dart';
import '../models/pet_service.dart';
import '../models/user_role.dart';
import '../state/auth_store.dart';
import '../state/notification_store.dart';
import '../theme/app_colors.dart';
import '../widgets/appointment_card.dart';
import '../widgets/pet_card.dart';
import '../widgets/section_title.dart';
import '../widgets/service_grid.dart';
import 'adoption_screen.dart';
import 'blog_screen.dart';
import 'notifications_screen.dart';
import 'pet_sitter_screen.dart';

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

  // ---- Mock (sahte) veriler ----
  static const _pet = Pet(
    name: 'Pamuk',
    breed: 'British Shorthair',
    ageLabel: '2 yaşında',
  );

  static const _nextAppointment = Appointment(
    title: 'Aşı kontrolü',
    place: 'Patiş Veteriner Kliniği',
    dateLabel: '12 Haziran, 14:30',
  );

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
    return [
      _GreetingHeader(
        title: 'Merhaba, $name 👋',
        subtitle: 'Bugün dostun için ne yapalım?',
      ),
      const SizedBox(height: 20),
      // Pamuk kartına dokununca Pasaport sekmesine (index 1) geç.
      PetCard(pet: _pet, onTap: () => onSelectTab(1)),
      const SizedBox(height: 28),
      const SectionTitle('Tüm hizmetler'),
      const SizedBox(height: 12),
      ServiceGrid(services: _ownerServices(context)),
      const SizedBox(height: 28),
      const SectionTitle('Yaklaşan randevu'),
      const SizedBox(height: 12),
      const AppointmentCard(appointment: _nextAppointment),
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
    final businessName = auth.businessName ?? auth.name ?? role.label;
    return [
      _GreetingHeader(
        title: 'Merhaba, $businessName ${isVet ? '🩺' : '✂️'}',
        subtitle: isVet
            ? 'Bugünkü hastaların hazır'
            : 'Bugünkü randevuların hazır',
      ),
      const SizedBox(height: 20),
      _BusinessSummaryCard(role: role),
      const SizedBox(height: 28),
      SectionTitle(isVet ? 'Klinik araçları' : 'Salon araçları'),
      const SizedBox(height: 12),
      ServiceGrid(services: _businessServices(context, role)),
      const SizedBox(height: 28),
      const SectionTitle('Bugünkü randevular'),
      const SizedBox(height: 12),
      for (final appt in _todaysAppointments(role)) ...[
        AppointmentCard(appointment: appt),
        const SizedBox(height: 12),
      ],
    ];
  }

  /// İşletme rollerine özel hizmet kutuları (role göre etiketler değişir).
  List<PetService> _businessServices(BuildContext context, UserRole role) {
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
        onTap: () => _soon(context),
      ),
      PetService(
        icon: isVet
            ? Icons.receipt_long_outlined
            : Icons.price_change_outlined,
        label: isVet ? 'Reçeteler' : 'Fiyat listesi',
        color: AppColors.gold,
        onTap: () => _soon(context),
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

  /// İşletmenin bugünkü müşteri randevuları (mock).
  List<Appointment> _todaysAppointments(UserRole role) {
    if (role == UserRole.veteriner) {
      return const [
        Appointment(
          title: 'Boncuk — Aşı',
          place: 'Sahibi: Zeynep A.',
          dateLabel: '10:00',
        ),
        Appointment(
          title: 'Max — Genel kontrol',
          place: 'Sahibi: Can D.',
          dateLabel: '14:30',
        ),
      ];
    }
    return const [
      Appointment(
        title: 'Pamuk — Tıraş & banyo',
        place: 'Sahibi: Ayşe Y.',
        dateLabel: '11:00',
        type: AppointmentType.kuafor,
      ),
      Appointment(
        title: 'Karamel — Tırnak kesimi',
        place: 'Sahibi: Mert K.',
        dateLabel: '13:30',
        type: AppointmentType.kuafor,
      ),
    ];
  }

  /// Henüz hazır olmayan işletme ekranları için kısa "yakında" geri bildirimi.
  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında 🐾')),
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

/// İşletme rollerinin ana ekranındaki özet kartı (forest zeminli).
///
/// Rol etiketi + günün özet sayıları (bugünkü randevu, bekleyen talep). Sayılar
/// şimdilik mock; ileride [AppointmentStore]'dan türetilecek.
class _BusinessSummaryCard extends StatelessWidget {
  const _BusinessSummaryCard({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVet = role == UserRole.veteriner;
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
                value: isVet ? '8' : '5',
                label: isVet ? 'bugünkü hasta' : 'bugünkü randevu',
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.cream.withValues(alpha: 0.2),
              ),
              _Stat(
                value: isVet ? '3' : '2',
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
