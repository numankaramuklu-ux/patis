import 'package:flutter/material.dart';

import '../models/vet_appointment.dart';
import '../theme/app_colors.dart';

/// Veteriner randevusunu gösteren kart.
///
/// Solda saat sütunu, ortada hayvan/sahip ve tür ikonlu sebep + ücret; üst
/// köşede durum rozeti. Salon kartıyla aynı düzeni izler ama tür ikonu taşır.
class VetAppointmentCard extends StatelessWidget {
  const VetAppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onStatusChanged,
  });

  final VetAppointment appointment;
  final VoidCallback? onTap;

  /// Verilirse durum rozeti tıklanabilir olur; seçilen yeni durum buraya
  /// bildirilir (kartın detay panelini açmadan hızlı değiştirme). null ise
  /// rozet salt-okunur gösterilir (örn. ana ekran özetinde).
  final ValueChanged<VetApptStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = appointment.type.color;
    final faded = appointment.status == VetApptStatus.iptal;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: faded ? 0.55 : 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saat sütunu. Sabit genişlik veriyoruz; aksi halde orantılı
                // rakamlar yüzünden "11:00" ile "09:30" farklı genişlikte olur
                // ve ayraç + sağdaki metinler satırdan satıra kayar.
                SizedBox(
                  width: 52,
                  child: Column(
                    children: [
                      Text(
                        appointment.time,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      Text(
                        '${appointment.durationMin} dk',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.text.withValues(alpha: 0.1),
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
                              appointment.petName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          onStatusChanged == null
                              ? _StatusBadge(status: appointment.status)
                              : _StatusSelector(
                                  status: appointment.status,
                                  onChanged: onStatusChanged!,
                                ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sahibi: ${appointment.ownerName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Tür rozeti (Aşı/Kontrol/Operasyon/Acil).
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(appointment.type.icon,
                                    size: 13, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.type.label,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appointment.reason,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${appointment.price}₺',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Randevu durumunu gösteren küçük renkli rozet.
///
/// [interactive] true ise yanında bir aşağı-ok gösterir; bu, rozetin
/// tıklanıp durum değiştirilebileceğini ima eder ([_StatusSelector] sarmalar).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.interactive = false});

  final VetApptStatus status;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 3, interactive ? 3 : 8, 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (interactive)
            Icon(Icons.arrow_drop_down, size: 16, color: status.color),
        ],
      ),
    );
  }
}

/// Rozete dokununca durum seçim panelini açan sarmalayıcı.
///
/// Dokununca alt panel (bottom sheet) açılır; tüm durumlar renkli noktayla
/// listelenir, mevcut durumun yanında onay işareti olur. Seçim [onChanged]
/// ile bildirilir. (Alt panel, kart içindeki PopupMenuButton'a kıyasla hem
/// daha güvenilir açılıyor hem de dokunması kolay.)
class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.status, required this.onChanged});

  final VetApptStatus status;
  final ValueChanged<VetApptStatus> onChanged;

  void _open(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Durumu değiştir', style: theme.textTheme.titleLarge),
              ),
            ),
            for (final s in VetApptStatus.values)
              ListTile(
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(s.label),
                trailing: s == status
                    ? Icon(Icons.check, color: s.color)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (s != status) onChanged(s);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: _StatusBadge(status: status, interactive: true),
    );
  }
}
