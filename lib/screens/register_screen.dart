import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../state/auth_store.dart';
import '../theme/app_colors.dart';
import 'main_scaffold.dart';

/// Kayıt oluşturma ekranı (uygulamanın açılış akışı).
///
/// Kullanıcıya önce "ne tür bir hesap" açmak istediğini sorar: evcil hayvan
/// sahibi mi, pet kuaförü mü, yoksa veteriner mi. Ardından ad/e-posta/şifre
/// alır. Hizmet veren roller (kuaför/veteriner) için ek olarak işletme adı
/// ister. Kayıt tamamlanınca bilgileri [AuthStore]'a yazıp ana ekrana geçer.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessController = TextEditingController();

  // Varsayılan olarak en yaygın rol seçili gelir.
  UserRole _role = UserRole.kullanici;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  /// Formu doğrular; geçerliyse oturumu doldurur ve ana ekrana geçer.
  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final business = _businessController.text.trim();

    // Basit doğrulama: ad, e-posta ve en az 6 karakter şifre zorunlu.
    if (name.isEmpty || email.isEmpty || password.length < 6) {
      _showError('Lütfen ad, e-posta ve en az 6 haneli şifre gir');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Geçerli bir e-posta adresi gir');
      return;
    }
    // Hizmet veren roller için işletme adı da zorunlu.
    if (_role.isBusiness && business.isEmpty) {
      _showError('İşletme/klinik adını gir');
      return;
    }

    context.read<AuthStore>().register(
          name: name,
          email: email,
          role: _role,
          businessName: _role.isBusiness ? business : null,
        );

    // Kayıt ekranını geçmişten çıkararak ana ekrana geç (geri tuşuyla dönülmesin).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            // ---- Üst başlık ----
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.forest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: AppColors.cream, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Aramıza katıl', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Patiş hesabını oluştur. Önce seni nasıl tanıyalım?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Rol seçimi ----
            Text('Hesap türü', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final role in UserRole.values) ...[
              _RoleCard(
                role: role,
                selected: _role == role,
                onTap: () => setState(() => _role = role),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),

            // ---- Bilgiler ----
            Text('Bilgilerin', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                hintText: 'Örn. Ayşe Yılmaz',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            // İşletme adı: yalnızca kuaför/veteriner seçiliyse görünür.
            if (_role.isBusiness) ...[
              TextField(
                controller: _businessController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _role == UserRole.veteriner
                      ? 'Klinik adı'
                      : 'Salon / işletme adı',
                  hintText: _role == UserRole.veteriner
                      ? 'Örn. Pati Veteriner Kliniği'
                      : 'Örn. Minnoş Pet Kuaför',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@eposta.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                hintText: 'En az 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ---- Kayıt butonu ----
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kayıt ol'),
              ),
            ),
            const SizedBox(height: 12),
            // Zaten hesabı olan için kısa yol (şimdilik doğrudan ana ekrana geçer).
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScaffold()),
                ),
                child: const Text('Zaten hesabın var mı? Giriş yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir rol seçeneğini gösteren, dokunulabilir kart.
///
/// Seçiliyken orman yeşili çerçeve + hafif dolgu ve sağda onay ikonu gösterir.
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? AppColors.forest.withValues(alpha: 0.08)
          : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.forest
                  : AppColors.text.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.forest
                      : AppColors.forest.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role.icon,
                  color: selected ? AppColors.cream : AppColors.forest,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.forest
                    : AppColors.text.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
