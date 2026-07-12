import 'package:MailMind/models/user.dart';
import 'package:MailMind/services/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

final GoogleSignIn googleSignIn = GoogleSignIn.instance;

final scopes = [
  'email',
  'profile',
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/gmail.modify',
  'https://www.googleapis.com/auth/gmail.send',
];

final userProvider = FutureProvider<USER?>((ref) async {
  return auth();
}, retry: (retryCount, error) {});

Future<USER> auth() async {
  return getUserProfile();
}

Future<void> loginWithGoogle() async {
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
    Uri.parse(BACKEND_URL + "/auth/login"),
    accessToken,
    "accessToken",
  );

  var res = await login(
    user.displayName != null ? user.displayName! : "no name",
    user.email,
    user.photoUrl != null ? user.photoUrl! : "no photo",
    "google",
  );

  List<Cookie> cookies = await getCookies(res.realUri);
  int index = 0;
  for (int i = 0; i < cookies.length; i++) {
    if (cookies[i].name == "token") {
      index = i;
      return;
    }
  }
  String token = res.data;
  String cookieToken = cookies[index].value;

  await setCustomCookie(Uri.parse(BACKEND_URL + "/auth/"), token, "token");

  USER finalUser = await getUserProfile();
  userProvider.overrideWithValue(AsyncValue.data(finalUser));
}

Future<void> logoutUser() async {
  await googleSignIn.signOut();
  await logout();
  userProvider.overrideWithValue(AsyncValue.data(null));
}
