# 🐾 Patiş

Evcil hayvan bakımı + topluluk uygulaması. Hayvan sahiplerini, pet kuaförlerini
ve veterinerleri tek bir uygulamada buluşturur. Flutter ile geliştirilmektedir.

> Veriler şimdilik bellekte tutulan mock veriler; ileride Firebase'e bağlanacak.

## ✨ Özellikler

### Rol bazlı deneyim
Kayıt sırasında hesap türü seçilir; ana ekran ve alt menü role göre değişir:

- **🐾 Evcil hayvan sahibi** — dijital pasaport, randevu, sahiplendirme, pet
  sitter, kayıp ilanları, blog ve topluluk.
- **✂️ Pet kuaförü** — salon paneli: detaylı randevu yönetimi (onay/tamamla/iptal),
  arama destekli müşteri listesi ve müşteri detay kartları.
- **🩺 Veteriner** — klinik paneli: hasta listesi ve randevular.

### Öne çıkanlar
- **Dijital pasaport** — aşılar, alerjiler, ilaçlar, kilo takibi (grafik) ve
  galeriden seçilen profil fotoğrafı; QR ile paylaşım.
- **Salon randevuları** — durum filtreleri, güne göre gruplama, detay paneli ve
  canlı durum güncelleme.
- **Müşteri yönetimi** — özet istatistikler, arama, ziyaret geçmişi, harcama,
  tercih edilen hizmetler ve salon notları.
- **Topluluk** — gönderiler, yorumlar ve bildirim sistemi.
- **Kayıp / sahiplendirme / pet sitter** ilanları.

## 🛠 Teknolojiler

- **Flutter** (Dart, Material 3)
- **provider** — durum yönetimi (`ChangeNotifier` tabanlı store'lar)
- **google_fonts** — Fraunces (başlık) + Bricolage Grotesque (gövde)
- **fl_chart** — kilo takibi grafiği
- **qr_flutter** — pasaport QR paylaşımı
- **image_picker** — profil fotoğrafı seçimi

## 📁 Proje yapısı

```
lib/
├── main.dart            # Uygulama girişi, provider'lar, açılış (kayıt) ekranı
├── models/              # Veri sınıfları (Pet, SalonAppointment, SalonClient, ...)
├── state/               # ChangeNotifier store'lar (AuthStore, SalonStore, ...)
├── screens/             # Ekranlar (kayıt, ana sayfa, pasaport, salon, ...)
├── widgets/             # Yeniden kullanılan parçalar (kartlar, ızgara, ...)
└── theme/               # Renk paleti ve tema (AppColors, AppTheme)
```

## 🚀 Çalıştırma

Gereksinim: [Flutter SDK](https://docs.flutter.dev/get-started/install)

```bash
flutter pub get          # bağımlılıkları çek
flutter run              # bağlı cihaz/emülatörde çalıştır
```

Belirli bir cihazda çalıştırmak için:

```bash
flutter devices                      # cihazları listele
flutter run -d <device-id>           # örn. emulator-5554
```

## 📌 Yol haritası

- [ ] Firebase Auth ile gerçek kimlik doğrulama
- [ ] Verilerin Firestore'a taşınması
- [ ] Profil fotoğrafları için Firebase Storage
- [ ] Veteriner paneli için müşterilerdeki detay seviyesi
- [ ] Bildirimlerin push olarak gönderilmesi
