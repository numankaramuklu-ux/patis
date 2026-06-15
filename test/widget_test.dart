// Patiş widget testleri.
//
// 1) Açılış akışı: oturum yokken kayıt ekranı gelir (auth gate).
// 2) Kuaför rolü: Randevular ekranından "Yeni randevu" ile bir randevu eklenir
//    ve depoya yazılır.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petapp/main.dart';
import 'package:petapp/screens/salon_appointments_screen.dart';
import 'package:petapp/state/salon_store.dart';

void main() {
  // Store'lar açılışta SharedPreferences okuyor; testte boş bir mock yeterli.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Oturum yokken açılışta kayıt ekranı gelir',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PatisApp());
    await tester.pumpAndSettle();

    // Auth gate giriş olmadığından RegisterScreen göstermeli (üstteki başlıklar).
    expect(find.text('Aramıza katıl'), findsOneWidget);
    expect(find.text('Hesap türü'), findsOneWidget);
  });

  testWidgets('Kuaför: yeni randevu eklenince depoya yazılır',
      (WidgetTester tester) async {
    final store = SalonStore();
    await tester.pumpWidget(
      ChangeNotifierProvider<SalonStore>.value(
        value: store,
        child: const MaterialApp(home: SalonAppointmentsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final before = store.appointments.length;

    // "Yeni randevu" butonuna (FAB) bas → form açılır.
    await tester.tap(find.text('Yeni randevu'));
    await tester.pumpAndSettle();
    expect(find.text('Randevu oluştur'), findsOneWidget);

    // Hizmet alanını doldur (kayıtlı müşteri varsayılan seçili gelir).
    await tester.enterText(
      find.widgetWithText(TextField, 'Hizmet'),
      'Test tıraşı',
    );

    // Tarih + saat seç (varsayılan bugün/şimdi; onay düğmeleri İngilizce: OK).
    await tester.tap(find.text('Tarih seç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Kaydet.
    await tester.tap(find.text('Randevu oluştur'));
    // SnackBar zamanlayıcısının da temizlenmesi için zamanı ileri sar.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Depoya bir randevu eklenmiş ve girilen hizmeti taşıyor olmalı.
    expect(store.appointments.length, before + 1);
    expect(
      store.appointments.any((a) => a.service == 'Test tıraşı'),
      isTrue,
    );
  });
}
