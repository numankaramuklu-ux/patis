import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon_appointment.dart';
import '../models/salon_client.dart';
import '../state/salon_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';

/// Yeni salon (kuaför) randevusu oluşturma formu (alttan açılan panel).
///
/// İki mod: kayıtlı bir müşteriyi seç (randevu o müşteriye bağlanır) ya da
/// kayıtsız/yeni müşteri için hayvan ve sahip bilgisini elle gir. Kaydedilince
/// randevu [SalonStore]'a eklenir.
class NewSalonAppointmentSheet extends StatefulWidget {
  const NewSalonAppointmentSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewSalonAppointmentSheet(),
    );
  }

  @override
  State<NewSalonAppointmentSheet> createState() =>
      _NewSalonAppointmentSheetState();
}

class _NewSalonAppointmentSheetState extends State<NewSalonAppointmentSheet> {
  // true = kayıtlı müşteri seç, false = kayıtsız (elle giriş).
  bool _existing = true;
  String? _clientId;

  // Kayıtsız müşteri için elle girilen alanlar.
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ownerController = TextEditingController();

  final _serviceController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  final _priceController = TextEditingController();
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    // Kayıtlı müşteri varsa ilkini varsayılan seç.
    final clients = context.read<SalonStore>().clients;
    if (clients.isNotEmpty) {
      _clientId = clients.first.id;
    } else {
      _existing = false; // hiç müşteri yoksa doğrudan elle giriş
    }
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ownerController.dispose();
    _serviceController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${formatTrDayMonth(dt)}, $hour:$minute';
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final store = context.read<SalonStore>();
    final service = _serviceController.text.trim();

    // Hayvan/sahip bilgisini moda göre belirle.
    String petName;
    String breed;
    String ownerName;
    String? clientId;
    if (_existing) {
      final idx = store.clients.indexWhere((c) => c.id == _clientId);
      if (idx == -1) {
        _error('Lütfen bir müşteri seç');
        return;
      }
      final client = store.clients[idx];
      petName = client.petName;
      breed = client.breed;
      ownerName = client.ownerName;
      clientId = client.id;
    } else {
      petName = _petNameController.text.trim();
      breed = _breedController.text.trim();
      ownerName = _ownerController.text.trim();
      clientId = null;
      if (petName.isEmpty || ownerName.isEmpty) {
        _error('Hayvan adı ve sahip adı zorunlu');
        return;
      }
    }

    if (service.isEmpty || _dateTime == null) {
      _error('Hizmet ve tarih/saat gir');
      return;
    }

    final dt = _dateTime!;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    store.addAppointment(
      SalonAppointment(
        id: 's${DateTime.now().millisecondsSinceEpoch}',
        clientId: clientId,
        petName: petName,
        breed: breed,
        ownerName: ownerName,
        service: service,
        durationMin: int.tryParse(_durationController.text.trim()) ?? 60,
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        date: DateTime(dt.year, dt.month, dt.day),
        time: time,
        status: SalonApptStatus.bekliyor,
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$petName için randevu eklendi')),
    );
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clients = context.read<SalonStore>().clients;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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
            Text('Yeni randevu', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Müşteri kaynağı: kayıtlı / kayıtsız.
            if (clients.isNotEmpty) ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Kayıtlı müşteri'),
                    icon: Icon(Icons.people_alt_outlined),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Yeni / kayıtsız'),
                    icon: Icon(Icons.person_add_alt),
                  ),
                ],
                selected: {_existing},
                onSelectionChanged: (s) => setState(() => _existing = s.first),
              ),
              const SizedBox(height: 16),
            ],

            // Müşteri seçimi (kayıtlı) ya da elle giriş (kayıtsız).
            if (_existing)
              DropdownButtonFormField<String>(
                initialValue: _clientId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Müşteri',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: [
                  for (final SalonClient c in clients)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.petName} • ${c.ownerName}'),
                    ),
                ],
                onChanged: (v) => setState(() => _clientId = v),
              )
            else ...[
              TextField(
                controller: _petNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Hayvan adı',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _breedController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cins',
                  prefixIcon: Icon(Icons.fingerprint),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ownerController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Sahip adı',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ],
            const SizedBox(height: 16),

            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Hizmet',
                hintText: 'Örn. Tıraş & Banyo',
                prefixIcon: Icon(Icons.content_cut),
              ),
            ),
            const SizedBox(height: 20),

            // Tarih/saat seçici.
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dateTime == null
                        ? 'Tarih / saat seçilmedi'
                        : _formatDateTime(_dateTime!),
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
            const SizedBox(height: 16),

            // Süre + ücret yan yana.
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Süre (dk)',
                      hintText: '60',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ücret (₺)',
                      hintText: 'Örn. 450',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Randevu oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
