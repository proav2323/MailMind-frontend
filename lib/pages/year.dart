import 'dart:developer';
import 'package:mailmind/components/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/components/UserAppBar.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/sharedPref.dart';

class yearSelect extends StatefulWidget {
  USER? user;
  bool isLaoding = false;
  DateTime date = DateTime(DateTime.now().year);
  yearSelect({super.key});

  @override
  State<yearSelect> createState() => _yearSelectState();
}

class _yearSelectState extends State<yearSelect> {
  void init() {}

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String route = GoRouterState.of(context).uri.toString();
    int currentYear = DateTime.now().year;

    Future<void> setYear() async {
      setState(() {
        widget.isLaoding = true;
      });
      await addItem("year", widget.date.year.toString());
      // get fetch emails for first time with year
      // get user from auth and chaneg provider state
      // then go to home
      setState(() {
        widget.isLaoding = false;
      });
      context.go("/");
    }

    return Consumer(
      builder: (context, ref, child) {
        return SafeArea(
          child: Scaffold(
            appBar: widget.user == null
                ? null
                : UserAppBar(
                    title: "",
                    actions: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications),
                      ),
                    ],
                  ),
            drawer: widget.user != null
                ? UserMainAppDrawer(
                    actions: [
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('Home'),
                        selected: route == '/',
                        selectedColor: isDarkMode
                            ? Colors.grey
                            : Colors.blueAccent,
                        onTap: () {},
                      ),
                    ],
                    title: "",
                    user: widget.user!,
                  )
                : null,
            body: Center(
              child: SizedBox(
                width: screenWidth * 0.90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),

                    Text(
                      "Hello, please select a year",
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.4,
                      child: YearPicker(
                        firstDate: DateTime(currentYear - 50),
                        lastDate: DateTime(currentYear),
                        selectedDate: widget.date,
                        onChanged: (date) {
                          setState(() {
                            widget.date = date;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "we would like you pick a year, so we can filter out your emails rather than getting your all emails from gmail which can slow down your website flow. we would highly recommend to select year where you want after which we start filter and get your important emails in your dashboard",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.blueGrey[900]
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(4),
                        child: ElevatedButton(
                          style: ButtonStyle(),
                          onPressed: setYear,
                          child: widget.isLaoding
                              ? Center(child: CircularProgressIndicator())
                              : Center(child: Text("set year")),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
