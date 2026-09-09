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
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class Email extends StatefulWidget {
  final String? id; // Made final as per good practices
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
              // Sorts the list parts by index 'i'
              widget.email!.bodyInOrder.sort((a, b) => b['i'] - a['i']);
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                      ),
                    ],
                  ),
            drawer: userProv.value != null
                ? UserMainAppDrawer(
                    actions: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Home'),
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
                ? const Center(child: CircularProgressIndicator())
                : userProv.value != null && widget.email != null
                ? SizedBox(
                    width: screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Email Subject Section
                        Container(
                          width: screenWidth * 0.95,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.email!.subject,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: widget.email!.isStarred == true
                                    ? const Icon(Icons.star)
                                    : const Icon(Icons.star_border),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 2. CustomScrollView Section
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Sender Name
                                      Expanded(
                                        child: Text(
                                          widget.email!.sender
                                              .split("<")[0]
                                              .split(">")[0],
                                          style: const TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Date & Actions
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.email!.receivedAt
                                                .toString()
                                                .split(".")[0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.more_horiz),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 10),
                              ),

                              // FIXED: Directly using SliverList.separated
                              SliverList.separated(
                                itemCount: widget.email!.bodyInOrder.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 24),
                                itemBuilder: (con, index) {
                                  final bodyPart =
                                      widget.email!.bodyInOrder[index];
                                  final String htmlContent = bodyPart['data'];
                                  bool show =
                                      index > 0 &&
                                      bodyPart['data'] !=
                                          widget.email!.bodyInOrder[index -
                                              1]['data'];

                                  return show == true || index == 0
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: HtmlWidget(
                                            htmlContent.isEmpty
                                                ? "<p>No content available</p>"
                                                : htmlContent,
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              height: 1.4,
                                            ),
                                          ),
                                        )
                                      : null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text("something went wrong")),
          ),
        );
      },
    );
  }
}
