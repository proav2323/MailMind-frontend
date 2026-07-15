import 'dart:developer';

import 'package:MailMind/components/UserAppBar.dart';
import 'package:MailMind/services/auth.dart';
import 'package:MailMind/services/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MailMind/models/user.dart';
import 'package:go_router/go_router.dart';

class MyHomePage extends StatefulWidget {
  USER? user;
  bool isLaoding = true;
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void init() {
    log(CONFIGAPIKEYS.GOOGLE_SECRET);
    final container = ProviderContainer();
    container.listen(
      userProvider,
      (prev, next) {
        next.when(
          error: (err, trace) {
            setState(() {
              widget.isLaoding = false;
              widget.user = null;
            });
            context.go("/login");
          },
          data: (value) {
            log(value.toString());
            setState(() {
              widget.isLaoding = false;
              widget.user = value;
            });
            if (value == null) {
              context.go("/login");
            }
          },
          loading: () {
            setState(() {
              widget.isLaoding = true;
              widget.user = null;
            });
          },
        );
      },
      onError: (err, trace) {
        setState(() {
          widget.isLaoding = false;
          widget.user = null;
        });
        context.go("/login");
      },
    );
  }

  @override
  void initState() {
    setState(() {
      widget.isLaoding = true;
    });
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer(
      builder: (context, ref, child) {
        return SafeArea(
          child: Scaffold(
            appBar: widget.user == null
                ? null
                : UserAppBar(
                    title: "",
                    actions: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications),
                      ),
                    ],
                    user: widget.user!,
                    showPopup: true,
                  ),
            body: widget.isLaoding == true
                ? Center(child: CircularProgressIndicator())
                : widget.user != null
                ? Center(
                    child: SizedBox(
                      width: screenWidth * 0.90,
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Hello, ${widget.user!.name} 👋",
                            style: TextStyle(
                              fontSize: 25,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Here's what's important today",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.blueGrey
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text("something went wrong"),
          ),
        );
      },
    );
  }
}
