import 'package:MailMind/models/user.dart';
import 'package:MailMind/services/api.dart';
import 'package:MailMind/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  // Pass data into the component via the constructor
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 4,
      leading: IconButton(
        onPressed: () => {},
        icon: ImageIcon(AssetImage('assets/MailMind-logo.png'), size: 100),
      ),
      actions: [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
