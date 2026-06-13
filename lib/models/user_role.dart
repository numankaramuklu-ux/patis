import 'package:flutter/material.dart';

/// Kayıt sırasında kullanıcının seçtiği hesap türü.
///
/// Patiş'i sadece evcil hayvan sahibi olarak mı kullanıyor, yoksa hizmet veren
/// bir pet kuaförü / veteriner mi — bunu ayırt etmek için. İleride role göre
/// farklı ekranlar (örn. işletme paneli) göstereceğiz.
enum UserRole {
  /// Evcil hayvan sahibi normal kullanıcı.
  kullanici,

  /// Pet kuaförü / bakım salonu işletmecisi.
  kuafor,

  /// Veteriner hekim / klinik.
  veteriner;

  /// Rol kartında gösterilen kısa başlık.
  String get label => switch (this) {
        UserRole.kullanici => 'Evcil hayvan sahibi',
        UserRole.kuafor => 'Pet kuaförü',
        UserRole.veteriner => 'Veteriner',
      };

  /// Rol kartının altındaki açıklama satırı.
  String get description => switch (this) {
        UserRole.kullanici =>
          'Dostumun bakımını takip etmek ve topluluğa katılmak istiyorum',
        UserRole.kuafor => 'Bakım/tıraş hizmeti veriyorum, randevu almak istiyorum',
        UserRole.veteriner => 'Klinik hizmeti veriyorum, hasta takibi yapacağım',
      };

  /// Rol kartındaki ikon.
  IconData get icon => switch (this) {
        UserRole.kullanici => Icons.pets,
        UserRole.kuafor => Icons.content_cut,
        UserRole.veteriner => Icons.medical_services_outlined,
      };

  /// İşletme adı alanı sadece hizmet veren roller için anlamlı.
  bool get isBusiness => this != UserRole.kullanici;
}
