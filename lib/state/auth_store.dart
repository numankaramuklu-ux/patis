import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';

/// Oturum açan kullanıcının temel bilgilerini tutan "depo" (store).
///
/// Kayıt/giriş ekranı buraya kullanıcının adını, e-postasını ve seçtiği rolü
/// yazar. Diğer ekranlar `context.watch<AuthStore>()` ile bunlara erişip role
/// göre arayüzü değiştirebilir.
///
/// Oturum `shared_preferences` ile cihazda saklanır: uygulama kapatılıp
/// yeniden açıldığında en son giriş geri yüklenir, kullanıcı tekrar giriş
/// yapmak zorunda kalmaz. (İleride Firebase Auth'a taşınabilir.)
class AuthStore extends ChangeNotifier {
  AuthStore() {
    _load();
  }

  // shared_preferences anahtarları.
  static const _kName = 'auth_name';
  static const _kEmail = 'auth_email';
  static const _kRole = 'auth_role'; // UserRole.index olarak saklanır
  static const _kBusiness = 'auth_business';

  String? _name;
  String? _email;
  UserRole? _role;
  String? _businessName;

  // Kayıtlı oturum diskten okunana kadar false. Auth gate bunu bekleyip
  // bu sırada bir açılış (splash) ekranı gösterir; aksi halde önce kayıt
  // ekranı, sonra ana ekran "sıçraması" yaşanır.
  bool _ready = false;

  String? get name => _name;
  String? get email => _email;
  UserRole? get role => _role;
  String? get businessName => _businessName;

  /// Kayıtlı oturum diskten yüklendi mi? Auth gate bunu bekler.
  bool get isReady => _ready;

  /// Oturum açık mı? Rol doluysa kullanıcı içeri girmiş demektir.
  bool get isLoggedIn => _role != null;

  /// Uygulama açılışında kayıtlı oturumu diskten geri yükler.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final roleIndex = prefs.getInt(_kRole);
    if (roleIndex != null &&
        roleIndex >= 0 &&
        roleIndex < UserRole.values.length) {
      _role = UserRole.values[roleIndex];
      _name = prefs.getString(_kName);
      _email = prefs.getString(_kEmail);
      _businessName = prefs.getString(_kBusiness);
    }
    _ready = true;
    notifyListeners();
  }

  /// Geçerli oturumu diske yazar.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRole, _role!.index);
    await _setOrRemove(prefs, _kName, _name);
    await _setOrRemove(prefs, _kEmail, _email);
    await _setOrRemove(prefs, _kBusiness, _businessName);
  }

  Future<void> _setOrRemove(
      SharedPreferences prefs, String key, String? value) async {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }

  /// Kullanıcı kayıt olduğunda oturumu doldurur ve diske yazar.
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
    _persist();
  }

  /// Mevcut hesapla giriş. Backend olmadığından kullanıcıyı doğrulayamıyoruz;
  /// e-posta/şifre alınır ve rol seçimine göre oturum doldurulur. Ad verilmezse
  /// e-postanın baş kısmından türetilir. İleride Firebase Auth'a bağlanacak.
  void login({
    required String email,
    required UserRole role,
    String? name,
    String? businessName,
  }) {
    _email = email;
    _role = role;
    _name = (name == null || name.isEmpty) ? email.split('@').first : name;
    _businessName = role.isBusiness ? businessName : null;
    notifyListeners();
    _persist();
  }

  /// Profil ekranından ad/e-posta/işletme adını günceller ve diske yazar.
  /// Verilmeyen (null) alanlar olduğu gibi korunur.
  void updateProfile({
    String? name,
    String? email,
    String? businessName,
  }) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    // İşletme adı yalnızca hizmet veren rollerde anlamlı.
    if (businessName != null && (_role?.isBusiness ?? false)) {
      _businessName = businessName;
    }
    notifyListeners();
    _persist();
  }

  /// Oturumu kapatır; diskteki kayıtlı oturumu da siler.
  void logout() {
    _name = null;
    _email = null;
    _role = null;
    _businessName = null;
    notifyListeners();
    _clear();
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kRole);
    await prefs.remove(_kBusiness);
  }
}
