import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_patient.dart';
import '../models/vet_prescription.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../widgets/new_prescription_sheet.dart';
import '../widgets/new_vet_appointment_sheet.dart';

/// Tek bir hastanın detay ekranı.
///
/// Hayvan/sahip bilgisi, iletişim, alerjiler, aşı kartı, tedavi geçmişi ve
/// klinik notu. Hasta kartına dokununca açılır.
class VetPatientDetailScreen extends StatelessWidget {
  const VetPatientDetailScreen({super.key, required this.patient});

  final VetPatient patient;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Depoyu dinle: yeni reçete eklenince bu ekran kendini günceller.
    final prescriptions = context.watch<VetStore>().prescriptionsFor(patient.id);
    return Scaffold(
      appBar: AppBar(title: Text(patient.petName)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Üst başlık ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pets,
                        color: AppColors.forest, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(patient.petName,
                          style: theme.textTheme.headlineSmall),
                      if (patient.tag != null) ...[
                        const SizedBox(width: 8),
                        _HeaderTag(label: patient.tag!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient.species} • ${patient.breed} • ${patient.ageLabel}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- İstatistikler ----
            Row(
              children: [
                _StatBox(
                  value: '${patient.totalVisits}',
                  label: 'ziyaret',
                  icon: Icons.event_available_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  value: '${patient.weightKg} kg',
                  label: 'kilo',
                  icon: Icons.monitor_weight_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  value: patient.nextVaccineLabel ?? '—',
                  label: 'sonraki aşı',
                  icon: Icons.vaccines_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- İletişim ----
            _SectionTitle('İletişim'),
            const SizedBox(height: 10),
            _ContactCard(
              ownerName: patient.ownerName,
              phone: patient.phone,
              onCall: () => _snack(context, '${patient.ownerName} aranıyor…'),
              onMessage: () => _snack(context, 'Mesaj gönderiliyor…'),
            ),

            // ---- Alerjiler / kronik durumlar ----
            if (patient.allergies.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle('Alerji / dikkat'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in patient.allergies)
                    Chip(
                      avatar: const Icon(Icons.warning_amber_rounded,
                          size: 18, color: AppColors.terracotta),
                      label: Text(a),
                      backgroundColor:
                          AppColors.terracotta.withValues(alpha: 0.1),
                      side: BorderSide(
                          color: AppColors.terracotta.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],

            // ---- Aşı kartı ----
            const SizedBox(height: 24),
            _SectionTitle('Aşı kartı'),
            const SizedBox(height: 10),
            if (patient.vaccinations.isEmpty)
              _EmptyHint('Henüz aşı kaydı yok')
            else
              for (final v in patient.vaccinations) ...[
                _VaccinationRow(vaccination: v),
                const SizedBox(height: 8),
              ],

            // ---- Klinik notu ----
            if (patient.note != null) ...[
              const SizedBox(height: 24),
              _SectionTitle('Klinik notu'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_outlined,
                        color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(patient.note!,
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ],

            // ---- Tedavi geçmişi ----
            const SizedBox(height: 24),
            _SectionTitle('Tedavi geçmişi'),
            const SizedBox(height: 10),
            for (final t in patient.treatments) ...[
              _TreatmentRow(treatment: t),
              const SizedBox(height: 8),
            ],

            // ---- Reçeteler (bu hastaya yazılanlar) ----
            const SizedBox(height: 24),
            _SectionTitle('Reçeteler'),
            const SizedBox(height: 10),
            if (prescriptions.isEmpty)
              _EmptyHint('Henüz reçete yok')
            else
              for (final p in prescriptions) ...[
                _PrescriptionCard(prescription: p),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 12),

            // ---- Aksiyonlar ----
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        NewPrescriptionSheet.show(context, patient),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Reçete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: const BorderSide(color: AppColors.forest),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        NewVetAppointmentSheet.show(context, patient),
                    icon: const Icon(Icons.add),
                    label: const Text('Randevu'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: AppColors.cream,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = label == 'Kronik' ? AppColors.terracotta : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

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
              textAlign: TextAlign.center,
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.ownerName,
    required this.phone,
    required this.onCall,
    required this.onMessage,
  });

  final String ownerName;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ownerName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gold.withValues(alpha: 0.18),
              foregroundColor: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onCall,
            icon: const Icon(Icons.phone),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aşı kartındaki tek bir satır (aşı adı + tarih + sonraki doz).
class _VaccinationRow extends StatelessWidget {
  const _VaccinationRow({required this.vaccination});

  final VetVaccination vaccination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.vaccines_outlined,
              color: AppColors.forest, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccination.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                Text(
                  'Yapıldı: ${vaccination.dateLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (vaccination.nextDueLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Sonraki: ${vaccination.nextDueLabel}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tedavi geçmişindeki tek bir satır.
class _TreatmentRow extends StatelessWidget {
  const _TreatmentRow({required this.treatment});

  final VetTreatment treatment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_services_outlined,
              color: Color(0xFF5B8C7B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(treatment.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    Text(
                      treatment.dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                if (treatment.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    treatment.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reçeteler bölümündeki tek bir reçete kartı (tarih + ilaçlar + not).
class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.prescription});

  final VetPrescription prescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık: reçete ikonu + tarih.
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AppColors.forest, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reçete',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                prescription.dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // İlaç satırları.
          for (final m in prescription.medicines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.forest,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: m.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (m.dosage.isNotEmpty)
                            TextSpan(
                              text: '  •  ${m.dosage}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.text.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Not (varsa).
          if (prescription.note != null) ...[
            const SizedBox(height: 4),
            Text(
              prescription.note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Boş bölüm için kısa ipucu.
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
