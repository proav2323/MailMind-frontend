import 'package:MailMind/components/appbar.dart';
import 'package:MailMind/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(userProvider);
        return Scaffold(
          appBar: CustomAppBar(title: "MailMind"),
          body: user.error != null
              ? Text(user.error.toString())
              : user.value != null
              ? user.value != null
                    ? Text("user found")
                    : Text("user not found")
              : CircularProgressIndicator(),
        );
      },
    );
  }
}
