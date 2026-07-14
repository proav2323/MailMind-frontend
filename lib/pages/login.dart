import 'dart:developer';
import 'package:MailMind/components/appbar.dart';
import 'package:MailMind/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:MailMind/services/api.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  void loginUser() {
    if (kIsWeb) {
    } else {
      setState(() {
        isLoading = true;
      });
      loginWithGoogle(context)
          .onError((err, trace) {
            log(err.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: kReleaseMode
                    ? Text("something went wrong")
                    : Text(err.toString()),
              ),
            );
          })
          .whenComplete(() {
            setState(() {
              isLoading = false;
            });
          })
          .catchError((err, trace) {
            log(err.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: kReleaseMode
                    ? Text("something went wrong")
                    : Text(err.toString()),
              ),
            );
          })
          .then((value) {});
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = false;
    });
    if (kIsWeb) {
      googleSignIn.authenticationState.listen(
        (GoogleSignInCredentials? cred) {
          setState(() {
            isLoading = true;
          });
          loginToDatabase(cred, context)
              .then((value) {})
              .onError((err, trace) {
                SnackBar(
                  content: kReleaseMode
                      ? Text("something went wrong")
                      : Text(err.toString()),
                );
              })
              .whenComplete(() {
                setState(() {
                  isLoading = false;
                });
              });
        },
        onError: (err) {
          SnackBar(
            content: kReleaseMode
                ? Text("something went wrong")
                : Text(err.toString()),
          );
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(
      builder: (context, ref, widget) {
        return Scaffold(
          appBar: CustomAppBar(title: "Login"),
          body: Center(
            child: Container(
              height: 500,
              padding: const EdgeInsets.all(16.0),
              width: screenWidth > 1200
                  ? screenWidth * 0.5
                  : screenWidth > 900
                  ? screenWidth * 0.7
                  : screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    spreadRadius: 4, // Expansion size
                    blurRadius: 10, // Blur softness
                    offset: const Offset(0, 6), // Shadow position (x, y)
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "MailMind",
                    style: TextStyle(
                      fontSize: 50,
                      color: Color.fromRGBO(138, 82, 235, 1),
                    ),
                  ),
                  Text(
                    "smart email assistance for college students",
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth * 0.95,
                    child: kIsWeb
                        ? isLoading
                              ? Center(child: CircularProgressIndicator())
                              : googleSignIn.signInButton()
                        : ElevatedButton(
                            onPressed: () => loginUser(),
                            style: ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            child: isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Image(
                                            image: AssetImage(
                                              'assets/google-logo.png',
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0, width: 15),
                                        Text("Sign in With google"),
                                      ],
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
