import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../state/auth_store.dart';
import 'appointment_screen.dart';
import 'clients_screen.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'lost_pet_screen.dart';
import 'passport_screen.dart';
import 'salon_appointments_screen.dart';
import 'salon_clients_screen.dart';

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
      // Randevu sekmesi: kuaför için detaylı salon randevuları, diğerleri için
      // standart randevu ekranı.
      role == UserRole.kuafor
          ? const SalonAppointmentsScreen()
          : const AppointmentScreen(),
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

  /// 1. sekmenin ekranı: sahip → Pasaport, kuaför → detaylı Müşteriler ekranı,
  /// veteriner → hasta listesi (mock verili [ClientsScreen]).
  Widget _firstTabScreen(UserRole role) {
    switch (role) {
      case UserRole.kuafor:
        return const SalonClientsScreen();
      case UserRole.veteriner:
        return ClientsScreen(role: role);
      case UserRole.kullanici:
        return const PassportScreen();
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
      case UserRole.kullanici:
        return const NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: 'Pasaport',
        );
    }
  }
}
