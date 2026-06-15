import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../state/auth_store.dart';
import '../theme/app_colors.dart';

/// Mevcut hesapla giriş ekranı.
///
/// Kayıt ekranındaki "Zaten hesabın var mı? Giriş yap" bağlantısından açılır.
/// Henüz bir backend (Firebase Auth) olmadığı için kullanıcıyı gerçekten
/// doğrulayamıyoruz; bu yüzden e-posta/şifrenin yanında hesap türünü de
/// seçtiriyoruz ki uygulama doğru rolle açılsın. Giriş tamamlanınca oturumu
/// [AuthStore]'a yazar ve kendini kapatır — ana ekrana geçişi auth gate yapar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessController = TextEditingController();

  UserRole _role = UserRole.kullanici;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  /// Formu doğrular; geçerliyse oturumu doldurur ve ekranı kapatır.
  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final business = _businessController.text.trim();

    if (email.isEmpty || password.length < 6) {
      _showError('Lütfen e-posta ve en az 6 haneli şifre gir');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Geçerli bir e-posta adresi gir');
      return;
    }
    if (_role.isBusiness && business.isEmpty) {
      _showError('İşletme/klinik adını gir');
      return;
    }

    context.read<AuthStore>().login(
          email: email,
          role: _role,
          businessName: _role.isBusiness ? business : null,
        );

    // Bu ekran kayıt ekranının üzerine push edilmişti; kendini kapatınca
    // alttaki auth gate yeniden çizilir ve ana ekran görünür.
    Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
            Text('Tekrar hoş geldin', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Patiş hesabınla giriş yap.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Hesap türü (backend gelene kadar elle seçiliyor) ----
            Text('Hesap türü', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<UserRole>(
              segments: [
                for (final role in UserRole.values)
                  ButtonSegment(
                    value: role,
                    icon: Icon(role.icon, size: 18),
                    tooltip: role.label,
                  ),
              ],
              selected: {_role},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _role = selection.first),
            ),
            const SizedBox(height: 6),
            Text(
              _role.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Bilgiler ----
            // İşletme adı: yalnızca kuaför/veteriner seçiliyse görünür.
            if (_role.isBusiness) ...[
              TextField(
                controller: _businessController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _role == UserRole.veteriner
                      ? 'Klinik adı'
                      : 'Salon / işletme adı',
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
              onSubmitted: (_) => _submit(),
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

            // ---- Giriş butonu ----
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Giriş yap'),
              ),
            ),
            const SizedBox(height: 12),
            // Hesabı olmayan için kayıt ekranına dön.
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hesabın yok mu? Kayıt ol'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
