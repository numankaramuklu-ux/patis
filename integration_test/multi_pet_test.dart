// Emülatör/cihaz üstünde çalışan entegrasyon testi: çoklu evcil hayvan akışı.
//
// Kayıt (sahip) → Pasaport sekmesi → "Ekle" ile yeni dost → yeni dostun aktif
// olduğunu doğrular. Çalıştırmak için:
//   flutter test integration_test/multi_pet_test.dart -d <emülatör>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petapp/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Çoklu hayvan: yeni dost eklenir ve aktif olur',
      (WidgetTester tester) async {
    // Temiz başlangıç: kayıtlı oturum/hayvan olmasın.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await tester.pumpWidget(const PatisApp());
    await tester.pumpAndSettle();

    // ---- Kayıt (sahip rolü varsayılan seçili) ----
    await tester.enterText(
        find.widgetWithText(TextField, 'Ad Soyad'), 'Test Sahibi');
    await tester.enterText(
        find.widgetWithText(TextField, 'E-posta'), 'test@patis.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Şifre'), '123456');

    // Klavyeyi kapat; aksi halde alttaki "Kayıt ol" butonuna dokunuş ıskalıyor.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final kayitBtn = find.widgetWithText(FilledButton, 'Kayıt ol');
    await tester.ensureVisible(kayitBtn);
    await tester.pumpAndSettle();
    await tester.tap(kayitBtn);
    await tester.pumpAndSettle();

    // ---- Ana ekran geldi; Pasaport sekmesine geç ----
    // "Pasaport" metni hem alt menüde hem hizmet kutusunda var; dokunulabilir
    // ilkini hedefle (ikisi de Pasaport sekmesine götürür).
    await tester.tap(find.text('Pasaport').hitTestable().first);
    await tester.pumpAndSettle();

    // Başlangıçta varsayılan dost "Pamuk" görünür.
    expect(find.text('Pamuk'), findsWidgets);

    // ---- Hayvan seçicideki "Ekle" ile yeni dost formunu aç ----
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni dost ekle'), findsOneWidget);

    // Ad gir ve kaydet (formdaki "Ekle" düğmesi bir FilledButton).
    await tester.enterText(find.widgetWithText(TextField, 'Ad'), 'Minnoş');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final ekleBtn = find.widgetWithText(FilledButton, 'Ekle');
    await tester.ensureVisible(ekleBtn);
    await tester.pumpAndSettle();
    await tester.tap(ekleBtn);
    // SnackBar zamanlayıcısı da temizlensin diye zamanı ileri sar.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ---- Doğrulama: yeni dost "Minnoş" eklendi ve aktif (başlıkta görünür) ----
    expect(find.text('Minnoş'), findsWidgets);
  });
}
