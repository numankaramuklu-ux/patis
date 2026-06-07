import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/appointment_store.dart';
import '../theme/app_colors.dart';
import '../widgets/appointment_card.dart';
import '../widgets/new_appointment_sheet.dart';

/// Randevu ekranı (yol haritası #2).
///
/// Randevuları artık [AppointmentStore]'dan (Provider) okur; sağ alttaki
/// "Yeni randevu" butonuyla ileride randevu oluşturma formunu açacağız.
class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu DİNLE: randevu listesi değişirse bu ekran kendini yeniden çizer.
    final appointments = context.watch<AppointmentStore>().appointments;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Randevular', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Yaklaşan veteriner ve kuaför randevuların',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Her randevuyu karta dönüştürüp aralarına boşluk koyuyoruz.
            for (final appointment in appointments) ...[
              AppointmentCard(appointment: appointment),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      // Sağ alta sabitlenen "Yeni randevu" butonu. Şimdilik bir bilgi mesajı
      // gösteriyor; randevu oluşturma formunu sonraki adımda ekleyeceğiz.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewAppointmentSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Yeni randevu'),
      ),
    );
  }
}
