import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon_appointment.dart';
import '../state/salon_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import '../widgets/appointment_calendar.dart';
import '../widgets/salon_appointment_card.dart';

/// Pet salonunun Randevular ekranı (kuaför rolünün Randevu sekmesi).
///
/// Üstte durum filtreleri (Tümü / Bekleyen / Onaylı / Tamamlanan), altında güne
/// göre (Bugün, Yarın) gruplanmış randevu kartları. Bir karta dokununca aksiyon
/// içeren detay paneli açılır. Veriler [SalonStore]'dan gelir.
class SalonAppointmentsScreen extends StatefulWidget {
  const SalonAppointmentsScreen({super.key});

  @override
  State<SalonAppointmentsScreen> createState() =>
      _SalonAppointmentsScreenState();
}

class _SalonAppointmentsScreenState extends State<SalonAppointmentsScreen> {
  // null = "Tümü". Aksi halde sadece bu durumdaki randevular gösterilir.
  SalonApptStatus? _filter;

  // false = liste görünümü, true = takvim görünümü.
  bool _calendar = false;

  // Takvimde görüntülenen ay ve seçili gün (varsayılan: bugün).
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  /// İki tarihin aynı güne ait olup olmadığını döndürür (saat yok sayılır).
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<SalonStore>();
    final all = store.appointments;

