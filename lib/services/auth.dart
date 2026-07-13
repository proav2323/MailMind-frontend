import 'package:MailMind/models/user.dart';
import 'package:MailMind/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:developer';

final GoogleSignIn googleSignIn = GoogleSignIn.instance;

final scopes = [
  'email',
  'profile',
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/gmail.modify',
  'https://www.googleapis.com/auth/gmail.send',
];

final userProvider = FutureProvider<USER?>((ref) async {
  return auth(true, null);
}, retry: (retryCount, error) {});

Future<USER> auth(bool firstTime, String? token) async {
  if (firstTime == false) {
    await setCustomCookie(Uri.parse(BACKEND_URL + "/auth/"), token!, "token");
  }
  return getUserProfile();
}

Future<void> loginWithGoogle(BuildContext context) async {
  await googleSignIn.initialize(
    clientId: Platform.isAndroid
        ? "954214301039-tmkatt15fvvdgb73rohcmcm3vu0s11df.apps.googleusercontent.com"
        : Platform.isIOS
        ? "954214301039-t7tvo7h1denqb7mdhg832etpsaop9ni5.apps.googleusercontent.com"
        : Platform.isWindows || Platform.isMacOS || Platform.isLinux
        ? "954214301039-sqn057nkl3p0uemog300fpigblhlap2c.apps.googleusercontent.com"
        : "954214301039-h68aeiokkdhp57efvrq98k90csj502gs.apps.googleusercontent.com",
    serverClientId:
        "954214301039-s0ja0vfk1uvu9mqvpndoatnvvjtdg8ea.apps.googleusercontent.com",
  );
  var user = await googleSignIn.authenticate(scopeHint: scopes);

  final authorization = await user.authorizationClient.authorizationForScopes(
    scopes,
  );
  String accessToken;

  if (authorization != null) {
    accessToken = authorization.accessToken;
  } else {
    final auth = await user.authorizationClient.authorizeScopes(scopes);
    accessToken = auth.accessToken;
  }

  await setCustomCookie(
    Uri.parse(BACKEND_URL + "/auth/login/"),
    accessToken,
    "accessToken",
  );

  var res = await login(
    user.displayName != null ? user.displayName! : "no name",
    user.email,
    user.photoUrl != null ? user.photoUrl! : "no photo",
    "google",
    accessToken,
  );
  String token = res.data;

  USER finalUser = await auth(false, token);
  userProvider.overrideWithValue(AsyncValue.data(finalUser));
  context.go('/');
}

Future<void> logoutUser() async {
  await googleSignIn.signOut();
  await logout();
  userProvider.overrideWithValue(AsyncValue.data(null));
}
