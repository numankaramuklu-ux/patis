// Patiş için basit bir "smoke test": uygulama hata vermeden açılıyor mu?
//
// Counter demosunun testini sildik; yerine ana iskeletin (5 sekme) doğru
// yüklendiğini doğrulayan küçük bir test koyduk.

import 'package:flutter_test/flutter_test.dart';

import 'package:petapp/main.dart';

void main() {
  testWidgets('Uygulama açılır ve Ana Sayfa sekmesi görünür',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PatisApp());
    await tester.pump();

    // Alt navigasyondaki "Ana Sayfa" etiketi ekranda olmalı.
    expect(find.text('Ana Sayfa'), findsOneWidget);
    // Karşılama metni de görünmeli.
    expect(find.textContaining('Merhaba'), findsOneWidget);
  });
}
