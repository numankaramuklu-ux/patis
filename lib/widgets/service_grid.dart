import 'package:flutter/material.dart';

import '../models/pet_service.dart';
import '../theme/app_colors.dart';

/// Hizmetleri ızgara (grid) halinde gösteren widget.
///
/// Hizmet listesini dışarıdan [PetService] listesi olarak alır. Her satırda
/// 3 kutucuk olacak şekilde kendi kendine bölünür. 3 sütun seçtik (4 yerine)
/// ki kutular ferah olsun ve "Sahiplendirme" gibi uzun etiketler sığsın.
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key, required this.services});

  final List<PetService> services;

  /// Bir satırda kaç kutu olacağı.
  static const _columns = 3;

  /// Kutular arasındaki yatay/dikey boşluk.
  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    // Kullanılabilir genişlik: ekran - dış kenar boşlukları (sağ/sol 20'şer).
    // Kalan genişliği sütun sayısına bölerken aradaki boşlukları da düşeriz.
    final available = MediaQuery.of(context).size.width - 40;
    final tileWidth = (available - _gap * (_columns - 1)) / _columns;

    // GridView yerine Wrap: dış ListView ile kaydırma çakışması olmasın diye.
    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: [
        for (final service in services)
          SizedBox(
            width: tileWidth,
            child: _ServiceTile(service: service),
          ),
      ],
    );
  }
}

/// Tek bir hizmet kutucuğu: renkli ikon kutusu + etiket.
///
/// Sadece bu dosyada kullanıldığı için "private" (alt çizgi ile) bıraktık.
class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final PetService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Material + InkWell birlikte: Material kartın zeminini/köşesini verir,
    // InkWell dokununca dalga (ripple) efekti gösterir → tıklanabilir hissi.
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias, // ripple köşelerden taşmasın
      child: InkWell(
        // Hizmetin kendi dokunma davranışı varsa onu çalıştır; yoksa (ekranı
        // henüz hazır değilse) basıldığında bir şey yapmasın.
        onTap: service.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // İkonu hizmetin kendi renginin soluk tonuyla bir kutuya alıyoruz;
              // ikon ise tam renkte → yumuşak ama belirgin bir vurgu. Rozet
              // varsa kutunun sağ üst köşesine taşacak şekilde üstüne bindiririz.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: service.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(service.icon, color: service.color, size: 26),
                  ),
                  if (service.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: _Badge(count: service.badgeCount),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Etiket için sabit yükseklik: 1 ve 2 satırlık etiketlerde tüm
              // kutular aynı boyda kalsın (satır hizası bozulmasın).
              SizedBox(
                height: 34,
                child: Center(
                  child: Text(
                    service.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// İkon üzerindeki küçük sayı rozeti (örn. okunmamış bildirim adedi).
/// 9'dan büyük sayıları "9+" gösterir ki rozet küçük ve yuvarlak kalsın.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.terracotta,
        borderRadius: BorderRadius.circular(10),
        // Krem zeminden ayrılsın diye ince bir çerçeve.
        border: Border.all(color: AppColors.cream, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cream,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
