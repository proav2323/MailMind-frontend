import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/components/Drawer.dart';
import 'package:mailmind/components/UserAppBar.dart';
import 'package:mailmind/models/emails.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/socket.dart';

class Email extends StatefulWidget {
  String? id;
  EMAIL? email;
  bool isLaoding = false;

  Email({super.key, required this.id});

  @override
  State<Email> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Email> {
  @override
  void initState() {
    setState(() {
      widget.isLaoding = true;
    });
    super.initState();
    if (widget.id == null) {
      setState(() {
        widget.isLaoding = false;
        widget.email = null;
      });
      context.go("/");
    } else {
      getEmailById(widget.id!)
          .then((value) {
            if (value == null) {
              setState(() {
                widget.isLaoding = false;
                widget.email = null;
              });
            } else {
              setState(() {
                widget.isLaoding = false;
                widget.email = value;
              });
            }
          })
          .catchError((err) {
            setState(() {
              widget.email = null;
              widget.isLaoding = false;
            });
            context.go("/");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String route = GoRouterState.of(context).uri.toString();

    return Consumer(
      builder: (context, ref, child) {
        AsyncValue<SocketService> socketService = ref.watch(SOCKET);
        AsyncValue<USER?> userProv = ref.read(userProvider);

        socketService.whenData((socket) {
          socket.socket.on('connect', (_) {});

          socket.socket.on('disconnect', (_) {});
        });

        return SafeArea(
          child: Scaffold(
            appBar: userProv.value == null
                ? null
                : UserAppBar(
                    showBackButton: true,
                    title: "",
                    actions: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications),
                      ),
                    ],
                  ),
            drawer: userProv.value != null
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
                    user: userProv.value!,
                  )
                : null,
            body: widget.isLaoding == true
                ? Center(child: CircularProgressIndicator())
                : userProv.value != null && widget.email != null
                ? Container(
                    width: screenWidth * 0.95,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.email!.subject,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: widget.email!.isStarred == true
                                  ? Icon(Icons.star)
                                  : Icon(Icons.star_border),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(widget.email!.subject),
                                subtitle: Text(widget.email!.sender),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(widget.email!.category),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Text("something went wrong"),
          ),
        );
      },
    );
  }
}
