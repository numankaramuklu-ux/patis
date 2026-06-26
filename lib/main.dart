import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_scaffold.dart';
import 'screens/register_screen.dart';
import 'state/adoption_store.dart';
import 'state/appointment_store.dart';
import 'state/auth_store.dart';
import 'state/community_store.dart';
import 'state/lost_pet_store.dart';
import 'state/notification_store.dart';
import 'state/passport_store.dart';
import 'state/pet_sitter_store.dart';
import 'state/salon_store.dart';
import 'state/sitter_booking_store.dart';
import 'state/sitter_profile_store.dart';
import 'state/sitter_review_store.dart';
import 'state/walk_store.dart';
import 'state/vet_store.dart';
import 'theme/app_theme.dart';

/// Uygulamanın başlangıç noktası. Flutter buradan çalışmaya başlar.
void main() {
  runApp(const PatisApp());
}

/// Patiş uygulamasının kök (root) widget'ı.
///
/// `MaterialApp` tüm uygulamayı sarar: temayı, başlığı ve açılış ekranını
/// burada belirleriz.
class PatisApp extends StatelessWidget {
  const PatisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider, birden çok depoyu (store) widget ağacının tepesine koyar;
    // altındaki tüm ekranlar `context.watch`/`context.read` ile bunlara
    // erişebilir. Yeni bir özellik state'i gerekince buraya bir satır ekleriz.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ChangeNotifierProvider(create: (_) => AppointmentStore()),
        ChangeNotifierProvider(create: (_) => LostPetStore()),
        ChangeNotifierProvider(create: (_) => CommunityStore()),
        ChangeNotifierProvider(create: (_) => PassportStore()),
        ChangeNotifierProvider(create: (_) => NotificationStore()),
        ChangeNotifierProvider(create: (_) => SalonStore()),
        ChangeNotifierProvider(create: (_) => VetStore()),
        ChangeNotifierProvider(create: (_) => AdoptionStore()),
        ChangeNotifierProvider(create: (_) => PetSitterStore()),
        ChangeNotifierProvider(create: (_) => SitterBookingStore()),
        ChangeNotifierProvider(create: (_) => SitterProfileStore()),
        ChangeNotifierProvider(create: (_) => SitterReviewStore()),
        ChangeNotifierProvider(create: (_) => WalkStore()),
      ],
      child: MaterialApp(
        title: 'Patiş',
        debugShowCheckedModeBanner:
            false, // sağ üstteki "DEBUG" şeridini gizler
        theme: AppTheme.light(),
        // Açılış kapısı: oturum yoksa kayıt/giriş, varsa ana ekran gösterilir.
        home: const AuthGate(),
      ),
    );
  }
}

/// Oturum durumuna göre doğru ekranı gösteren "kapı".
///
/// [AuthStore]'u dinler: kayıtlı oturum diskten yüklenene kadar bir açılış
/// (splash) ekranı; ardından kullanıcı giriş yapmadıysa kayıt ekranını,
/// giriş/kayıt tamamlanınca ana ekranı (MainScaffold) gösterir. Çıkış
/// yapılınca otomatik olarak yeniden kayıt ekranına döner — ekranlar arası
/// elle yönlendirme yapmaya gerek kalmaz.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    if (!auth.isReady) return const _SplashScreen();
    return auth.isLoggedIn ? const MainScaffold() : const RegisterScreen();
  }
}

/// Kayıtlı oturum diskten okunurken gösterilen kısa açılış ekranı.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Icon(Icons.pets, size: 56)));
  }
}
