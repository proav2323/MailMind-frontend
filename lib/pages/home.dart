import 'dart:developer';
import 'package:mailmind/components/BottomNavigationBar.dart';
import 'package:mailmind/components/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/components/UserAppBar.dart';
import 'package:mailmind/models/email.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/pages/inbox.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/emails.dart';
import 'package:mailmind/services/sharedPref.dart';
import 'package:mailmind/services/api.dart';
import 'package:dio/dio.dart';
import 'package:mailmind/services/socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends StatefulWidget {
  USER? user;
  bool isLaoding = true;
  int index = 0;
  MyHomePage({super.key, required this.index});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void change(int newIndex) {
    if (newIndex == 2) {
    } else {
      setState(() {
        widget.index = newIndex;
      });
    }
  }

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
            log(err.toString());
            log(trace.toString());
            context.go("/login");
          },
          data: (value) async {
            if (value == null) {
              setState(() {
                widget.isLaoding = false;
                widget.user = value;
              });
              context.go("/login");
            }
            Object? year = await getItem("year");
            if (year == null || year == "" || year == " ") {
              setState(() {
                widget.isLaoding = false;
                widget.user = value;
              });
              context.go('/year');
            }
            if (value != null && year != null && year != "" && year != " ") {
              try {
                Response<dynamic> data = await getNewEmails();
              } on DioException catch (e) {
                log(e.toString());
                setState(() {
                  widget.user = null;
                  widget.isLaoding = false;
                });
              }
              USER user = await auth(true, null);
              userProvider.overrideWithValue(AsyncValue.data(user));
              setState(() {
                widget.user = user;
                widget.isLaoding = false;
              });
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
        AsyncValue<SocketService> socketService = ref.watch(SOCKET);
        socketService.whenData((socket) {
          socket.socket.on('connect', (_) {});

          socket.socket.on('disconnect', (_) {});
        });
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
            bottomNavigationBar: widget.user != null
                ? CustomBottomNavigationBar(
                    actions: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.mail),
                        label: "Inbox",
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Custom background color
                            borderRadius: BorderRadius.circular(
                              200,
                            ), // Rounded border
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        label: '', // Required empty label to hide text space
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calendar_view_day_rounded),
                        label: "Calender",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.phone),
                        label: "Reminders",
                      ),
                    ],
                    user: widget.user!,
                    index: widget.index,
                    change: change,
                  )
                : null,
            body: widget.isLaoding == true
                ? Center(child: CircularProgressIndicator())
                : widget.user != null
                ? widget.index == 0
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
                      : widget.index == 1
                      ? Inbox()
                      : widget.index == 3
                      ? Text("calenders")
                      : Text("reminders")
                : Text("something went wrong"),
          ),
        );
      },
    );
  }
}
