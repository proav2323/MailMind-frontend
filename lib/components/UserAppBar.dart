import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  bool showBackButton = false;

  // Pass data into the component via the constructor
  UserAppBar({
    super.key,
    required this.title,
    required this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back),
            )
          : IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
