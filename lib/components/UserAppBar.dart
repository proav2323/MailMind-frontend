import 'package:MailMind/models/user.dart';
import 'package:MailMind/services/api.dart';
import 'package:MailMind/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final USER user;
  final bool showPopup;

  // Pass data into the component via the constructor
  const UserAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.user,
    required this.showPopup,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(onPressed: () => {}, icon: Icon(Icons.menu)),
      actions: showPopup
          ? [
              ...actions,
              PopupMenuButton(
                offset: const Offset(
                  0,
                  56,
                ), // Positions dropdown directly below the AppBar
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
                onSelected: (String value) {
                  if (value == 'logout') {
                    logoutUser(context);
                  }
                },
              ),
            ]
          : actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
