import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../models/pet_profile.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_pet_sheet.dart';
import '../widgets/health_record_card.dart';
import '../widgets/new_health_record_sheet.dart';
import '../widgets/new_vaccination_sheet.dart';
import '../widgets/new_weight_sheet.dart';
import '../widgets/passport_share_sheet.dart';
import '../widgets/section_title.dart';
import '../widgets/vaccination_card.dart';
import '../widgets/weight_chart_card.dart';
import 'pet_journal_screen.dart';

/// Dijital Pasaport ekranı.
///
/// Üstte hayvanın profil başlığı ve künye kartı (tür, cinsiyet, mikroçip…),
/// altında sağlık özeti ve aşı/alerji/ilaç/kilo bölümleri. Veriler
/// [PassportStore]'dan (Provider) okunur; her bölümün "+" butonu ekleme formunu
/// açar.
class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  /// Galeriden bir fotoğraf seçtirir ve depoya kaydeder.
  Future<void> _pickPhoto(BuildContext context) async {
    final store = context.read<PassportStore>();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      store.setPhoto(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Depoyu DİNLE: yeni kayıt eklenince ekran kendini yeniden çizer.
    final store = context.watch<PassportStore>();
    final pet = store.pet;
    final lastWeight =
        store.weights.isNotEmpty ? store.weights.last.kg : null;
    // Sonraki dozu olan ilk aşı (hatırlatıcı banner için).
    final upcoming =
        store.vaccinations.where((v) => v.nextDueLabel != null).toList();
    final nextVacc = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Çoklu hayvan seçici: dostlar arasında geçiş + yeni ekleme.
            _PetSelector(
              pets: store.pets,
              selectedId: store.selectedId,
              onSelect: (id) => store.selectPet(id),
              onAdd: () => EditPetSheet.show(context, isNew: true),
            ),
            const SizedBox(height: 16),
            _PassportHeader(
              pet: pet,
              photoPath: store.photoPath,
              onPickPhoto: () => _pickPhoto(context),
              onOpenJournal: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PetJournalScreen()),
              ),
              onShare: () => PassportShareSheet.show(
                context,
                pet: pet,
                vaccinations: store.vaccinations,
              ),
            ),
            const SizedBox(height: 16),

            // ---- Sağlık özeti ----
            _HealthStatsRow(
              weightLabel: lastWeight != null ? '$lastWeight kg' : '—',
              vaccineCount: store.vaccinations.length,
              allergyCount: store.allergies.length,
            ),
            const SizedBox(height: 16),

            // ---- Künye ----
            _IdentityCard(pet: pet),
            const SizedBox(height: 28),

            // ---- Aşılar ----
            _SectionHeader(
              title: 'Aşılar',
              count: store.vaccinations.length,
              onAdd: () => NewVaccinationSheet.show(context),
            ),
            const SizedBox(height: 12),
            // Yaklaşan aşı varsa hatırlatıcı banner.
            if (nextVacc != null) ...[
              _UpcomingVaccineBanner(
                name: nextVacc.name,
                dueLabel: nextVacc.nextDueLabel!,
              ),
              const SizedBox(height: 12),
            ],
            if (store.vaccinations.isEmpty)
              const _EmptyHint('Henüz aşı kaydı yok')
            else
              for (final vaccination in store.vaccinations) ...[
                VaccinationCard(vaccination: vaccination),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 16),

            // ---- Alerjiler ----
            _SectionHeader(
              title: 'Alerjiler',
              count: store.allergies.length,
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
            if (store.allergies.isEmpty)
              const _EmptyHint('Bilinen alerji yok')
            else
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
              count: store.medications.length,
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
            if (store.medications.isEmpty)
              const _EmptyHint('Kayıtlı ilaç yok')
            else
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

/// Bölüm başlığı (+ isteğe bağlı sayı) ve sağında yuvarlak "+" ekleme butonu.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd, this.count});

  final String title;
  final VoidCallback onAdd;

  /// Başlığın yanında gösterilecek kayıt sayısı (verilmezse gösterilmez).
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SectionTitle(title),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
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

/// Dostlar arasında geçiş yapılan yatay seçici + "yeni dost" butonu.
///
/// Her hayvan bir avatar (fotoğrafı varsa onunla, yoksa ikonla) ve adıyla
/// gösterilir; seçili olan orman yeşili çerçeveyle vurgulanır.
class _PetSelector extends StatelessWidget {
  const _PetSelector({
    required this.pets,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
  });

  final List<PetProfile> pets;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1, // son öğe "ekle" butonu
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == pets.length) return _AddPetButton(onTap: onAdd);
          final profile = pets[i];
          return _PetAvatar(
            profile: profile,
            selected: profile.id == selectedId,
            onTap: () => onSelect(profile.id),
          );
        },
      ),
    );
  }
}

