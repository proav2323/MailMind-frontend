import 'dart:developer';
import 'package:MailMind/components/appbar.dart';
import 'package:MailMind/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:MailMind/services/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  void loginUser() {
    if (kIsWeb) {
      login("hello", "hello", "hello", "hello");
    } else {
      setState(() {
        isLoading = true;
      });
      loginWithGoogle()
          .onError((err, trace) {
            log(err.toString());
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(err.toString())));
          })
          .whenComplete(() {
            setState(() {
              isLoading = false;
            });
          })
          .catchError((err, trace) {})
          .then((value) {
            context.go('/');
          });
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = false;
    });

    googleSignIn.authenticationEvents.listen(
      (data) {},
      onError: (err) {},
      onDone: () {},
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(title: "Login"),
      body: Center(
        child: Container(
          width: screenWidth > 1200
              ? screenWidth * 0.5
              : screenWidth > 900
              ? screenWidth * 0.7
              : screenWidth,
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
                child: ElevatedButton(
                  onPressed: () => loginUser(),
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                    ),
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Image(
                                  image: AssetImage('assets/google-logo.png'),
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
  }
}
