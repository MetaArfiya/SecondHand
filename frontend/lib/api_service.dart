import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.detail);

  final int statusCode;
  final String detail;
}

class ApiService {
  ApiService._();

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String? get _token => LocalAuthService.accessToken;
  static final ValueNotifier<int> productsChanged = ValueNotifier(0);

  static void notifyProductsChanged() => productsChanged.value++;

  static Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body is Map ? body['detail'] : null;
      throw ApiException(
        response.statusCode,
        detail?.toString() ?? '',
      );
    }
    return body;
  }

  static String humanizeError(Object error) {
    if (error is ApiException) {
      final detail = error.detail.trim();
      switch (error.statusCode) {
        case 401:
          if (detail.toLowerCase().contains('email') &&
              detail.toLowerCase().contains('password')) {
            return 'Email atau kata sandi tidak cocok. Periksa kembali, lalu coba lagi.';
          }
          return 'Sesi login sudah berakhir. Masuk kembali untuk melanjutkan.';
        case 403:
          if (detail.toLowerCase().contains('admin')) {
            return 'Akun ini belum memiliki akses admin. Masuk dengan akun admin untuk melanjutkan.';
          }
          return 'Akun ini tidak memiliki izin untuk melakukan tindakan tersebut.';
        case 404:
          return detail.isNotEmpty
              ? '$detail. Muat ulang halaman dan coba lagi.'
              : 'Data yang dicari tidak ditemukan. Muat ulang halaman dan coba lagi.';
        case 409:
          return detail.isNotEmpty
              ? '$detail Muat ulang data sebelum mencoba lagi.'
              : 'Data sudah berubah atau diproses. Muat ulang halaman lalu coba lagi.';
        case 422:
          return 'Data yang diisi belum sesuai. Periksa kembali kolom dan formatnya.';
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Server sedang mengalami kendala. Coba lagi beberapa saat.';
      }
      if (detail.isNotEmpty) return detail;
      return 'Permintaan gagal diproses (kode ${error.statusCode}). Coba lagi.';
    }

    final message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
    final normalized = message.toLowerCase();
    if (error is TimeoutException ||
        normalized.contains('clientexception') ||
        normalized.contains('failed to fetch') ||
        normalized.contains('xmlhttprequest') ||
        normalized.contains('socketexception') ||
        normalized.contains('connection refused')) {
      return 'Tidak bisa terhubung ke server. Pastikan backend aktif dan perangkat tersambung ke jaringan yang sama, lalu coba lagi.';
    }
    if (error is FormatException) {
      return 'Server mengirim data yang tidak bisa dibaca. Coba muat ulang; jika masih terjadi, periksa backend.';
    }
    if (normalized.contains('token tidak ditemukan') ||
        normalized.contains('token tidak valid')) {
      return 'Sesi login sudah berakhir. Masuk kembali untuk melanjutkan.';
    }
    if (normalized.contains('hanya admin')) {
      return 'Akun ini belum memiliki akses admin. Masuk dengan akun admin untuk melanjutkan.';
    }
    return message.isEmpty
        ? 'Terjadi kendala. Coba lagi.'
        : message;
  }

  static Future<dynamic> _get(
    String path, [
    Map<String, String>? query,
  ]) async => _decode(await http.get(_uri(path, query), headers: _headers));

  static Future<dynamic> _postJson(
    String path,
    Map<String, Object?> data,
  ) async => _decode(
    await http.post(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ),
  );

  static Future<Map<String, dynamic>> _authenticate(
    String path,
    Map<String, Object?> data,
  ) async {
    final result = await _postJson(path, data) as Map<String, dynamic>;
    final token = result['access_token'] as String?;
    if (token == null) throw Exception('Token dari server tidak ditemukan');
    LocalAuthService.accessToken = token;
    final profile = await _get('/api/users/me') as Map<String, dynamic>;
    await LocalAuthService.setSession(
      token: token,
      user: _toLocalUser(profile),
    );
    return profile;
  }

  static LocalUser _toLocalUser(Map<String, dynamic> profile) => LocalUser(
    id: profile['id'] as int,
    name: profile['name'] as String,
    email: profile['email'] as String,
    phone: profile['phone'] as String? ?? '',
    location: profile['location'] as String? ?? '',
    bio: profile['bio'] as String? ?? '',
    avatarUrl: profile['avatar_url'] as String?,
    isAdmin: profile['is_admin'] == true,
  );

  static Future<bool> restoreSession() async {
    final token = await LocalAuthService.storedAccessToken();
    if (token == null || token.isEmpty) return false;
    LocalAuthService.accessToken = token;
    try {
      final profile = await _get('/api/users/me') as Map<String, dynamic>;
      await LocalAuthService.setSession(
        token: token,
        user: _toLocalUser(profile),
      );
      return true;
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('(401)') ||
          message.contains('(403)') ||
          message.contains('token tidak valid')) {
        await LocalAuthService.logout();
      }
      return false;
    }
  }

  static Future<void> login(String email, String password) async {
    await _authenticate('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    await _authenticate('/api/auth/register', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    });
  }

  static Future<String?> requestPasswordReset(String email) async {
    final result =
        await _postJson('/api/auth/forgot-password', {
              'email': email.trim().toLowerCase(),
            })
            as Map<String, dynamic>;
    final data = result['data'];
    return data is Map ? data['dev_token']?.toString() : null;
  }

  static Future<void> resetPassword(String token, String password) async {
    await _postJson('/api/auth/reset-password', {
      'token': token.trim(),
      'new_password': password,
    });
  }

  static Future<String> uploadAvatar(Uint8List bytes, String filename) async {
    final request = http.MultipartRequest('POST', _uri('/api/users/me/avatar'))
      ..headers.addAll(_headers)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
    final response = await http.Response.fromStream(await request.send());
    final result = _decode(response) as Map<String, dynamic>;
    return (result['avatar_url'] ?? '').toString();
  }

  static Future<void> updateSettings({
    bool? allowMessages,
    bool? notifyTransactions,
    bool? notifyPromos,
    String? profileVisibility,
  }) async {
    await _postPatch('/api/users/me/settings', {
      if (allowMessages != null) 'allow_messages': allowMessages,
      if (notifyTransactions != null) 'notify_transactions': notifyTransactions,
      if (notifyPromos != null) 'notify_promos': notifyPromos,
      if (profileVisibility != null) 'profile_visibility': profileVisibility,
    });
  }

  static Future<void> _postPatch(String path, Map<String, Object?> data) async {
    final response = await http.patch(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _decode(response);
  }

  static Future<List<Map<String, dynamic>>> categories() async {
    final result = await _get('/api/categories') as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(result['data'] as List);
  }

  static Future<List<Map<String, dynamic>>> notifications() async {
    final result = await _get('/api/notifications') as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(result['data'] as List);
  }

  static Future<void> markNotificationRead(int id) async {
    final response = await http.patch(
      _uri('/api/notifications/$id/read'),
      headers: _headers,
    );
    _decode(response);
  }

  static Future<List<Map<String, dynamic>>> products({
    bool mine = false,
    String? category,
    String? query,
    String? location,
    String sort = 'newest',
  }) async {
    final result = await _get(
      mine ? '/api/products/me' : '/api/products',
      mine
          ? null
          : {
              if (category != null && category != 'Semua')
                'category': _categorySlug(category),
              if (query != null && query.isNotEmpty) 'q': query,
              if (location != null && location.isNotEmpty) 'location': location,
              'sort': sort,
            },
    );

    final list = mine
        ? result as List
        : (result as Map<String, dynamic>)['items'] as List;

    // --- PERBAIKAN: Konversi String harga ke double otomatis ---
    final mappedList = List<Map<String, dynamic>>.from(list);
    for (var item in mappedList) {
      if (item['price'] != null) {
        item['price'] = double.tryParse(item['price'].toString()) ?? 0.0;
      }
    }
    return mappedList;
  }

  static String _categorySlug(String name) => switch (name) {
    'Mobil' => 'cars',
    'Motor' => 'motors',
    'Sepeda' => 'bicycles',
    'HP' => 'phones',
    _ => name.toLowerCase(),
  };

  static String imageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) return '$baseUrl/$value';
    final configured = Uri.parse(baseUrl);
    return uri
        .replace(
          scheme: configured.scheme,
          host: configured.host,
          port: configured.hasPort ? configured.port : null,
        )
        .toString();
  }

  static Future<Map<String, dynamic>> createProduct({
    required int categoryId,
    required String title,
    required int price,
    required String location,
    required String description,
    required List<Uint8List> photos,
    required List<String> filenames,
  }) async {
    final paths = <String>[];
    for (var i = 0; i < photos.length; i++) {
      final request =
          http.MultipartRequest('POST', _uri('/api/products/images'))
            ..headers.addAll(_headers)
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                photos[i],
                filename: filenames[i],
              ),
            );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final result = _decode(response) as Map<String, dynamic>;
      paths.add((result['data'] as Map<String, dynamic>)['path'] as String);
    }
    final product =
        await _postJson('/api/products', {
              'category_id': categoryId,
              'title': title,
              'price': price,
              'location': location,
              'description': description,
              'image_paths': paths,
            })
            as Map<String, dynamic>;
    notifyProductsChanged();
    return product;
  }

  static Future<Map<String, dynamic>> requestPromotion(
    int productId,
    int days,
  ) async =>
      await _postJson('/api/promotions/request', {
            'product_id': productId,
            'package_days': days,
          })
          as Map<String, dynamic>;

  static Future<Map<String, dynamic>> uploadPaymentProof(
    int paymentId,
    Uint8List bytes,
    String filename,
  ) async {
    final request =
        http.MultipartRequest('POST', _uri('/api/payments/$paymentId/proof'))
          ..headers.addAll(_headers)
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename),
          );
    final response = await http.Response.fromStream(await request.send());
    return _decode(response) as Map<String, dynamic>;
  }

  static Future<void> updateProfile(LocalUser user) async {
    final response = await http.patch(
      _uri('/api/users/me'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': user.name,
        'phone': user.phone,
        'location': user.location,
        'bio': user.bio,
      }),
    );
    _decode(response);
  }

  static Future<List<Map<String, dynamic>>> adminPayments({
    String? status,
  }) async {
    final result = await _get(
      '/api/admin/payments',
      status == null ? null : {'status': status},
    );
    return List<Map<String, dynamic>>.from(result as List);
  }

  static Future<void> decidePayment(
    int paymentId,
    String status, {
    String? note,
  }) async {
    final response = await http.patch(
      _uri('/api/admin/payments/$paymentId'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status, 'admin_note': note}),
    );
    _decode(response);
  }

  static Future<List<Map<String, Object>>> favorites() async {
    final categories = await ApiService.categories();
    final names = {
      for (final category in categories) category['id']: category['name'],
    };
    final response = await _get('/api/favorites') as Map<String, dynamic>;
    return (response['data'] as List).map<Map<String, Object>>((raw) {
      final item = raw as Map<String, dynamic>;
      final images = item['images'] as List? ?? [];
      final image = images.isEmpty
          ? ''
          : (images.first as Map)['url']?.toString() ?? '';
      final rawPrice = num.tryParse(item['price'].toString()) ?? 0;
      final amount = rawPrice.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
      return {
        'id': item['id'] as int,
        'category': names[item['category_id']]?.toString() ?? 'Lainnya',
        'title': item['title'].toString(),
        'price': 'Rp $amount',
        'location': (item['location'] ?? '').toString(),
        'time': 'BARU',
        'image': image.isEmpty ? '' : imageUrl(image),
        'gallery': images
            .map((image) => imageUrl((image as Map)['url'].toString()))
            .toList(),
        'featured': item['is_promoted'] == true,
        'condition': 'Bekas',
        'description': (item['description'] ?? '').toString(),
        'seller': (item['seller_name'] ?? 'Pengguna SecondHand').toString(),
        'phone': (item['seller_phone'] ?? '').toString(),
      };
    }).toList();
  }

  static Future<void> setFavorite(int productId, bool favorite) async {
    final uri = _uri('/api/favorites/$productId');
    final response = favorite
        ? await http.post(uri, headers: _headers)
        : await http.delete(uri, headers: _headers);
    _decode(response);
  }

  static Future<void> logout() async {
    await LocalAuthService.logout();
  }
}
