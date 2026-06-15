import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_profile.dart';
import '../models/user_role.dart';
import '../state/auth_store.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_pet_sheet.dart';

/// Kullanıcının hesap (profil) ekranı.
///
/// Ana ekrandaki profil düğmesinden açılır. Kullanıcının adını, e-postasını,
/// rolünü ve (işletme rollerinde) işletme adını gösterir; bilgileri düzenlemeye
/// ve oturumu kapatmaya izin verir. Düzenleme [AuthStore.updateProfile] ile
/// yapılır ve `shared_preferences` sayesinde kalıcıdır.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthStore>();
    final role = auth.role ?? UserRole.kullanici;
    final displayName = auth.name ?? 'Kullanıcı';
    final email = auth.email ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Üst kart: avatar + ad + rol rozeti ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.cream.withValues(alpha: 0.15),
                    child: Icon(role.icon, color: AppColors.cream, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cream.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Bilgi satırları ----
            Text('Hesap bilgileri', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.person_outline,
              label: 'Ad Soyad',
              value: displayName,
            ),
            if (role.isBusiness) ...[
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.storefront_outlined,
                label: role == UserRole.veteriner ? 'Klinik adı' : 'İşletme adı',
                value: auth.businessName ?? '—',
              ),
            ],
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.mail_outline,
              label: 'E-posta',
              value: email,
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.badge_outlined,
              label: 'Hesap türü',
              value: role.label,
            ),
            const SizedBox(height: 24),

            // ---- Dostlarım (yalnızca hayvan sahibi rolünde) ----
            if (role == UserRole.kullanici) ...[
              Text('Dostlarım', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              const _PetList(),
              const SizedBox(height: 24),
            ],

            // ---- Aksiyonlar ----
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openEditSheet(context, auth, role),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Bilgileri düzenle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forest,
                  side: BorderSide(color: AppColors.forest.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış yap'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgileri düzenlemek için alttan açılan form.
  void _openEditSheet(BuildContext context, AuthStore auth, UserRole role) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _EditProfileSheet(role: role),
    );
  }

  /// Çıkış öncesi onay sorar; onaylanırsa oturumu kapatır. Auth gate, çıkış
  /// sonrası otomatik olarak kayıt ekranına döner.
  void _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Oturumu kapatmak istediğine emin misin?'),
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
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthStore>().logout();
    }
  }
}

/// Profildeki tüm dostların listesi + "yeni dost ekle".
/// [PassportStore]'u dinler; ekleme/silme/düzenleme anında yansır.
class _PetList extends StatelessWidget {
  const _PetList();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PassportStore>();
    return Column(
      children: [
        for (final profile in store.pets) ...[
          _PetRow(
            profile: profile,
            selected: profile.id == store.selectedId,
            // Satıra dokununca o dostu aktif yapar.
            onTap: () => store.selectPet(profile.id),
            // Düzenle: önce aktif yap, sonra düzenleme formunu aç (form daima
            // seçili hayvanı düzenler).
            onEdit: () {
              store.selectPet(profile.id);
              EditPetSheet.show(context);
            },
          ),
          const SizedBox(height: 10),
        ],
        _AddPetTile(onTap: () => EditPetSheet.show(context, isNew: true)),
      ],
    );
  }
}

/// Listedeki tek bir dost satırı: avatar + ad + cins/yaş, seçili rozeti ve
/// düzenleme butonu.
class _PetRow extends StatelessWidget {
  const _PetRow({
    required this.profile,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final PetProfile profile;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pet = profile.pet;
    final path = profile.photoPath;
    final subtitleParts = [
      if (pet.species != null) pet.species!,
      pet.breed,
      pet.ageLabel,
    ].where((s) => s.isNotEmpty);
    return Material(
      color: selected ? AppColors.forest.withValues(alpha: 0.06) : AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.forest
                  : AppColors.text.withValues(alpha: 0.08),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.forest.withValues(alpha: 0.1),
                  image: path != null
                      ? DecorationImage(
                          image: FileImage(File(path)), fit: BoxFit.cover)
                      : null,
                ),
                child: path == null
                    ? const Icon(Icons.pets, color: AppColors.forest)
                    : null,
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
                            pet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle,
                              size: 16, color: AppColors.forest),
                        ],
                      ],
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Düzenle',
                icon: Icon(Icons.edit_outlined,
                    color: AppColors.forest.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Yeni dost ekle" satırı (kesik çerçeveli, dikkat çekici).
class _AddPetTile extends StatelessWidget {
  const _AddPetTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.forest.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.forest.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: AppColors.forest, size: 20),
              const SizedBox(width: 8),
              Text(
                'Yeni dost ekle',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.forest,
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

/// Tek bir bilgi satırı (ikon + etiket + değer).
class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.forest, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profil bilgilerini düzenleme formu (alttan açılan sayfa).
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.role});

  final UserRole role;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _businessController;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthStore>();
    _nameController = TextEditingController(text: auth.name ?? '');
    _emailController = TextEditingController(text: auth.email ?? '');
    _businessController =
        TextEditingController(text: auth.businessName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final business = _businessController.text.trim();

    if (name.isEmpty) {
      _showError('Ad boş olamaz');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Geçerli bir e-posta adresi gir');
      return;
    }
    if (widget.role.isBusiness && business.isEmpty) {
      _showError('İşletme/klinik adını gir');
      return;
    }

    context.read<AuthStore>().updateProfile(
          name: name,
          email: email,
          businessName: widget.role.isBusiness ? business : null,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bilgiler güncellendi')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVet = widget.role == UserRole.veteriner;
    // Klavye açılınca form yukarı kaysın diye alt boşluğu klavye yüksekliğine
    // göre ayarlıyoruz.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
          Text('Bilgileri düzenle', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          if (widget.role.isBusiness) ...[
            TextField(
              controller: _businessController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isVet ? 'Klinik adı' : 'İşletme adı',
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
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
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
