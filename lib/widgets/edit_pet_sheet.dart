import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';

/// Hayvanın künyesini (ad, tür, cins, mikroçip…) eklemek/düzenlemek için alttan
/// açılan form. Kaydedince [PassportStore]'a yazar; değişiklik ana ekran +
/// pasaport ekranında anında görünür ve kalıcıdır.
///
/// [isNew] true ise yeni bir dost ekler (boş form, "Ekle"); false ise seçili
/// hayvanı düzenler (dolu form, "Kaydet" + birden çok hayvan varsa "Sil").
class EditPetSheet extends StatelessWidget {
  const EditPetSheet({super.key, this.isNew = false});

  final bool isNew;

  /// Formu modal alt sayfa olarak gösterir.
  static Future<void> show(BuildContext context, {bool isNew = false}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => EditPetSheet(isNew: isNew),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _EditPetForm(isNew: isNew);
  }
}

class _EditPetForm extends StatefulWidget {
  const _EditPetForm({required this.isNew});

  final bool isNew;

  @override
  State<_EditPetForm> createState() => _EditPetFormState();
}

class _EditPetFormState extends State<_EditPetForm> {
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _breed;
  late final TextEditingController _ageLabel;
  late final TextEditingController _birthDate;
  late final TextEditingController _color;
  late final TextEditingController _microchip;
  late final TextEditingController _registrationNo;

  // Cinsiyet sınırlı seçenekli olduğundan ayrı tutulur (künyedeki ikon buna
  // bağlı). null = belirtilmemiş.
  String? _gender;

  @override
  void initState() {
    super.initState();
    // Yeni ekleme modunda boş form; düzenlemede seçili hayvandan doldur.
    final pet = widget.isNew ? null : context.read<PassportStore>().pet;
    _name = TextEditingController(text: pet?.name ?? '');
    _species = TextEditingController(text: pet?.species ?? '');
    _breed = TextEditingController(text: pet?.breed ?? '');
    _ageLabel = TextEditingController(text: pet?.ageLabel ?? '');
    _birthDate = TextEditingController(text: pet?.birthDateLabel ?? '');
    _color = TextEditingController(text: pet?.colorLabel ?? '');
    _microchip = TextEditingController(text: pet?.microchip ?? '');
    _registrationNo = TextEditingController(text: pet?.registrationNo ?? '');
    _gender = pet?.gender;
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    _ageLabel.dispose();
    _birthDate.dispose();
    _color.dispose();
    _microchip.dispose();
    _registrationNo.dispose();
    super.dispose();
  }

  /// Form alanlarından bir [Pet] üretir; boş bırakılan isteğe bağlı alanlar
  /// null olur ki künyede boş satır görünmesin.
  Pet _buildPet() {
    String? clean(String s) => s.trim().isEmpty ? null : s.trim();
    return Pet(
      name: _name.text.trim(),
      breed: _breed.text.trim(),
      ageLabel: _ageLabel.text.trim(),
      species: clean(_species.text),
      gender: _gender,
      birthDateLabel: clean(_birthDate.text),
      colorLabel: clean(_color.text),
      microchip: clean(_microchip.text),
      registrationNo: clean(_registrationNo.text),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dostunun adını gir')),
      );
      return;
    }

    final store = context.read<PassportStore>();
    final pet = _buildPet();
    if (widget.isNew) {
      store.addPet(pet);
    } else {
      store.updatePet(pet);
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isNew ? '${pet.name} eklendi' : 'Hayvan bilgileri güncellendi',
        ),
      ),
    );
  }

  void _confirmDelete() async {
    final store = context.read<PassportStore>();
    final name = store.pet.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hayvanı sil'),
        content: Text(
          '$name ve tüm sağlık kayıtları silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      store.deletePet(store.selectedId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // Birden çok hayvan varsa düzenleme modunda silmeye izin ver.
    final canDelete =
        !widget.isNew && context.watch<PassportStore>().pets.length > 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isNew ? 'Yeni dost ekle' : 'Hayvan bilgileri',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (canDelete)
                  IconButton(
                    onPressed: _confirmDelete,
                    tooltip: 'Hayvanı sil',
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.terracotta),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _field(_name, 'Ad', Icons.pets, cap: TextCapitalization.words),
            const SizedBox(height: 12),
            _field(_species, 'Tür (örn. Kedi)', Icons.category_outlined,
                cap: TextCapitalization.words),
            const SizedBox(height: 12),
            _field(_breed, 'Cins', Icons.fingerprint,
                cap: TextCapitalization.words),
            const SizedBox(height: 12),
            // ---- Cinsiyet ----
            Text('Cinsiyet', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _genderChip('Dişi', Icons.female),
                _genderChip('Erkek', Icons.male),
              ],
            ),
            const SizedBox(height: 12),
            _field(_ageLabel, 'Yaş (örn. 2 yaşında)', Icons.cake_outlined),
            const SizedBox(height: 12),
            _field(_birthDate, 'Doğum tarihi (örn. 14 Mart 2024)',
                Icons.event_outlined),
            const SizedBox(height: 12),
            _field(_color, 'Renk / desen', Icons.palette_outlined,
                cap: TextCapitalization.words),
            const SizedBox(height: 12),
            _field(_microchip, 'Mikroçip no', Icons.memory),
            const SizedBox(height: 12),
            _field(_registrationNo, 'Kayıt / pasaport no', Icons.badge_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(widget.isNew ? 'Ekle' : 'Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextCapitalization cap = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: cap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  /// Seçilebilir cinsiyet etiketi; tekrar dokununca seçim kaldırılır.
  Widget _genderChip(String value, IconData icon) {
    final selected = _gender == value;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.cream : AppColors.forest,
      ),
      label: Text(value),
      selected: selected,
      selectedColor: AppColors.forest,
      labelStyle: TextStyle(
        color: selected ? AppColors.cream : AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => setState(() => _gender = selected ? null : value),
    );
  }
}
