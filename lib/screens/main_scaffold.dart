import 'package:flutter/material.dart';

import 'appointment_screen.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'lost_pet_screen.dart';
import 'passport_screen.dart';

/// Uygulamanın ana kabuğu: alttaki 5 sekmeli navigasyon çubuğu.
///
/// Hangi sekmenin seçili olduğunu hatırlaması gerektiği için (kullanıcı
/// sekmeye dokununca değişir) bu bir StatefulWidget. Seçili sekme indeksini
/// `_currentIndex` değişkeninde tutar.
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
    // Her sekmeye karşılık gelen ekranlar. Sıra, alttaki butonların sırasıyla
    // birebir aynı olmalı. HomeScreen'e sekme değiştirme geri-çağırımı geçtiğimiz
    // için liste artık `build` içinde (const değil) oluşturuluyor.
    final screens = <Widget>[
      HomeScreen(onSelectTab: _selectTab),
      const PassportScreen(),
      const AppointmentScreen(),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Pasaport',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Randevu',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Kayıp',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Topluluk',
          ),
        ],
      ),
    );
  }
}
