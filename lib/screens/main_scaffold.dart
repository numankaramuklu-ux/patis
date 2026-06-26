import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../services/reminder_service.dart';
import '../state/appointment_store.dart';
import '../state/auth_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import 'appointment_screen.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'lost_pet_screen.dart';
import 'passport_screen.dart';
import 'pet_sitter_dashboard_screen.dart';
import 'pet_walker_dashboard_screen.dart';
import 'salon_appointments_screen.dart';
import 'salon_clients_screen.dart';
import 'sitter_schedule_screen.dart';
import 'vet_appointments_screen.dart';
import 'vet_patients_screen.dart';
import 'walk_schedule_screen.dart';

/// Uygulamanın ana kabuğu: alttaki 5 sekmeli navigasyon çubuğu.
///
/// Hangi sekmenin seçili olduğunu hatırlaması gerektiği için (kullanıcı
/// sekmeye dokununca değişir) bu bir StatefulWidget. Seçili sekme indeksini
/// `_currentIndex` değişkeninde tutar.
///
/// Alt menü role göre değişir: indeksleri sabit tutmak için (Bildirimler ve
/// Ana Sayfa bu indekslere bağlı) yalnızca 1. sekme role göre farklılaşır —
/// sahip için Pasaport, kuaför için Müşteriler, veteriner için Hastalar.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Şu an açık olan sekmenin sırası (0 = Ana Sayfa).
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Oturum açıldığında yaklaşan aşı/randevular için bir kez hatırlatma üret.
    // Depoların `shared_preferences`'tan yüklenmesini beklemek için kısa bir
    // gecikme veriyoruz (aksi halde _load listeyi sıfırlayıp eklediğimiz
    // hatırlatmayı silebilir). Tekrarlar kalıcı anahtarlarla önlenir.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ReminderService.sync(
        passport: context.read<PassportStore>(),
        appointments: context.read<AppointmentStore>(),
        notifications: context.read<NotificationStore>(),
      );
    });
  }

  // Sekmeyi programatik olarak değiştirir. Ana Sayfa'daki hizmet kutularına
  // verip, kutuya basınca ilgili sekmeye geçmesini sağlıyoruz.
  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Rolü oku (kayıt yapılmadan girilirse sahip kabul edilir). Yalnızca
    // 1. sekme buna göre değişir.
    final role = context.watch<AuthStore>().role ?? UserRole.kullanici;

    // Her sekmeye karşılık gelen ekranlar. Sıra, alttaki butonların sırasıyla
    // birebir aynı olmalı. HomeScreen'e sekme değiştirme geri-çağırımı geçtiğimiz
    // için liste artık `build` içinde (const değil) oluşturuluyor.
    final screens = <Widget>[
      HomeScreen(onSelectTab: _selectTab),
      _firstTabScreen(role),
      // Randevu sekmesi role göre: kuaför salon randevuları, veteriner klinik
      // randevuları, sahip standart randevu ekranı.
      _appointmentsScreen(role),
      const LostPetScreen(),
      const CommunityScreen(),
    ];
    return Scaffold(
      // Seçili indekse göre ilgili ekranı göster.
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        // Bir sekmeye dokununca seçili indeksi güncelle ve ekranı yeniden çiz.
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          // 1. sekme role göre değişir.
          _firstTabDestination(role),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Randevu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Kayıp',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Topluluk',
          ),
        ],
      ),
    );
  }

  /// 1. sekmenin ekranı: sahip → Pasaport, kuaför → Müşteriler, veteriner →
  /// Hastalar (her ikisi de detaylı, mock verili ekranlar).
  Widget _firstTabScreen(UserRole role) {
    switch (role) {
      case UserRole.kuafor:
        return const SalonClientsScreen();
      case UserRole.veteriner:
        return const VetPatientsScreen();
      case UserRole.petSitter:
        return PetSitterDashboardScreen(onSelectTab: _selectTab);
      case UserRole.petWalker:
        return PetWalkerDashboardScreen(onSelectTab: _selectTab);
      case UserRole.kullanici:
        return const PassportScreen();
    }
  }

  /// Randevu sekmesinin ekranı, role göre.
  Widget _appointmentsScreen(UserRole role) {
    switch (role) {
      case UserRole.kuafor:
        return const SalonAppointmentsScreen();
      case UserRole.veteriner:
        return const VetAppointmentsScreen();
      case UserRole.petSitter:
        return const SitterScheduleScreen();
      case UserRole.petWalker:
        return const WalkScheduleScreen();
      case UserRole.kullanici:
        return const AppointmentScreen();
    }
  }

  /// 1. sekmenin alt menü butonu (ikon + etiket), role göre.
  NavigationDestination _firstTabDestination(UserRole role) {
    switch (role) {
      case UserRole.kuafor:
        return const NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: 'Müşteriler',
        );
      case UserRole.veteriner:
        return const NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'Hastalar',
        );
      case UserRole.petSitter:
        return const NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Rezervasyon',
        );
      case UserRole.petWalker:
        return const NavigationDestination(
          icon: Icon(Icons.directions_walk_outlined),
          selectedIcon: Icon(Icons.directions_walk),
          label: 'Yürüyüş',
        );
      case UserRole.kullanici:
        return const NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: 'Pasaport',
        );
    }
  }
}
