import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_patient.dart';
import '../models/vet_prescription.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import '../widgets/new_prescription_sheet.dart';
import 'vet_patient_detail_screen.dart';

/// Veteriner kliniğinin "Reçeteler" ekranı (klinik geneli).
///
/// Tüm hastalara yazılmış reçeteleri tek bir listede toplar, tarihe göre (en
/// yeni üstte) sıralar ve hayvan/sahip/ilaç adına göre aramayı destekler. Bir
/// karta dokununca hastanın detayına gider. Sağ alttaki FAB ile bir hasta
/// seçilip yeni reçete yazılabilir. Veriler [VetStore]'dan canlı gelir.
class VetPrescriptionsScreen extends StatefulWidget {
  const VetPrescriptionsScreen({super.key});

  @override
  State<VetPrescriptionsScreen> createState() => _VetPrescriptionsScreenState();
}

class _VetPrescriptionsScreenState extends State<VetPrescriptionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VetStore>();
    final patients = store.patients;
    final now = DateTime.now();

    // Tüm hastaların reçetelerini (hasta + reçete) tek listede topla.
    final entries = <_PrescriptionEntry>[];
    for (final patient in patients) {
      for (final pres in store.prescriptionsFor(patient.id)) {
        entries.add(_PrescriptionEntry(
          patient: patient,
          prescription: pres,
          date: parseTrDate(pres.dateLabel, now: now, preferPast: true),
        ));
      }
    }

    // En yeni üstte.
    entries.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    // Özet sayılar (filtreden bağımsız, tüm reçeteler üzerinden).
    final totalCount = entries.length;
    final patientCount =
        entries.map((e) => e.patient.id).toSet().length;
    final thisMonth = entries
        .where((e) =>
            e.date != null &&
            e.date!.year == now.year &&
            e.date!.month == now.month)
        .length;

    // Arama: hayvan / sahip / ilaç adına göre.
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? entries
        : entries.where((e) {
            if (e.patient.petName.toLowerCase().contains(q)) return true;
            if (e.patient.ownerName.toLowerCase().contains(q)) return true;
            return e.prescription.medicines
                .any((m) => m.name.toLowerCase().contains(q));
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reçeteler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickPatientAndWrite(context, patients),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Reçete yaz'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _StatsCard(
              total: totalCount,
              patients: patientCount,
              thisMonth: thisMonth,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Hayvan, sahip veya ilaç ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (entries.isEmpty)
              _Empty(
                icon: Icons.receipt_long_outlined,
                text: 'Henüz reçete yok.\nSağ alttan ilk reçeteyi yaz 🐾',
              )
            else if (filtered.isEmpty)
              _Empty(
                icon: Icons.search_off,
                text: '"$_query" için reçete bulunamadı',
              )
            else
              for (final entry in filtered) ...[
                _PrescriptionEntryCard(
                  entry: entry,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VetPatientDetailScreen(patient: entry.patient),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  /// Önce bir hasta seçtiren alttan paneli açar, sonra o hastaya reçete yazma
  /// formunu gösterir.
  Future<void> _pickPatientAndWrite(
    BuildContext context,
    List<VetPatient> patients,
  ) async {
    if (patients.isEmpty) return;
    final selected = await showModalBottomSheet<VetPatient>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PatientPickerSheet(patients: patients),
    );
    if (selected == null || !context.mounted) return;
    NewPrescriptionSheet.show(context, selected);
  }
}

/// Listedeki tek bir kayıt (hangi hastanın hangi reçetesi).
class _PrescriptionEntry {
  const _PrescriptionEntry({
    required this.patient,
    required this.prescription,
    required this.date,
  });

  final VetPatient patient;
  final VetPrescription prescription;

  /// [prescription.dateLabel]'dan ayrıştırılan tarih; ayrıştırılamazsa null.
  final DateTime? date;
}

/// Üstteki özet kart (forest zeminli): toplam reçete, hasta, bu ay.
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.total,
    required this.patients,
    required this.thisMonth,
  });

  final int total;
  final int patients;
  final int thisMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Stat(value: '$total', label: 'reçete'),
          _divider(),
          _Stat(value: '$patients', label: 'hasta'),
          _divider(),
          _Stat(value: '$thisMonth', label: 'bu ay'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: AppColors.cream.withValues(alpha: 0.2),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Klinik geneli listedeki tek bir reçete kartı (hasta başlığı + ilaçlar).
class _PrescriptionEntryCard extends StatelessWidget {
  const _PrescriptionEntryCard({required this.entry, required this.onTap});

  final _PrescriptionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = entry.patient;
    final pres = entry.prescription;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık: hayvan + sahip, sağda tarih.
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: AppColors.forest),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.petName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Sahibi: ${patient.ownerName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pres.dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // İlaç satırları.
              for (final m in pres.medicines)
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
                                    color:
                                        AppColors.text.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (pres.note != null) ...[
                const SizedBox(height: 4),
                Text(
                  pres.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// FAB'den açılan hasta seçim paneli — seçilen hastayı geri döndürür.
class _PatientPickerSheet extends StatelessWidget {
  const _PatientPickerSheet({required this.patients});

  final List<VetPatient> patients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Hangi hastaya?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: patients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = patients[i];
                  return Material(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () => Navigator.of(context).pop(p),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x1F2F4A3C),
                        child: Icon(Icons.pets, color: AppColors.forest),
                      ),
                      title: Text(p.petName),
                      subtitle: Text('${p.species} • ${p.ownerName}'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boş durumlar için ortak yer tutucu (boş liste / arama sonucu yok).
class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 56, color: AppColors.forest.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
