import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  // Pass data into the component via the constructor
  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 4,
      leading: IconButton(
        onPressed: () => {},
        icon: route == "/"
            ? ImageIcon(AssetImage('assets/MailMind-logo.png'), size: 100)
            : Icon(Icons.arrow_back),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
