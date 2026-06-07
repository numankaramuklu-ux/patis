import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../widgets/health_record_card.dart';
import '../widgets/new_health_record_sheet.dart';
import '../widgets/new_vaccination_sheet.dart';
import '../widgets/new_weight_sheet.dart';
import '../widgets/passport_share_sheet.dart';
import '../widgets/section_title.dart';
import '../widgets/vaccination_card.dart';
import '../widgets/weight_chart_card.dart';

/// Dijital Pasaport ekranı.
///
/// Üstte hayvanın profil başlığı; altında aşı, alerji, ilaç ve kilo takibi
/// bölümleri. Veriler artık [PassportStore]'dan (Provider) okunur; her bölümün
/// başlığındaki "+" butonu ilgili ekleme formunu açar.
class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  // Tek hayvan olduğu için profil sabit (değişmiyor); diğer veriler depodan.
  static const _pet = Pet(
    name: 'Pamuk',
    breed: 'British Shorthair',
    ageLabel: '2 yaşında',
  );

  @override
  Widget build(BuildContext context) {
    // Depoyu DİNLE: yeni kayıt eklenince ekran kendini yeniden çizer.
    final store = context.watch<PassportStore>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _PassportHeader(
              pet: _pet,
              onShare: () => PassportShareSheet.show(
                context,
                pet: _pet,
                vaccinations: store.vaccinations,
              ),
            ),
            const SizedBox(height: 28),

            // ---- Aşılar ----
            _SectionHeader(
              title: 'Aşılar',
              onAdd: () => NewVaccinationSheet.show(context),
            ),
            const SizedBox(height: 12),
            for (final vaccination in store.vaccinations) ...[
              VaccinationCard(vaccination: vaccination),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),

            // ---- Alerjiler ----
            _SectionHeader(
              title: 'Alerjiler',
              onAdd: () => NewHealthRecordSheet.show(
                context,
                heading: 'Yeni alerji',
                titleLabel: 'Alerjen',
                titleHint: 'Örn. Tavuk proteini',
                noteLabel: 'Belirti',
                noteHint: 'Örn. Ciltte kaşıntı yapıyor',
                onSave: (record) =>
                    context.read<PassportStore>().addAllergy(record),
              ),
            ),
            const SizedBox(height: 12),
            for (final allergy in store.allergies) ...[
              HealthRecordCard(
                record: allergy,
                icon: Icons.warning_amber_rounded,
                color: AppColors.terracotta,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),

            // ---- İlaçlar ----
            _SectionHeader(
              title: 'İlaçlar',
              onAdd: () => NewHealthRecordSheet.show(
                context,
                heading: 'Yeni ilaç',
                titleLabel: 'İlaç adı',
                titleHint: 'Örn. Frontline',
                noteLabel: 'Doz / kullanım',
                noteHint: 'Örn. Ayda 1 damla • boyun arkası',
                onSave: (record) =>
                    context.read<PassportStore>().addMedication(record),
              ),
            ),
            const SizedBox(height: 12),
            for (final medication in store.medications) ...[
              HealthRecordCard(
                record: medication,
                icon: Icons.medication_outlined,
                color: AppColors.gold,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),

            // ---- Kilo takibi ----
            _SectionHeader(
              title: 'Kilo takibi',
              onAdd: () => NewWeightSheet.show(context),
            ),
            const SizedBox(height: 12),
            WeightChartCard(entries: store.weights),
          ],
        ),
      ),
    );
  }
}

/// Bölüm başlığı + sağında yuvarlak "+" ekleme butonu.
///
/// Pasaporttaki her bölüm (Aşılar, Alerjiler, İlaçlar, Kilo) bunu kullanır;
/// [onAdd] ilgili ekleme formunu açar.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionTitle(title),
        // Küçük, yuvarlak ekleme butonu (forest zeminli krem artı).
        Material(
          color: AppColors.forest,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, color: AppColors.cream, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pasaport ekranının üstündeki büyük profil başlığı.
class _PassportHeader extends StatelessWidget {
  const _PassportHeader({required this.pet, required this.onShare});

  final Pet pet;

  /// Sağ üstteki paylaş ikonuna basılınca çağrılır.
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.cream),
              tooltip: 'QR ile paylaş',
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppColors.cream, size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            pet.name,
            style: theme.textTheme.headlineSmall?.copyWith(
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
    );
  }
}
