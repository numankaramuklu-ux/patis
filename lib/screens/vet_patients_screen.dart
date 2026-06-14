import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vet_patient.dart';
import '../state/vet_store.dart';
import '../theme/app_colors.dart';
import 'vet_patient_detail_screen.dart';

/// Veteriner kliniğinin Hastalar ekranı (veteriner rolünün 1. sekmesi).
///
/// Özet istatistik kartı + arama + hasta kartları. Karta dokununca hasta detay
/// ekranı açılır. Veriler [VetStore]'dan gelir.
class VetPatientsScreen extends StatefulWidget {
  const VetPatientsScreen({super.key});

  @override
  State<VetPatientsScreen> createState() => _VetPatientsScreenState();
}

class _VetPatientsScreenState extends State<VetPatientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patients = context.watch<VetStore>().patients;

    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? patients
        : patients
            .where((p) =>
                p.petName.toLowerCase().contains(q) ||
                p.ownerName.toLowerCase().contains(q))
            .toList();

    // Özet istatistikler.
    final total = patients.length;
    final dueVaccine =
        patients.where((p) => p.nextVaccineLabel != null).length;
    final chronic = patients.where((p) => p.tag == 'Kronik').length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Hastalar', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            _StatsCard(total: total, dueVaccine: dueVaccine, chronic: chronic),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Hasta veya sahip ara',
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
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    '"$_query" için hasta bulunamadı',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              for (final patient in filtered) ...[
                _PatientCard(
                  patient: patient,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VetPatientDetailScreen(patient: patient),
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
}

/// Üstteki özet istatistik kartı (forest zeminli).
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.total,
    required this.dueVaccine,
    required this.chronic,
  });

  final int total;
  final int dueVaccine;
  final int chronic;

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
          _Stat(value: '$total', label: 'hasta'),
          _divider(),
          _Stat(value: '$dueVaccine', label: 'aşı zamanı'),
          _divider(),
          _Stat(value: '$chronic', label: 'kronik takip'),
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

/// Hasta listesindeki tek bir kart (detay ekranına götürür).
class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final VetPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.pets, color: AppColors.forest, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            patient.petName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (patient.tag != null) ...[
                          const SizedBox(width: 8),
                          _Tag(label: patient.tag!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.species} • ${patient.breed} • ${patient.ageLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Yaklaşan aşı varsa öne çıkar; yoksa son ziyaret.
                    Text(
                      patient.nextVaccineLabel != null
                          ? 'Aşı: ${patient.nextVaccineLabel} • Son: ${patient.lastVisitLabel}'
                          : 'Son ziyaret: ${patient.lastVisitLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.text),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hasta durum etiketi (örn. "Kronik").
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Kronik takip dikkat çekici (terracotta), diğerleri sakin (gold).
    final color =
        label == 'Kronik' ? AppColors.terracotta : AppColors.gold;
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
