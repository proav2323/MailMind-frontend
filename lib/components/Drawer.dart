import 'package:flutter/material.dart';
import 'package:mailmind/models/user.dart';

class UserMainAppDrawer extends StatelessWidget implements Widget {
  final String title;
  final List<Map<String, dynamic>> actions;
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
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                'Fixed Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                ListTile(leading: Icon(Icons.home), title: Text('Home')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
