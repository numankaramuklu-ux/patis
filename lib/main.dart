import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_scaffold.dart';
import 'state/appointment_store.dart';
import 'state/community_store.dart';
import 'state/lost_pet_store.dart';
import 'state/notification_store.dart';
import 'state/passport_store.dart';
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
        ChangeNotifierProvider(create: (_) => AppointmentStore()),
        ChangeNotifierProvider(create: (_) => LostPetStore()),
        ChangeNotifierProvider(create: (_) => CommunityStore()),
        ChangeNotifierProvider(create: (_) => PassportStore()),
        ChangeNotifierProvider(create: (_) => NotificationStore()),
      ],
      child: MaterialApp(
        title: 'Patiş',
        debugShowCheckedModeBanner: false, // sağ üstteki "DEBUG" şeridini gizler
        theme: AppTheme.light(),
        home: const MainScaffold(),
      ),
    );
  }
}
