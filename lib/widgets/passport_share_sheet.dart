import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/pet.dart';
import '../models/vaccination.dart';
import '../theme/app_colors.dart';

/// Pasaport bilgilerini bir QR kod olarak gösteren, alttan açılan panel.
///
/// Amaç: veteriner, kuaför ya da pet sitter gibi birine hayvanın özet
/// bilgilerini hızlıca göstermek. Karşı taraf QR'ı telefon kamerasıyla
/// okutunca aşağıdaki metni görür. Şimdilik QR içeriği düz metin; ileride
/// (Firebase'e geçince) paylaşılabilir bir web bağlantısına çevirebiliriz.
///
/// Bu widget'ı doğrudan kullanmak yerine [PassportShareSheet.show] ile
/// açıyoruz; o metot Flutter'ın standart `showModalBottomSheet` çağrısını
/// bizim için sarmalar.
class PassportShareSheet extends StatelessWidget {
  const PassportShareSheet({
    super.key,
    required this.pet,
    required this.vaccinations,
  });

  final Pet pet;
  final List<Vaccination> vaccinations;

  /// Paneli alttan açar. Pasaport ekranı bu kısa metodu çağırır.
  static void show(
    BuildContext context, {
    required Pet pet,
    required List<Vaccination> vaccinations,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      // Üst köşeleri yuvarlat — uygulamanın "rounded" diline uysun.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PassportShareSheet(pet: pet, vaccinations: vaccinations),
    );
  }

  /// QR kodunun içine gömülecek metni hazırlar.
  ///
  /// `StringBuffer`, parça parça metin biriktirip sonunda tek seferde birleştiren
  /// verimli bir yardımcıdır (her `+` işleminde yeni String oluşturmaktan kaçınır).
  String _buildQrData() {
    final buffer = StringBuffer()
      ..writeln('🐾 Patiş Dijital Pasaport')
      ..writeln('İsim: ${pet.name}')
      ..writeln('Cins: ${pet.breed}')
      ..writeln('Yaş: ${pet.ageLabel}')
      ..writeln()
      ..writeln('Aşılar:');
    for (final vaccination in vaccinations) {
      buffer.writeln('• ${vaccination.name} — ${vaccination.dateLabel}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        // mainAxisSize.min → panel, içeriği kadar yer kaplasın (tüm ekranı değil).
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üstteki küçük "tutamak" çizgisi — panelin aşağı çekilebileceğini sezdirir.
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${pet.name} • Pasaport',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Bu kodu okutan kişi bilgileri görebilir',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            // QR'ı beyaz bir kartın içine koyuyoruz: tarayıcılar yüksek kontrast
            // (koyu kod / açık zemin) ister, krem zemin üzerinde okunması zorlaşabilir.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: _buildQrData(),
                size: 220,
                // Kod modüllerinin rengi — paletimizdeki orman yeşili.
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.forest,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.forest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