/// Seçicideki tek bir hayvan avatarı.
class _PetAvatar extends StatelessWidget {
  const _PetAvatar({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final PetProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = profile.photoPath;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.forest.withValues(alpha: 0.1),
                border: Border.all(
                  color: selected
                      ? AppColors.forest
                      : AppColors.text.withValues(alpha: 0.12),
                  width: selected ? 2.5 : 1,
                ),
                image: path != null
                    ? DecorationImage(
                        image: FileImage(File(path)), fit: BoxFit.cover)
                    : null,
              ),
              child: path == null
                  ? const Icon(Icons.pets, color: AppColors.forest)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              profile.pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected
                    ? AppColors.forest
                    : AppColors.text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seçicinin sonundaki "yeni dost ekle" butonu.
class _AddPetButton extends StatelessWidget {
  const _AddPetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            DottedCircle(
              child: const Icon(Icons.add, color: AppColors.forest),
            ),
            const SizedBox(height: 4),
            Text(
              'Ekle',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Ekle" butonu için kesik çizgili daire görünümü (basit, dolgulu çember).
class DottedCircle extends StatelessWidget {
  const DottedCircle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.forest.withValues(alpha: 0.06),
        border: Border.all(
          color: AppColors.forest.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

/// Pasaport ekranının üstündeki büyük profil başlığı.
class _PassportHeader extends StatelessWidget {
  const _PassportHeader({
    required this.pet,
    required this.photoPath,
    required this.onPickPhoto,
    required this.onOpenJournal,
    required this.onShare,
  });

  final Pet pet;
  final String? photoPath;
  final VoidCallback onPickPhoto;
  final VoidCallback onOpenJournal;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onOpenJournal,
                icon: const Icon(Icons.auto_stories_outlined,
                    color: AppColors.cream),
                tooltip: 'Günlük',
              ),
              IconButton(
                onPressed: onShare,
                icon:
                    const Icon(Icons.qr_code_2_rounded, color: AppColors.cream),
                tooltip: 'QR ile paylaş',
              ),
            ],
          ),
          GestureDetector(
            onTap: onPickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
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
                      ? const Icon(Icons.pets,
                          color: AppColors.cream, size: 44)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.forest, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.forest, size: 16),
                  ),
                ),
              ],
            ),
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
          // Tür ve cinsiyet rozetleri (varsa).
          if (pet.species != null || pet.gender != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pet.species != null)
                  _HeaderChip(icon: Icons.pets, label: pet.species!),
                if (pet.species != null && pet.gender != null)
                  const SizedBox(width: 8),
                if (pet.gender != null)
                  _HeaderChip(
                    icon: pet.gender == 'Erkek'
                        ? Icons.male
                        : Icons.female,
                    label: pet.gender!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Başlıktaki krem yarı saydam küçük rozet (tür / cinsiyet).
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.cream),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profil başlığının altındaki sağlık özeti (kilo / aşı / alerji).
class _HealthStatsRow extends StatelessWidget {
  const _HealthStatsRow({
    required this.weightLabel,
    required this.vaccineCount,
    required this.allergyCount,
  });

  final String weightLabel;
  final int vaccineCount;
  final int allergyCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.monitor_weight_outlined,
          value: weightLabel,
          label: 'güncel kilo',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.vaccines_outlined,
          value: '$vaccineCount',
          label: 'aşı',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.warning_amber_rounded,
          value: '$allergyCount',
          label: 'alerji',
        ),
      ],
    );
  }
}

/// Sağlık özetindeki tek bir istatistik kutusu.
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forest, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hayvanın resmi künye bilgilerini gösteren kart.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined,
                  color: AppColors.forest, size: 20),
              const SizedBox(width: 8),
              Text('Künye', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          if (pet.species != null)
            _InfoRow(label: 'Tür', value: pet.species!),
          _InfoRow(label: 'Cins', value: pet.breed),
          if (pet.gender != null)
            _InfoRow(label: 'Cinsiyet', value: pet.gender!),
          if (pet.birthDateLabel != null)
            _InfoRow(label: 'Doğum tarihi', value: pet.birthDateLabel!),
          if (pet.colorLabel != null)
            _InfoRow(label: 'Renk', value: pet.colorLabel!),
          if (pet.microchip != null)
            _InfoRow(label: 'Mikroçip', value: pet.microchip!, copyable: true),
          if (pet.registrationNo != null)
            _InfoRow(
                label: 'Kayıt no', value: pet.registrationNo!, isLast: true),
        ],
      ),
    );
  }
}

/// Künye kartındaki tek bir satır (etiket + değer, isteğe bağlı kopyalama).
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.isLast = false,
  });

  final String label;
  final String value;

  /// true ise değerin yanında bir kopyala butonu gösterilir (mikroçip için).
  final bool copyable;

  /// Son satırsa alttaki ayraç çizgisini gizle.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (copyable)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mikroçip no kopyalandı')),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.copy_outlined,
                        size: 18, color: AppColors.forest),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: AppColors.text.withValues(alpha: 0.06)),
      ],
    );
  }
}

/// Aşılar bölümünün üstündeki "sıradaki aşı" hatırlatıcısı.
class _UpcomingVaccineBanner extends StatelessWidget {
  const _UpcomingVaccineBanner({required this.name, required this.dueLabel});

  final String name;
  final String dueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_outlined,
                color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sıradaki aşı', style: theme.textTheme.bodySmall),
                Text(
                  '$name • $dueLabel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir bölüm boşken gösterilen kısa ipucu kartı.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.text.withValues(alpha: 0.5)),
      ),
    );
  }
}
