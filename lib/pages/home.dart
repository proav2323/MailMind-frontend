import 'dart:developer';

import 'package:MailMind/components/appbar.dart';
import 'package:MailMind/services/auth.dart';
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
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: CustomAppBar(title: "MailMind"),
          body: widget.isLaoding == true
              ? Center(child: CircularProgressIndicator())
              : widget.user != null
              ? Text("user")
              : Text("something went wrong"),
        );
      },
    );
  }
}
