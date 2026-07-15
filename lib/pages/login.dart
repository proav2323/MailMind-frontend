import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isMicrosoftLoading = false;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer(
      builder: (context, ref, widget) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: null,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constrainst) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        Container(
                          width: 200,
                          child: Image(
                            image: AssetImage('assets/MailMind-logo.png'),
                          ),
                        ),
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 40,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "login to continue",
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: isDarkMode
                                ? Color.fromRGBO(88, 87, 87, 1)
                                : Color.fromRGBO(150, 150, 150, 1),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 30),
                        Container(
                          child: Image(image: AssetImage('assets/Login.png')),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: screenWidth * 0.95,
                          child: ElevatedButton(
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
                        SizedBox(height: 20),
                        SizedBox(
                          width: screenWidth * 0.95,
                          child: ElevatedButton(
                            onPressed: () => {},
                            style: ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 16,
                                ),
                              ),
                              backgroundColor: isDarkMode
                                  ? WidgetStatePropertyAll(Colors.blueAccent)
                                  : WidgetStatePropertyAll(Colors.amber),
                            ),
                            child: isMicrosoftLoading
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
                                              'assets/micorsoft-logo.png',
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0, width: 15),
                                        Text(
                                          "Sign in With Microsoft",
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.amber
                                                : Colors.blueAccent,
                                          ),
                                        ),
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
          ),
        );
      },
    );
  }
}
