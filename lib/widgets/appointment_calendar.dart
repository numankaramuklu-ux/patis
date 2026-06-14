import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Randevu ekranlarında Liste / Takvim görünümü arasında geçiş yapan ikili
/// segment butonu. Hem salon hem veteriner ekranı aynı bileşeni kullanır.
class AppointmentViewToggle extends StatelessWidget {
  const AppointmentViewToggle({
    super.key,
    required this.calendar,
    required this.onChanged,
  });

  /// true = takvim görünümü seçili, false = liste.
  final bool calendar;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _segment(
            label: 'Liste',
            icon: Icons.view_agenda_outlined,
            active: !calendar,
            onTap: () => onChanged(false),
          ),
          _segment(
            label: 'Takvim',
            icon: Icons.calendar_month_outlined,
            active: calendar,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.forest : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? AppColors.cream : AppColors.text,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.cream : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Randevu yoğunluğunu noktalarla gösteren basit aylık takvim ızgarası.
///
/// Bağımlılık eklememek için elle çizilir: ay başlığı + hafta günü satırı +
/// 7 sütunlu gün ızgarası. Randevu verisinden bağımsızdır; her gün için
/// randevu sayısını [countFor] ve bekleyen olup olmadığını [pendingFor]
/// geri-çağırımlarından öğrenir. Böylece hem salon hem veteriner ekranı
/// kendi modelini geçirip aynı takvimi kullanabilir.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.countFor,
    required this.pendingFor,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;

  /// Verilen günde kaç randevu olduğunu döndürür (0 = nokta yok).
  final int Function(DateTime day) countFor;

  /// Verilen günde bekleyen (onay bekleyen) randevu var mı.
  final bool Function(DateTime day) pendingFor;

  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    // Ayın ilk günü ve gün sayısı.
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    // Pazartesi=1 ... Pazar=7 → ızgarada başa eklenecek boş hücre sayısı.
    final leadingBlanks = firstOfMonth.weekday - 1;

    // Hücre listesi: önce boşluklar, sonra günler.
    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, d);
      cells.add(_DayCell(
        day: d,
        selected: _sameDay(date, selectedDay),
        isToday: _sameDay(date, today),
        hasPending: pendingFor(date),
        count: countFor(date),
        onTap: () => onSelectDay(date),
      ));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Ay başlığı + ileri/geri okları.
          Row(
            children: [
              _NavArrow(icon: Icons.chevron_left, onTap: onPrevMonth),
              Expanded(
                child: Text(
                  formatTrMonthYear(focusedMonth),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              _NavArrow(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 8),
          // Hafta günü başlıkları (Pazartesi başlangıçlı).
          Row(
            children: [
              for (final d in const [
                'Pzt',
                'Sal',
                'Çar',
                'Per',
                'Cum',
                'Cmt',
                'Paz'
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Gün ızgarası.
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
        ],
      ),
    );
  }
}

/// Takvimdeki tek bir gün hücresi (gün numarası + randevu noktası).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.hasPending,
    required this.count,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isToday;
  final bool hasPending;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAppts = count > 0;
    final dotColor = hasPending ? AppColors.gold : AppColors.forest;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppColors.forest : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !selected
                ? Border.all(color: AppColors.forest, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? AppColors.cream : AppColors.text,
                  fontWeight:
                      isToday || selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              // Randevu noktası (seçiliyken kontrast için krem).
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: hasAppts
                      ? (selected ? AppColors.cream : dotColor)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Takvim başlığındaki ay değiştirme oku.
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: AppColors.forest,
      visualDensity: VisualDensity.compact,
    );
  }
}
