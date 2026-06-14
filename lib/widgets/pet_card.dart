import 'dart:io';

import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../theme/app_colors.dart';

/// Kullanıcının evcil hayvanını gösteren büyük yeşil kart.
///
/// Veriyi dışarıdan bir [Pet] nesnesi olarak alır; böylece kartın kendisi
/// "hangi hayvan" olduğunu bilmez, sadece verileni çizer (yeniden kullanılır).
class PetCard extends StatelessWidget {
  const PetCard({super.key, required this.pet, this.onTap, this.photoPath});

  final Pet pet;

  /// Karta dokununca çalışır (örn. Pasaport ekranına gitmek). İsteğe bağlı;
  /// verilmezse kart tıklanmaz.
  final VoidCallback? onTap;

  /// Pasaportta seçilen profil fotoğrafının yolu. Verilirse avatarda gösterilir,
  /// yoksa varsayılan pati ikonu kalır.
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Material + InkWell: forest zemini + dokununca dalga (ripple) efekti.
    return Material(
      color: AppColors.forest,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Hayvanın avatarı — pasaportta fotoğraf seçildiyse o gösterilir.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  image: photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoPath == null
                    ? const Icon(Icons.pets, color: AppColors.cream, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed} • ${pet.ageLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.cream.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
