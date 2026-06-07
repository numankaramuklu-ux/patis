import 'package:flutter/material.dart';

/// Ekranlardaki bölüm başlığı (örn. "Tüm hizmetler", "Yaklaşan randevu").
///
/// Tek satırlık ama birçok yerde kullanacağımız için ayrı widget yaptık;
/// böylece başlık stilini tek yerden değiştirebiliriz.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
