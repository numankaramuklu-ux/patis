import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/lost_pet_store.dart';
import '../theme/app_colors.dart';
import '../widgets/lost_pet_card.dart';
import '../widgets/new_lost_pet_sheet.dart';
import 'lost_pet_detail_screen.dart';

/// Kayıp / Bulundu ilanları ekranı (yol haritası #5).
///
/// Alt menüdeki "Kayıp" sekmesi. İlanları [LostPetStore]'dan (Provider) okur;
/// sağ alttaki "Kayıp bildir" butonu yeni ilan formunu açar. Harita ve konuma
/// dayalı bildirim sonraki adımda eklenecek.
class LostPetScreen extends StatelessWidget {
  const LostPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu DİNLE: yeni ilan eklenince bu ekran kendini yeniden çizer.
    final lostPets = context.watch<LostPetStore>().lostPets;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Kayıp & Bulundu', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Bölgendeki ilanlar — birlikte yuvasına ulaştıralım',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final lostPet in lostPets) ...[
              LostPetCard(
                lostPet: lostPet,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LostPetDetailScreen(lostPet: lostPet),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      // "Kayıp bildir" butonu — yeni ilan formunu açar.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewLostPetSheet.show(context),
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Kayıp bildir'),
      ),
    );
  }
}
