import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/auth.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final USER user;

  // Pass data into the component via the constructor
  const UserAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(onPressed: () => {}, icon: Icon(Icons.menu)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
