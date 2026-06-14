import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Uygulamanın görsel kimliğini (renkler + yazı tipleri + bileşen stilleri)
/// tek bir `ThemeData` nesnesinde toplar.
///
/// `main.dart` içinde `MaterialApp(theme: AppTheme.light())` diyerek bunu
/// uygularız; böylece tüm ekranlar aynı sıcak/organik ve modern dili konuşur.
/// Bileşen temaları (input, buton, snackbar, chip…) sayesinde tek tek ekranlara
/// dokunmadan tüm uygulamanın görünümünü buradan yönetiriz.
class AppTheme {
  AppTheme._();

  /// Beyaz kartların altında kullanılan ortak yumuşak gölge.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.forest.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.forest,
      secondary: AppColors.terracotta,
      tertiary: AppColors.gold,
      surface: AppColors.cream,
      onPrimary: AppColors.cream,
      onSurface: AppColors.text,
    );

    // Yazı tipleri: başlıklar Fraunces, gövde metni Bricolage Grotesque.
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

    final cardBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,
      // Dokunma dalgasını yumuşat (modern, daha sakin geri bildirim).
      splashFactory: InkSparkle.splashFactory,

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: cardBorder,
        margin: EdgeInsets.zero,
      ),

      // ---- Metin alanları: dolgulu, yuvarlak, çerçevesiz (modern) ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: AppColors.text.withValues(alpha: 0.4)),
        labelStyle: TextStyle(color: AppColors.text.withValues(alpha: 0.7)),
        prefixIconColor: AppColors.text.withValues(alpha: 0.5),
        suffixIconColor: AppColors.text.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.forest, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.terracotta),
        ),
      ),

      // ---- Butonlar: yuvarlak köşe, ferah dokunma alanı ----
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forest,
          side: BorderSide(color: AppColors.forest.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: GoogleFonts.bricolageGrotesque(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---- Floating + yuvarlak snackbar ----
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.forest,
        contentTextStyle: GoogleFonts.bricolageGrotesque(
          color: AppColors.cream,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),

      // ---- Çipler ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        side: BorderSide(color: AppColors.text.withValues(alpha: 0.12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: GoogleFonts.bricolageGrotesque(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),

      // ---- Alt gezinme çubuğu ----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        height: 70,
        elevation: 0,
        indicatorColor: AppColors.forest.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.bricolageGrotesque(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.forest
                : AppColors.text.withValues(alpha: 0.55),
          );
        }),
      ),

      // ---- Alttan açılan paneller ----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.text.withValues(alpha: 0.08),
        thickness: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }
}
