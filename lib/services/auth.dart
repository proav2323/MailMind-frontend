import 'dart:developer';
import 'package:MailMind/models/user.dart';
import 'package:MailMind/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:MailMind/services/config.dart';

// final GoogleSignIn googleSignIn = GoogleSignIn.instance;
final googleSignIn = GoogleSignIn(
  // See 'How to Get Google OAuth Credentials' section below
  params: GoogleSignInParams(
    clientId: CONFIGAPIKEYS.GOOGLE_CLINET_ID,
    clientSecret: CONFIGAPIKEYS
        .GOOGLE_SECRET, // Don't worry - not truly a secret! See 'Client Secret Requirements'
    scopes: scopes,
  ),
);

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
    await setCustomCookie(Uri.parse(BACKEND_URL + "/auth/"), token!, "token");
  }
  return getUserProfile();
}

Future<void> loginWithGoogle(BuildContext context) async {
  if (kIsWeb) {
  } else {
    final cred = await googleSignIn.signInOnline();
    final client = await googleSignIn.authenticatedClient;
    if (client == null || cred == null) {
      log(
        client == null && cred == null
            ? "both null"
            : client == null
            ? "client null"
            : "cred null",
      );
      return;
    }
    final peopleApi = PeopleServiceApi(client);
    final person = await peopleApi.people.get(
      'people/me',
      personFields: "names,emailAddresses,photos",
    );
    String? email = person.emailAddresses![0].value;
    String? name = person.names![0].displayName;
    String? photoUrl = person.photos![0].url;

    await setCustomCookie(
      Uri.parse(BACKEND_URL + "/auth/login/"),
      cred.accessToken,
      "accessToken",
    );

    var res = await login(
      name != null ? name : "no name",
      email!,
      photoUrl != null ? photoUrl : "no photo",
      "google",
      cred.accessToken,
    );
    String token = res.data;

    USER finalUser = await auth(false, token);
    userProvider.overrideWithValue(AsyncValue.data(finalUser));
    context.go('/');
  }
}

Future<void> logoutUser() async {
  await googleSignIn.signOut();
  await logout();
  userProvider.overrideWithValue(AsyncValue.data(null));
}
