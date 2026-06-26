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
  veteriner,

  /// Pet sitter / evde bakıcı. Konaklama (rezervasyon) talepleri alır.
  petSitter;

  /// Rol kartında gösterilen kısa başlık.
  String get label => switch (this) {
        UserRole.kullanici => 'Evcil hayvan sahibi',
        UserRole.kuafor => 'Pet kuaförü',
        UserRole.veteriner => 'Veteriner',
        UserRole.petSitter => 'Pet sitter',
      };

  /// Rol kartının altındaki açıklama satırı.
  String get description => switch (this) {
        UserRole.kullanici =>
          'Dostumun bakımını takip etmek ve topluluğa katılmak istiyorum',
        UserRole.kuafor => 'Bakım/tıraş hizmeti veriyorum, randevu almak istiyorum',
        UserRole.veteriner => 'Klinik hizmeti veriyorum, hasta takibi yapacağım',
        UserRole.petSitter =>
          'Evde hayvan bakıyorum, konaklama rezervasyonları alacağım',
      };

  /// Rol kartındaki ikon.
  IconData get icon => switch (this) {
        UserRole.kullanici => Icons.pets,
        UserRole.kuafor => Icons.content_cut,
        UserRole.veteriner => Icons.medical_services_outlined,
        UserRole.petSitter => Icons.home_work_outlined,
      };

  /// İşletme adı (salon/klinik) alanı yalnızca kuaför ve veteriner için anlamlı.
  /// Pet sitter bireysel çalıştığı için işletme adı istemiyoruz.
  bool get isBusiness =>
      this == UserRole.kuafor || this == UserRole.veteriner;

  /// Sahip dışındaki tüm roller hizmet sağlayıcıdır (panel/dashboard görür).
  bool get isProvider => this != UserRole.kullanici;
}
