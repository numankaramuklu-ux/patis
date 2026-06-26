import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sitter_profile.dart';
import '../state/sitter_profile_store.dart';
import '../theme/app_colors.dart';

/// Pet sitter fiyat kalemi ekleme/düzenleme formu (alttan açılan panel).
///
/// [existing] verilirse o kalemin alanları doldurulur ve kaydedince güncellenir;
/// verilmezse yeni bir kalem oluşturulur. [SitterProfileStore]'a yazılır.
class NewSitterPriceSheet extends StatefulWidget {
  const NewSitterPriceSheet({super.key, this.existing});

  /// Düzenlenecek kalem (null ise yeni ekleme modu).
  final SitterPriceItem? existing;

  static void show(BuildContext context, {SitterPriceItem? existing}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NewSitterPriceSheet(existing: existing),
    );
  }

  @override
  State<NewSitterPriceSheet> createState() => _NewSitterPriceSheetState();
}

class _NewSitterPriceSheetState extends State<NewSitterPriceSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;
  late String _unit;

  // Seçilebilir birimler.
  static const _units = ['gece', 'gün', 'saat', 'yürüyüş', 'ziyaret'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _labelController = TextEditingController(text: s?.label ?? '');
    _priceController =
        TextEditingController(text: s != null ? '${s.price}' : '');
    _noteController = TextEditingController(text: s?.note ?? '');
    // Mevcut birim listede yoksa ilk birime düş.
    _unit = (s != null && _units.contains(s.unit)) ? s.unit : _units.first;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final store = context.read<SitterProfileStore>();
    final label = _labelController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final note = _noteController.text.trim();

    if (label.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hizmet adı ve ücret zorunlu')),
      );
      return;
    }

    if (_isEdit) {
      store.updatePriceItem(
        widget.existing!.copyWith(
          label: label,
          price: price,
          unit: _unit,
          note: note.isEmpty ? null : note,
        ),
      );
    } else {
      store.addPriceItem(
        SitterPriceItem(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          label: label,
          price: price,
          unit: _unit,
          note: note.isEmpty ? null : note,
        ),
      );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label ${_isEdit ? 'güncellendi' : 'eklendi'}')),
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
              _isEdit ? 'Fiyatı düzenle' : 'Yeni fiyat',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Hizmet adı',
                hintText: 'Örn. Gecelik konaklama',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ücret (₺)',
                      hintText: 'Örn. 250',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Birim',
                    ),
                    items: [
                      for (final u in _units)
                        DropdownMenuItem(value: u, child: Text('/$u')),
                    ],
                    onChanged: (v) =>
                        setState(() => _unit = v ?? _units.first),
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
                hintText: 'Örn. Sabah-akşam besleme dahil',
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
                child: Text(_isEdit ? 'Kaydet' : 'Fiyat ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
