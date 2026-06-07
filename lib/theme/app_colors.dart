import 'package:flutter/material.dart';

/// Patiş uygulamasının tüm renk paleti.
///
/// Renkleri tek bir yerde topladık; böylece bir rengi değiştirmek
/// istediğimizde tüm ekranları tek tek dolaşmak zorunda kalmayız.
/// `const` kullanıyoruz çünkü bu değerler hiç değişmez (derleme anında sabit).
class AppColors {
  // Bu sınıftan nesne üretilmesini engelliyoruz (sadece sabitler için var).
  AppColors._();

  /// Krem zemin — ekranların arka plan rengi.
  static const Color cream = Color(0xFFFBF6EE);

  /// Orman yeşili — ana (primary) renk, butonlar ve vurgular.
  static const Color forest = Color(0xFF2F4A3C);

  /// Terracotta — ikincil vurgu (turuncumsu kırmızı).
  static const Color terracotta = Color(0xFFE07A5F);

  /// Altın — üçüncül vurgu / dikkat çekici küçük öğeler.
  static const Color gold = Color(0xFFE0A458);

  /// Koyu metin rengi.
  static const Color text = Color(0xFF243027);

  /// Kartların arka planı (krem zeminde hafif öne çıksın diye saf beyaz).
  static const Color card = Color(0xFFFFFFFF);
}
