import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:developer';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/config.dart';
import 'package:mailmind/services/api.dart';

final GoogleSignIn googleSignIn = GoogleSignIn.instance;

final scopes = [
  GmailApi.gmailComposeScope,
  GmailApi.gmailInsertScope,
  GmailApi.gmailReadonlyScope,
  GmailApi.gmailLabelsScope,
  GmailApi.gmailModifyScope,
  GmailApi.gmailMetadataScope,
  GmailApi.gmailSendScope,
  PeopleServiceApi.contactsReadonlyScope,
  PeopleServiceApi.userEmailsReadScope,
  PeopleServiceApi.userinfoProfileScope,
  PeopleServiceApi.userinfoEmailScope,
];

final userProvider = FutureProvider<USER?>((ref) async {
  return auth(true, null);
}, retry: (retryCount, error) {});

Future<USER> auth(bool firstTime, String? token) async {
  if (firstTime == false) {
    await setCustomCookie(
      Uri.parse(BACKEND_URL + "/auth/"),
      token!,
      "token",
      1,
    );
  }
  return getUserProfile();
}

Future<void> loginWithGoogle(BuildContext context) async {
  await googleSignIn.initialize(
    clientId: Platform.isAndroid
        ? CONFIGAPIKEYS.GOOGLE_ANDRIOD_CLIENT_ID
        : Platform.isIOS
        ? CONFIGAPIKEYS.GOOGLE_IOS_CLIENT_ID
        : "",
    serverClientId: CONFIGAPIKEYS.GOOGLE_CLINET_ID,
  );
  var user = await googleSignIn.authenticate(scopeHint: scopes);

  final authorization = await user.authorizationClient.authorizationForScopes(
    scopes,
  );
  String accessToken;
  String? refreshToken;
  List<String> userScopes;

  if (authorization != null) {
    var auth = authorization.authClient(scopes: scopes).credentials;
    refreshToken = auth.refreshToken;
    accessToken = auth.accessToken.data;
    userScopes = auth.scopes;
  } else {
    final auth = await user.authorizationClient.authorizeScopes(scopes);
    var authClient = auth.authClient(scopes: scopes).credentials;
    accessToken = authClient.accessToken.data;
    refreshToken = authClient.refreshToken;
    userScopes = authClient.scopes;
  }

  await setCustomCookie(
    Uri.parse(BACKEND_URL + "/auth/login"),
    accessToken,
    "accessToken",
    1,
  );

  await setCustomCookie(
    Uri.parse(BACKEND_URL + "/auth/login"),
    refreshToken ?? "",
    "refreshToken",
    1,
  );

  var res = await login(
    user.displayName != null ? user.displayName! : "no name",
    user.email,
    user.photoUrl != null ? user.photoUrl! : "no photo",
    "google",
    accessToken,
    refreshToken,
    userScopes,
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
