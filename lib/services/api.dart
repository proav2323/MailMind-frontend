import 'dart:developer';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MailMind/models/user.dart';
import 'package:dio/browser.dart'; // Web-specific adapter
import 'package:web/web.dart' as web;

late Dio _dio;
PersistCookieJar? _cookieJar;
final BACKEND_URL = 'https://mailmind-backend.vercel.app';
// final BACKEND_URL = 'http://10.0.2.2:3000';

Future<void> initApi() async {
  _dio = Dio(BaseOptions(baseUrl: BACKEND_URL));

  if (kIsWeb || Platform.isWindows) {
    final adapter = BrowserHttpClientAdapter();
    adapter.withCredentials = true;

    _dio.httpClientAdapter = adapter;
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';

    var _cookieJarr = PersistCookieJar(
      storage: FileStorage(cookiePath),
      ignoreExpires: false,
    );
    _cookieJar = _cookieJarr;

    _dio.interceptors.add(CookieManager(_cookieJar!));
  }
}

Future<Response> login(
  String name,
  String email,
  String photoUrl,
  String oAuthProvider,
  String accessToken,
) async {
  if (_cookieJar == null) {
    await initApi();
  }
  _dio.options.headers['Content-Type'] = 'application/json';
  final res = await _dio.post(
    '/auth/login',
    data: {
      "name": name,
      "email": email,
      "photoUrl": photoUrl,
      "oAuthProvider": oAuthProvider,
      "accessToken": accessToken,
    },
  );

  return res;
}

Future<USER> getUserProfile() async {
  if (_cookieJar == null) {
    await initApi();
  }
  final response = await _dio.get('/auth');
  return USER.fromJson(response.data!);
}

Future<List<Cookie>> getCookies(Uri url) async {
  if (_cookieJar == null) {
    await initApi();
  }
  if (kIsWeb || Platform.isWindows) {
    final Map<String, String> cookieMap = {};

    // Access the document object via the window context
    final String cookieString = web.window.document.cookie;

    if (cookieString.isEmpty) {
      return [];
    }

    final List<String> cookiesS = cookieString.split(';');
    List<Cookie> cookies = [];
    cookiesS.forEach((cookie) {
      final List<String> parts = cookie.split('=');
      if (parts.length >= 2) {
        final String key = parts[0].trim();
        // Join remaining elements in case the value contains '=' signs
        final String value = parts.sublist(1).join('=').trim();
        cookies.add(
          Cookie(key, value)
            ..domain = BACKEND_URL
            ..path = "/"
            ..httpOnly = false,
        );
      }
    });
    return cookies;
  } else {
    return await _cookieJar!.loadForRequest(url);
  }
}

// Manually store a brand new cookie
Future<void> setCustomCookie(
  Uri url,
  String value,
  String name,
  int days,
) async {
  if (_cookieJar == null) {
    await initApi();
  }
  if (kIsWeb || Platform.isWindows) {
    final expires = DateTime.now().add(Duration(days: days)).toUtc();

    // Construct cookie string
    web.document.cookie =
        "$name=$value; expires=${expires.toIso8601String()}; Domain=${BACKEND_URL + url.path}; Path=/; SameSite=Lax; Secure";
  } else {
    List<Cookie> cookies = [
      Cookie(name, value)
        ..domain = BACKEND_URL
        ..path = "/"
        ..httpOnly = false,
    ];
    await _cookieJar!.saveFromResponse(url, cookies);
  }
}

// Delete all stored cookies (Useful for Logging Out)
Future<void> clearAllCookies() async {
  if (_cookieJar == null) {
    await initApi();
  }
  await _cookieJar!.deleteAll();
}

Future<void> logout() async {
  if (_cookieJar == null) {
    await initApi();
  }
  await _dio.put("");
  await clearAllCookies();
}