    // Filtre uygula (her iki görünüm de aynı filtreyi kullanır).
    final filtered = _filter == null
        ? all
        : all.where((a) => a.status == _filter).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Randevular', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Bugün ${store.todayCount} randevu • ${store.pendingCount} onay bekliyor',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // Liste / Takvim görünüm geçişi.
            AppointmentViewToggle(
              calendar: _calendar,
              onChanged: (v) => setState(() => _calendar = v),
            ),
            const SizedBox(height: 16),
            // Durum filtreleri.
            _FilterChips(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 20),
            if (_calendar)
              ..._calendarView(theme, filtered)
            else
              ..._listView(theme, filtered),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LİSTE GÖRÜNÜMÜ
  // ---------------------------------------------------------------------------
  List<Widget> _listView(ThemeData theme, List<SalonAppointment> filtered) {
    if (filtered.isEmpty) return [_EmptyState(theme: theme)];

    // Güne göre grupla (listedeki sırayı koruyup benzersiz gün etiketlerini
    // topluyoruz; randevular zaten tarih sırasında).
    final days = <String>[];
    for (final a in filtered) {
      if (!days.contains(a.dayLabel)) days.add(a.dayLabel);
    }
    return [
      for (final day in days) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(day, style: theme.textTheme.titleLarge),
        ),
        for (final appt in filtered.where((a) => a.dayLabel == day)) ...[
          SalonAppointmentCard(
            appointment: appt,
            onTap: () => _AppointmentDetailSheet.show(context, appt),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    ];
  }

  // ---------------------------------------------------------------------------
  // TAKVİM GÖRÜNÜMÜ
  // ---------------------------------------------------------------------------
  List<Widget> _calendarView(ThemeData theme, List<SalonAppointment> filtered) {
    // Seçili güne ait randevular (saate göre sıralı).
    final dayAppts = filtered.where((a) => _sameDay(a.date, _selectedDay)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return [
      MonthCalendar(
        focusedMonth: _focusedMonth,
        selectedDay: _selectedDay,
        countFor: (day) =>
            filtered.where((a) => _sameDay(a.date, day)).length,
        pendingFor: (day) => filtered.any(
          (a) =>
              _sameDay(a.date, day) && a.status == SalonApptStatus.bekliyor,
        ),
        onPrevMonth: () => setState(() {
          _focusedMonth =
              DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        }),
        onNextMonth: () => setState(() {
          _focusedMonth =
              DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        }),
        onSelectDay: (d) => setState(() => _selectedDay = d),
      ),
      const SizedBox(height: 24),
      // Seçili günün başlığı.
      Row(
        children: [
          Text(formatTrDayMonth(_selectedDay), style: theme.textTheme.titleLarge),
          const SizedBox(width: 8),
          Text(
            '${dayAppts.length} randevu',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (dayAppts.isEmpty)
        _EmptyState(theme: theme, message: 'Bu günde randevu yok')
      else
        for (final appt in dayAppts) ...[
          SalonAppointmentCard(
            appointment: appt,
            onTap: () => _AppointmentDetailSheet.show(context, appt),
          ),
          const SizedBox(height: 12),
        ],
    ];
  }
}

/// Durum filtresi seçici (yatay chip dizisi).
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final SalonApptStatus? selected;
  final ValueChanged<SalonApptStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    // null = Tümü; ardından her durum bir chip.
    final items = <(String, SalonApptStatus?)>[
      ('Tümü', null),
      for (final s in SalonApptStatus.values) (s.label, s),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, value) = items[i];
          final active = selected == value;
          return ChoiceChip(
            label: Text(label),
            selected: active,
            onSelected: (_) => onChanged(value),
            showCheckmark: false,
            backgroundColor: AppColors.card,
            selectedColor: AppColors.forest,
            labelStyle: TextStyle(
              color: active ? AppColors.cream : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: active
                    ? AppColors.forest
                    : AppColors.text.withValues(alpha: 0.15),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Filtre sonucu boşsa gösterilen durum.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, this.message = 'Bu filtrede randevu yok'});

  final ThemeData theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: AppColors.text.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Randevu detayını ve duruma göre aksiyon butonlarını gösteren alt panel.
class _AppointmentDetailSheet extends StatelessWidget {
  const _AppointmentDetailSheet({required this.appointment});

  final SalonAppointment appointment;

  static void show(BuildContext context, SalonAppointment appointment) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AppointmentDetailSheet(appointment: appointment),
    );
  }

  /// Durumu değiştirir, kullanıcıya kısa bilgi verir ve paneli kapatır.
  void _setStatus(BuildContext context, SalonApptStatus status, String msg) {
    context.read<SalonStore>().updateStatus(appointment.id, status);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = appointment;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
          Row(
            children: [
              Expanded(
                child: Text('${a.petName} • ${a.breed}',
                    style: theme.textTheme.titleLarge),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: a.status.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  a.status.label,
                  style: TextStyle(
                    color: a.status.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(icon: Icons.person_outline, label: 'Sahibi', value: a.ownerName),
          _DetailRow(
              icon: Icons.schedule,
              label: 'Zaman',
              value: '${a.dayLabel}, ${a.time}'),
          _DetailRow(
              icon: Icons.content_cut, label: 'Hizmet', value: a.service),
          _DetailRow(
              icon: Icons.timelapse_outlined,
              label: 'Süre',
              value: '${a.durationMin} dakika'),
          _DetailRow(
              icon: Icons.payments_outlined,
              label: 'Ücret',
              value: '${a.price} ₺'),
          const SizedBox(height: 24),
          ..._actions(context),
        ],
      ),
    );
  }

  /// Mevcut duruma göre uygun aksiyon butonlarını üretir.
  List<Widget> _actions(BuildContext context) {
    switch (appointment.status) {
      case SalonApptStatus.bekliyor:
        return [
          _PrimaryButton(
            label: 'Randevuyu onayla',
            color: AppColors.forest,
            icon: Icons.check_circle_outline,
            onPressed: () => _setStatus(
                context, SalonApptStatus.onaylandi, 'Randevu onaylandı'),
          ),
          const SizedBox(height: 10),
          _TextAction(
            label: 'İsteği reddet',
            color: AppColors.terracotta,
            onPressed: () => _setStatus(
                context, SalonApptStatus.iptal, 'Randevu iptal edildi'),
          ),
        ];
      case SalonApptStatus.onaylandi:
        return [
          _PrimaryButton(
            label: 'Tamamlandı olarak işaretle',
            color: const Color(0xFF5B8C7B),
            icon: Icons.done_all,
            onPressed: () => _setStatus(
                context, SalonApptStatus.tamamlandi, 'Randevu tamamlandı'),
          ),
          const SizedBox(height: 10),
          _TextAction(
            label: 'Randevuyu iptal et',
            color: AppColors.terracotta,
            onPressed: () => _setStatus(
                context, SalonApptStatus.iptal, 'Randevu iptal edildi'),
          ),
        ];
      case SalonApptStatus.tamamlandi:
        return [
          _InfoNote(
            icon: Icons.done_all,
            text: 'Bu randevu tamamlandı.',
            color: const Color(0xFF5B8C7B),
          ),
        ];
      case SalonApptStatus.iptal:
        return [
          _TextAction(
            label: 'İptali geri al (bekliyor)',
            color: AppColors.forest,
            onPressed: () => _setStatus(
                context, SalonApptStatus.bekliyor, 'Randevu geri alındı'),
          ),
        ];
    }
  }
}

/// Detay panelindeki tek bir bilgi satırı (ikon + etiket + değer).
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.forest),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dolgu (filled) ana aksiyon butonu.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// İkincil metin aksiyonu (örn. iptal).
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: color),
        child: Text(label),
      ),
    );
  }
}

/// Aksiyon gerektirmeyen durumlarda gösterilen bilgi notu.
class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
