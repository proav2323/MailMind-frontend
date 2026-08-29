import 'package:flutter/material.dart';
import 'package:mailmind/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/services/auth.dart';

class CustomBottomNavigationBar extends StatefulWidget implements Widget {
  final List<BottomNavigationBarItem> actions;
  final USER user;
  final int index;
  final Function change;
  CustomBottomNavigationBar({
    super.key,
    required this.actions,
    required this.user,
    required this.index,
    required this.change,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  void click(int index) {
    widget.change(index);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      items: widget.actions,
      currentIndex: widget.index,
      selectedItemColor: isDarkMode
          ? Color.fromARGB(255, 0, 26, 104)
          : Colors.amber[800],
      onTap: click,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white70,
      unselectedItemColor: isDarkMode ? Colors.white : Colors.black,
    );
  }
}
