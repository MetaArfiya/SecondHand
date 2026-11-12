import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class LocalUser {
  const LocalUser({
    required this.name,
    required this.email,
    this.phone = '',
    this.location = 'Jakarta Selatan',
    this.bio = '',
    this.avatarBytes,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String bio;
  final Uint8List? avatarBytes;
}

/// Autentikasi sementara untuk prototipe front end.
/// Akun hanya tersimpan di memori dan hilang saat aplikasi ditutup.
class LocalAuthService {
  LocalAuthService._();

  static final Map<String, ({LocalUser user, String password})> _accounts = {};
  static LocalUser? currentUser;
  static final ValueNotifier<LocalUser?> userUpdates = ValueNotifier(null);
  static String get displayName =>
      currentUser?.name ?? 'Pengguna SecondHand';

  static void updateCurrentUserProfile(LocalUser profile) {
    final user = currentUser;
    if (user == null) return;
    final updatedUser = LocalUser(
      name: profile.name.trim(),
      email: user.email,
      phone: profile.phone.trim(),
      location: profile.location.trim(),
      bio: profile.bio.trim(),
      avatarBytes: profile.avatarBytes,
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

    _accounts[normalizedEmail] = (
      user: account.user,
      password: newPassword,
    );
    return null;
  }

  static void logout() => _setCurrentUser(null);

  static void _setCurrentUser(LocalUser? user) {
    currentUser = user;
    userUpdates.value = user;
  }
}
