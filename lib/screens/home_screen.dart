import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/pet.dart';
import '../models/pet_service.dart';
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
/// Şimdilik tüm veriler "mock" (sahte, elle yazılmış) — ileride Firebase'den
/// gerçek veriyle değiştireceğiz. Bu ekranın işi: veriyi hazırlayıp
/// `lib/widgets` içindeki hazır parçaları sırayla dizmek.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  /// Alt menüde bir sekmeye geçmek için çağrılır (MainScaffold'dan gelir).
  /// Ana Sayfa'daki bazı kutular (Pasaport, Randevu, Kayıp, Topluluk) ayrı
  /// ekran açmak yerine ilgili sekmeye geçer; bunu bu geri-çağırımla yaparlar.
  final ValueChanged<int> onSelectTab;

  // ---- Mock (sahte) veriler ----
  // İleride bunlar Firebase'den gelecek; şimdilik tasarımı görmek için sabit.
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

  // Hizmet ızgarasındaki kutular. Bazı kutuların dokununca ekran açması (yani
  // `context`'e ihtiyacı) olduğundan liste artık `const` değil; `context` alan
  // bir metotla oluşturuluyor. Ekranı henüz hazır olmayan kutuların `onTap`'i
  // boş kalır → basıldığında bir şey yapmazlar.
  List<PetService> _services(BuildContext context) {
    return [
      PetService(
        icon: Icons.badge_outlined,
        label: 'Pasaport',
        color: AppColors.forest,
        // Pasaport bir alt menü sekmesi (index 1) → o sekmeye geç.
        onTap: () => onSelectTab(1),
      ),
      PetService(
        icon: Icons.event_outlined,
        label: 'Randevu',
        color: AppColors.gold,
        // Randevu sekmesi (index 2).
        onTap: () => onSelectTab(2),
      ),
      PetService(
        icon: Icons.favorite_outline,
        label: 'Sahiplendirme',
        color: AppColors.terracotta,
        // Bu kutuya basınca Sahiplendirme ekranını mevcut sayfanın üstüne aç.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdoptionScreen()),
        ),
      ),
      PetService(
        icon: Icons.handshake_outlined,
        label: 'Pet Sitter',
        color: AppColors.forest,
        // Bu kutuya basınca Pet Sitter ekranını üstüne aç.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetSitterScreen()),
        ),
      ),
      PetService(
        icon: Icons.location_on_outlined,
        label: 'Kayıp',
        color: AppColors.terracotta,
        // Kayıp sekmesi (index 3).
        onTap: () => onSelectTab(3),
      ),
      PetService(
        icon: Icons.article_outlined,
        label: 'Blog',
        color: AppColors.gold,
        // Blog'un alt menü sekmesi yok → ayrı ekran olarak üstüne aç.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BlogScreen()),
        ),
      ),
      PetService(
        icon: Icons.groups_outlined,
        label: 'Topluluk',
        color: AppColors.forest,
        // Topluluk sekmesi (index 4).
        onTap: () => onSelectTab(4),
      ),
      PetService(
        icon: Icons.notifications_outlined,
        label: 'Bildirim',
        color: AppColors.gold,
        // Okunmamış bildirim sayısını rozet olarak göster (depoyu DİNLE ki
        // okundu işaretlenince rozet anında güncellensin).
        badgeCount: context.watch<NotificationStore>().unreadCount,
        // Dokununca Bildirimler ekranını üstüne aç. Bildirime dokununca ilgili
        // sekmeye geçebilmesi için sekme değiştirme geri-çağırımını da veririz.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(onSelectTab: onSelectTab),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const _GreetingHeader(ownerName: 'Numan'),
          const SizedBox(height: 20),
          // Pamuk kartına dokununca Pasaport sekmesine (index 1) geç.
          PetCard(pet: _pet, onTap: () => onSelectTab(1)),
          const SizedBox(height: 28),
          const SectionTitle('Tüm hizmetler'),
          const SizedBox(height: 12),
          ServiceGrid(services: _services(context)),
          const SizedBox(height: 28),
          const SectionTitle('Yaklaşan randevu'),
          const SizedBox(height: 12),
          const AppointmentCard(appointment: _nextAppointment),
        ],
      ),
    );
  }
}

/// Üstteki karşılama bölümü: "Merhaba, [isim]". Ana Sayfa'ya özel olduğu için
/// ayrı bir widgets dosyasına taşımadık, burada private bıraktık.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.ownerName});

  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba, $ownerName 👋',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Bugün dostun için ne yapalım?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.text.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
