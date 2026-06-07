import 'package:flutter/material.dart';

/// Ana Sayfa'daki "Tüm hizmetler" ızgarasında gösterilen tek bir hizmet
/// (örn. Pasaport, Randevu, Kayıp...).
///
/// `icon` arayüz öğesi olduğu için bu modelin `material.dart`'a ihtiyacı var.
class PetService {
  const PetService({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
  });

  /// Kutucukta gösterilecek ikon.
  final IconData icon;

  /// Kutucuğun altındaki etiket (örn. "Pasaport").
  final String label;

  /// Bu hizmetin vurgu rengi. Her hizmete farklı renk vererek ızgaranın
  /// monoton görünmesini engeller ve gözün hizmetleri ayırt etmesini
  /// kolaylaştırır.
  final Color color;

  /// Kutucuğa dokununca çalışacak iş (örn. ilgili ekrana gitmek).
  ///
  /// İsteğe bağlı: ekranı henüz hazır olmayan hizmetlerde boş bırakılır,
  /// o kutu da basıldığında bir şey yapmaz.
  final VoidCallback? onTap;

  /// Kutucuğun ikonu üzerinde gösterilecek sayı rozeti (örn. okunmamış
  /// bildirim sayısı). 0 ise rozet gösterilmez.
  final int badgeCount;
}
