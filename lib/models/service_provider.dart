import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Owner tarafında listelenen hizmet vereni türü. Etiket/ikon/renk taşır.
enum ProviderKind {
  veteriner(
    label: 'Veteriner',
    plural: 'Veterinerler',
    icon: Icons.medical_services_outlined,
    accent: AppColors.forest,
  ),
  kuafor(
    label: 'Kuaför',
    plural: 'Kuaförler',
    icon: Icons.content_cut,
    accent: AppColors.terracotta,
  );

  const ProviderKind({
    required this.label,
    required this.plural,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String plural;
  final IconData icon;
  final Color accent;
}

/// Owner tarafında gezilebilen bir hizmet veren (veteriner kliniği / kuaför
/// salonu). Yorumlar [ReviewStore]'da [id] (= targetId) ile tutulur.
///
/// [PetSitter] / [PetWalker] ile aynı mantık; veteriner ve kuaförü tek modelle
/// kapsamak için [kind] alanı var.
class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.kind,
    required this.name,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.summary,
    this.priceFrom,
    this.phone,
    this.verified = false,
  });

  final String id;
  final ProviderKind kind;

  /// İşletme/klinik adı (örn. "Patiş Veteriner Kliniği").
  final String name;

  /// Semt / bölge (örn. "Kadıköy, İstanbul").
  final String district;

  String get city => district.contains(',')
      ? district.split(',').last.trim()
      : district.trim();

  /// Ortalama puan (0–5).
  final double rating;

  /// Değerlendirme sayısı.
  final int reviewCount;

  /// Kısa tanıtım.
  final String summary;

  /// Başlangıç fiyatı (TL); muayene/bakım için "₺X'den" gösterilir.
  final int? priceFrom;

  final String? phone;
  final bool verified;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'name': name,
        'district': district,
        'rating': rating,
        'reviewCount': reviewCount,
        'summary': summary,
        'priceFrom': priceFrom,
        'phone': phone,
        'verified': verified,
      };

  factory ServiceProvider.fromJson(Map<String, dynamic> json) =>
      ServiceProvider(
        id: json['id'] as String? ?? '',
        kind: ProviderKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => ProviderKind.veteriner,
        ),
        name: json['name'] as String? ?? '',
        district: json['district'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        summary: json['summary'] as String? ?? '',
        priceFrom: (json['priceFrom'] as num?)?.toInt(),
        phone: json['phone'] as String?,
        verified: json['verified'] as bool? ?? false,
      );
}
