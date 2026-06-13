import 'package:flutter/foundation.dart';

import '../models/user_role.dart';

/// Oturum açan kullanıcının temel bilgilerini tutan "depo" (store).
///
/// Kayıt ekranı buraya kullanıcının adını, e-postasını ve seçtiği rolü yazar.
/// Diğer ekranlar `context.watch<AuthStore>()` ile bunlara erişip role göre
/// arayüzü değiştirebilir. Şimdilik bellekte; ileride Firebase Auth'a bağlanacak.
class AuthStore extends ChangeNotifier {
  String? _name;
  String? _email;
  UserRole? _role;
  String? _businessName;

  String? get name => _name;
  String? get email => _email;
  UserRole? get role => _role;
  String? get businessName => _businessName;

  /// Kullanıcı kayıt olduğunda oturumu doldurur.
  void register({
    required String name,
    required String email,
    required UserRole role,
    String? businessName,
  }) {
    _name = name;
    _email = email;
    _role = role;
    _businessName = businessName;
    notifyListeners();
  }
}
