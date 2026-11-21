import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUser {
  const LocalUser({
    this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.location = 'Jakarta Selatan',
    this.bio = '',
    this.avatarBytes,
    this.avatarUrl,
    this.avatarFilename,
    this.isAdmin = false,
  });

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String bio;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final String? avatarFilename;
  final bool isAdmin;
}

/// Menyimpan token sesi API dan profil aktif untuk dipakai UI.
class LocalAuthService {
  LocalAuthService._();

  static final Map<String, ({LocalUser user, String password})> _accounts = {};
  static LocalUser? currentUser;
  static final ValueNotifier<LocalUser?> userUpdates = ValueNotifier(null);
  static String get displayName => currentUser?.name ?? 'Pengguna SecondHand';
  static String? accessToken;

  static Future<void> setSession({
    required String token,
    required LocalUser user,
  }) async {
    accessToken = token;
    _setCurrentUser(user);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('access_token', token);
  }

  static Future<String?> storedAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('access_token');
  }

  static void updateCurrentUserProfile(LocalUser profile) {
    final user = currentUser;
    if (user == null) return;
    final updatedUser = LocalUser(
      name: profile.name.trim(),
      id: user.id,
      email: user.email,
      phone: profile.phone.trim(),
      location: profile.location.trim(),
      bio: profile.bio.trim(),
      avatarBytes: profile.avatarBytes,
      avatarUrl: profile.avatarUrl,
      avatarFilename: profile.avatarFilename,
      isAdmin: user.isAdmin,
    );
    _setCurrentUser(updatedUser);
    final account = _accounts[user.email];
    if (account != null) {
      _accounts[user.email] = (user: updatedUser, password: account.password);
    }
  }

  static String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }

    final user = LocalUser(name: name.trim(), email: normalizedEmail);
    _accounts[normalizedEmail] = (user: user, password: password);
    _setCurrentUser(user);
    return null;
  }

  static String? login({required String email, required String password}) {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    }
    if (account.password != password) {
      return 'Kata sandi tidak sesuai.';
    }

    _setCurrentUser(account.user);
    return null;
  }

  static String? resetPassword({
    required String email,
    required String newPassword,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];
    if (account == null) {
      return 'Akun dengan email tersebut tidak ditemukan.';
    }

    _accounts[normalizedEmail] = (user: account.user, password: newPassword);
    return null;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('access_token');
    accessToken = null;
    _setCurrentUser(null);
  }

  static void _setCurrentUser(LocalUser? user) {
    currentUser = user;
    userUpdates.value = user;
  }
}
