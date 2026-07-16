import 'package:flutter/material.dart';
import 'package:mailmind/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/services/auth.dart';

class UserMainAppDrawer extends StatelessWidget implements Widget {
  final String title;
  final List<Widget> actions;
  final USER user;

  // Pass data into the component via the constructor
  const UserMainAppDrawer({
    super.key,
    required this.title,
    required this.actions,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode == true ? Colors.black87 : Colors.blueGrey,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 70,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                      ),
                      SizedBox(height: 0, width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => logoutUser(context),
                          child: Text("logout"),
                        ),
                      ),
                      SizedBox(height: 0, width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("logout"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: actions),
          ),
        ],
      ),
    );
  }
}
