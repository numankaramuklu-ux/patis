import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/appointment_store.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../widgets/appointment_card.dart';
import '../widgets/new_appointment_sheet.dart';

/// Randevu ekranı (yol haritası #2).
///
/// Randevuları [AppointmentStore]'dan okur ve üstteki filtre çipleriyle hayvana
/// göre süzer. Varsayılan filtre, o an aktif (seçili) hayvandır; "Tümü" ile tüm
/// dostların randevuları görülebilir.
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // Seçili filtre: null = Tümü, aksi halde bir hayvanın kimliği.
  String? _filterPetId;

  @override
  void initState() {
    super.initState();
    // Açılışta aktif hayvanın randevularını göster.
    _filterPetId = context.read<PassportStore>().selectedId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<AppointmentStore>();
    final pets = context.watch<PassportStore>().pets;
    // Hayvan kimliğinden ada hızlı erişim (kart rozeti + filtre etiketi için).
    final petNames = {for (final p in pets) p.id: p.pet.name};

    // Seçili filtre artık mevcut değilse (hayvan silinmişse) Tümü'ne düş.
    if (_filterPetId != null && !petNames.containsKey(_filterPetId)) {
      _filterPetId = null;
    }

    final appointments = _filterPetId == null
        ? store.appointments
        : store.appointmentsFor(_filterPetId!);

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
            const SizedBox(height: 16),

            // ---- Hayvana göre filtre çipleri ----
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'Tümü',
                    selected: _filterPetId == null,
                    onTap: () => setState(() => _filterPetId = null),
                  ),
                  const SizedBox(width: 8),
                  for (final p in pets) ...[
                    _FilterChip(
                      label: p.pet.name,
                      selected: _filterPetId == p.id,
                      onTap: () => setState(() => _filterPetId = p.id),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Liste / boş durum ----
            if (appointments.isEmpty)
              _EmptyHint(
                _filterPetId == null
                    ? 'Henüz randevu yok'
                    : '${petNames[_filterPetId] ?? 'Bu dost'} için randevu yok',
              )
            else
              for (final appointment in appointments) ...[
                AppointmentCard(
                  appointment: appointment,
                  petName: petNames[appointment.petId],
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
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

/// Üstteki tek bir filtre çipi (Tümü / hayvan adı).
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? AppColors.forest : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.forest
                  : AppColors.text.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? AppColors.cream : AppColors.text,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Filtreye uygun randevu olmadığında gösterilen kısa ipucu.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 36, color: AppColors.text.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
