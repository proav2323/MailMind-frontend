import 'dart:developer';
import 'package:mailmind/components/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/components/UserAppBar.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/sharedPref.dart';

class MyHomePage extends StatefulWidget {
  USER? user;
  bool isLaoding = true;
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void init() {
    final container = ProviderContainer();
    container.listen(
      userProvider,
      (prev, next) {
        next.when(
          error: (err, trace) {
            setState(() {
              widget.isLaoding = false;
              widget.user = null;
            });
            context.go("/login");
          },
          data: (value) async {
            setState(() {
              widget.isLaoding = false;
              widget.user = value;
            });
            if (value == null) {
              context.go("/login");
            }
            Object? year = await getItem("year");
            log(year.toString());
            if (year == null || year == "" || year == " ") {
              context.go('/year');
            }
          },
          loading: () {
            setState(() {
              widget.isLaoding = true;
              widget.user = null;
            });
          },
        );
      },
      onError: (err, trace) {
        setState(() {
          widget.isLaoding = false;
          widget.user = null;
        });
        context.go("/login");
      },
    );
  }

  @override
  void initState() {
    setState(() {
      widget.isLaoding = true;
    });
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String route = GoRouterState.of(context).uri.toString();
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
            body: widget.isLaoding == true
                ? Center(child: CircularProgressIndicator())
                : widget.user != null
                ? Center(
                    child: SizedBox(
                      width: screenWidth * 0.90,
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Hello, ${widget.user!.name} 👋",
                            style: TextStyle(
                              fontSize: 25,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Here's what's important today",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.blueGrey
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text("something went wrong"),
          ),
        );
      },
    );
  }
}
