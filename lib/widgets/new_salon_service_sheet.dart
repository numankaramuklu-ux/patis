import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon_service.dart';
import '../state/salon_store.dart';
import '../theme/app_colors.dart';

/// Salon hizmeti ekleme/düzenleme formu (alttan açılan panel).
///
/// [existing] verilirse o hizmetin alanları doldurulur ve kaydedince güncellenir;
/// verilmezse yeni bir hizmet oluşturulur. Kaydedilince [SalonStore]'a yazılır.
class NewSalonServiceSheet extends StatefulWidget {
  const NewSalonServiceSheet({super.key, this.existing});

  /// Düzenlenecek hizmet (null ise yeni ekleme modu).
  final SalonService? existing;

  static void show(BuildContext context, {SalonService? existing}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NewSalonServiceSheet(existing: existing),
    );
  }

  @override
  State<NewSalonServiceSheet> createState() => _NewSalonServiceSheetState();
}

class _NewSalonServiceSheetState extends State<NewSalonServiceSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameController = TextEditingController(text: s?.name ?? '');
    _durationController =
        TextEditingController(text: s != null ? '${s.durationMin}' : '60');
    _priceController =
        TextEditingController(text: s != null ? '${s.price}' : '');
    _noteController = TextEditingController(text: s?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final store = context.read<SalonStore>();
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final note = _noteController.text.trim();

    if (name.isEmpty || price == null) {
      _error('Hizmet adı ve ücret zorunlu');
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 60;

    if (_isEdit) {
      store.updateService(
        widget.existing!.copyWith(
          name: name,
          durationMin: duration,
          price: price,
          note: note.isEmpty ? null : note,
        ),
      );
    } else {
      store.addService(
        SalonService(
          id: 'sv${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          durationMin: duration,
          price: price,
          note: note.isEmpty ? null : note,
        ),
      );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name ${_isEdit ? 'güncellendi' : 'eklendi'}')),
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
            Text(
              _isEdit ? 'Hizmeti düzenle' : 'Yeni hizmet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Hizmet adı',
                hintText: 'Örn. Tıraş & Banyo',
                prefixIcon: Icon(Icons.content_cut),
              ),
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
                      prefixIcon: Icon(Icons.schedule),
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
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                hintText: 'Örn. Uzun tüylü ırklar için',
                prefixIcon: Icon(Icons.notes),
              ),
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
                child: Text(_isEdit ? 'Kaydet' : 'Hizmet ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
