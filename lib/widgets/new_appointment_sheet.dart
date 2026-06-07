import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../state/appointment_store.dart';
import '../theme/app_colors.dart';

/// "Yeni randevu" oluşturma formu (alttan açılan panel).
///
/// Kullanıcı girişi (yazılan metin, seçilen tür/tarih) zaman içinde değiştiği
/// için bu bir [StatefulWidget]. Kaydedilince randevuyu [AppointmentStore]'a
/// ekler ve paneli kapatır.
class NewAppointmentSheet extends StatefulWidget {
  const NewAppointmentSheet({super.key});

  /// Paneli açan kısa yardımcı. Randevu ekranı bunu çağırır.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      // isScrollControlled: klavye açılınca panelin yukarı kayabilmesi için.
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewAppointmentSheet(),
    );
  }

  @override
  State<NewAppointmentSheet> createState() => _NewAppointmentSheetState();
}

class _NewAppointmentSheetState extends State<NewAppointmentSheet> {
  // Türkçe ay isimleri — seçilen tarihi "12 Haziran" gibi etikete çevirmek için.
  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  // TextField'ların içeriğini okumak için controller'lar. Widget yok olurken
  // bellekten temizlemek gerektiği için dispose()'ta serbest bırakıyoruz.
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();

  // Form üzerinde o an seçili olan tür ve tarih/saat.
  AppointmentType _type = AppointmentType.veteriner;
  DateTime? _dateTime;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  /// Seçilen tarihi "12 Haziran, 14:30" biçiminde metne çevirir.
  String _formatDate(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month - 1]}, $hour:$minute';
  }

  /// Önce gün, sonra saat seçtiren sistem diyaloglarını sırayla açar.
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return; // kullanıcı vazgeçti
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // AM/PM yerine 24 saatlik (yerel) gösterim zorla — cihaz dili ne olursa
      // olsun saat seçici "14:30" biçiminde çalışsın.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _dateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  /// Formu doğrular ve geçerliyse randevuyu depoya ekler.
  void _save() {
    final title = _titleController.text.trim();
    final place = _placeController.text.trim();

    // Eksik alan varsa uyarı göster, kaydetme.
    if (title.isEmpty || place.isEmpty || _dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldur')),
      );
      return;
    }

    // context.read: depoya sadece bir kez erişip metodunu çağırıyoruz
    // (dinlemiyoruz, o yüzden watch değil read).
    context.read<AppointmentStore>().add(
          Appointment(
            title: title,
            place: place,
            dateLabel: _formatDate(_dateTime!),
            type: _type,
          ),
        );
    Navigator.of(context).pop(); // paneli kapat
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // viewInsets.bottom: klavye yüksekliği. Panel klavyenin üstünde kalsın.
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aşağı çekme tutamağı (ortalı).
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
          Text('Yeni randevu', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          // Önce randevu türünü soruyoruz: tek seçimli iki düğme
          // (Veteriner / Kuaför). En üstte olması, kullanıcının önce ne tür
          // bir randevu aldığına karar vermesini sağlar.
          Text(
            'Randevu türü',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<AppointmentType>(
            segments: const [
              ButtonSegment(
                value: AppointmentType.veteriner,
                label: Text('Veteriner'),
                icon: Icon(Icons.medical_services_outlined),
              ),
              ButtonSegment(
                value: AppointmentType.kuafor,
                label: Text('Kuaför'),
                icon: Icon(Icons.content_cut),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() => _type = selection.first);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Konu',
              hintText: 'Örn. Aşı kontrolü',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _placeController,
            decoration: const InputDecoration(
              labelText: 'Yer / klinik',
              hintText: 'Örn. Patiş Veteriner Kliniği',
            ),
          ),
          const SizedBox(height: 20),
          // Tarih seçici satırı: solda seçilen tarih, sağda "seç" butonu.
          Row(
            children: [
              Expanded(
                child: Text(
                  _dateTime == null
                      ? 'Tarih seçilmedi'
                      : _formatDate(_dateTime!),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _dateTime == null
                        ? AppColors.text.withValues(alpha: 0.5)
                        : AppColors.text,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: const Text('Tarih seç'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Kaydet butonu — tam genişlik.
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
