import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Uygulamanın görsel kimliğini (renkler + yazı tipleri + köşe yuvarlaklığı)
/// tek bir `ThemeData` nesnesinde toplar.
///
/// `main.dart` içinde `MaterialApp(theme: AppTheme.light())` diyerek bunu
/// uygularız; böylece tüm ekranlar aynı sıcak/organik dili konuşur.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    // Renk şeması: tek bir "tohum" renkten (orman yeşili) Material 3'ün
    // uyumlu bir palet üretmesini sağlıyoruz, sonra kendi renklerimizle
    // önemli alanları elle eziyoruz (override).
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.forest,
      secondary: AppColors.terracotta,
      tertiary: AppColors.gold,
      surface: AppColors.cream, // ekran arka planı
      onPrimary: AppColors.cream,
      onSurface: AppColors.text,
    );

    // Yazı tipleri: başlıklar Fraunces, gövde metni Bricolage Grotesque.
    // google_fonts paketi bu fontları bizim için sağlar.
    // textTheme = mevcut Material gövde fontlarını Bricolage ile değiştir,
    // sonra başlık (display/headline/title) stillerini Fraunces yap.
    final baseText = GoogleFonts.bricolageGrotesqueTextTheme().apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    final textTheme = baseText.copyWith(
      displayLarge: GoogleFonts.fraunces(textStyle: baseText.displayLarge),
      displayMedium: GoogleFonts.fraunces(textStyle: baseText.displayMedium),
      displaySmall: GoogleFonts.fraunces(textStyle: baseText.displaySmall),
      headlineLarge: GoogleFonts.fraunces(textStyle: baseText.headlineLarge),
      headlineMedium: GoogleFonts.fraunces(textStyle: baseText.headlineMedium),
      headlineSmall: GoogleFonts.fraunces(textStyle: baseText.headlineSmall),
      titleLarge: GoogleFonts.fraunces(
        textStyle: baseText.titleLarge,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,

      // Kartlar: yumuşak köşeler + hafif gölge + bol iç boşluk hissi.
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),

      // Alt navigasyon çubuğunun varsayılan görünümü.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.gold.withValues(alpha: 0.25),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.bricolageGrotesque(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
