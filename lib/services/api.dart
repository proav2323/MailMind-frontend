import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MailMind/models/user.dart';

late Dio _dio;
late PersistCookieJar _cookieJar;
final BACKEND_URL = 'https://mailmind-backend.vercel.app';
// final BACKEND_URL = 'http://10.0.2.2:3000';

Future<void> initApi() async {
  _dio = Dio(BaseOptions(baseUrl: BACKEND_URL));

  // 1. Get a safe directory on the device to save cookie files
  final directory = await getApplicationDocumentsDirectory();
  final cookiePath = '${directory.path}/.cookies/';

  // 2. Initialize the persistent cookie jar
  _cookieJar = PersistCookieJar(
    storage: FileStorage(cookiePath),
    ignoreExpires: false, // Set to true if you want to bypass expiration dates
  );

  // 3. Attach the CookieManager interceptor to Dio
  _dio.interceptors.add(CookieManager(_cookieJar));
}

Future<Response> login(
  String name,
  String email,
  String photoUrl,
  String oAuthProvider,
  String accessToken,
) async {
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
  final response = await _dio.get('/auth');
  return USER.fromJson(response.data!);
}

Future<List<Cookie>> getCookies(Uri url) async {
  return await _cookieJar.loadForRequest(url);
}

// Manually store a brand new cookie
Future<void> setCustomCookie(Uri url, String value, String name) async {
  List<Cookie> cookies = [
    Cookie(name, value)
      ..domain = BACKEND_URL
      ..path = "/"
      ..httpOnly = true,
  ];
  await _cookieJar.saveFromResponse(url, cookies);
}

// Delete all stored cookies (Useful for Logging Out)
Future<void> clearAllCookies() async {
  await _cookieJar.deleteAll();
}

Future<void> logout() async {
  await _dio.put("");
  await clearAllCookies();
}
