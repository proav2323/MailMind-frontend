import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/emails.dart';
import 'package:mailmind/services/socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

// 1. Change from StatefulWidget to ConsumerStatefulWidget
class Inbox extends ConsumerStatefulWidget {
  String? category;
  String? priority;
  String? starred;
  String? dateStart;
  String? dateEnd;
  Inbox({
    super.key,
    required this.category,
    required this.dateEnd,
    required this.dateStart,
    required this.priority,
    required this.starred,
  });

  @override
  ConsumerState<Inbox> createState() => _InboxState();
}

// 2. Change from State to ConsumerState
class _InboxState extends ConsumerState<Inbox> {
  bool isLoading = true; // Use simple state for UI loading spinner only

  bool hasMore = true;

  List<Map<String, dynamic>> categories = [
    {"name": "assignment"},
    {"name": "project"},
    {"name": "syllabus"},
    {"name": "task"},
    {"name": "meeting"},
    {"name": "review"},
    {"name": "interview"},
    {"name": "course"},
    {"name": "exam"},
    {"name": "submission"},
    {"name": "invoice"},
    {"name": "report"},
    {"name": "schedule"},
    {"name": "urgent"},
    {"name": "education"},
    {"name": "work"},
    {"name": "school"},
    {"name": "office"},
    {"name": "OTP"},
    {"name": "event"},
    {"name": "hackathons"},
    {"name": "class"},
    {"name": "annoucements"},
    {"name": "finace"},
    {"name": "billing"},
    {"name": "placement"},
    {"name": "reminder"},
    {"name": "fees"},
    {"name": "scholarship"},
    {"name": "timetable"},
    {"name": "academic"},
    {"name": "holiday"},
    {"name": "club"},
    {"name": "intership"},
    {"name": "research"},
    {"name": "Finace"},
    {"name": "personal"},
    {"name": "spam"},
    {"name": "social"},
  ];

  void init() async {
    cursorData data;
    try {
      getUserCategories()
          .then((value) {
            List<Map<String, dynamic>> newCat = [...categories];
            value.forEach((valueW) {
              newCat.insert(0, {"name": valueW['name']});
            });

            setState(() {
              categories = newCat;
            });
          })
          .onError((err, trace) {
            log(err.toString());
            log(trace.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: kReleaseMode
                    ? Text("something went wrong")
                    : Text(err.toString()),
              ),
            );
          });
      if (widget.category != null ||
          widget.priority != null ||
          widget.starred != null ||
          (widget.dateEnd != null && widget.dateStart != null)) {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserFilteredEmails(
          widget.starred,
          widget.category,
          widget.priority,
          widget.dateStart,
          widget.dateEnd,
          cursor,
        );
      } else {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserEmails(cursor);
      }

      // 3. Update Riverpod providers directly when data arrives using ref.read
      ref
          .read(emailsProivder.notifier)
          .updateValue(
            ref.read(cursorProvider.notifier).getValue() != null ? true : false,
            data.emails,
          );
      ref.read(cursorProvider.notifier).updateValue(data.cursor);
      ref.read(hasMoreProvider.notifier).updateValue(data.hasMore);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching emails: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void getMoreEmails() async {
    try {
      cursorData data;
      if (widget.category != null ||
          widget.priority != null ||
          widget.starred != null ||
          (widget.dateEnd != null && widget.dateStart != null)) {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserFilteredEmails(
          widget.starred,
          widget.category,
          widget.priority,
          widget.dateStart,
          widget.dateEnd,
          cursor,
        );
      } else {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserEmails(cursor);
      }

      // 3. Update Riverpod providers directly when data arrives using ref.read
      ref
          .read(emailsProivder.notifier)
          .updateValue(
            ref.read(cursorProvider.notifier).getValue() != null ? true : false,
            data.emails,
          );
      ref.read(cursorProvider.notifier).updateValue(data.cursor);
      ref.read(hasMoreProvider.notifier).updateValue(data.hasMore);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching emails: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Watch socket connections safely inside build
    ref.watch(SOCKET).whenData((socket) {
      socket.socket.on('connect', (_) {});
      socket.socket.on('disconnect', (_) {});
    });
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    final emails = ref.watch(emailsProivder);

    return SafeArea(
      child: isLoading && emails.isEmpty == true
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(200),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDarkMode
                                    ? [
                                        const Color(0xFF1E1E24),
                                        const Color(0xFF0F0F12),
                                      ] // Dark Mode Colors
                                    : [
                                        const Color(0xFF667EEA),
                                        const Color(0xFF764BA2),
                                      ], // Light Mode Colors
                              ),
                            ),
                            child: Text(categories[index]['name']),
                          ),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                          itemCount: categories.length,
                        ),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: emails.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 5,
                    ), // Number of items in your list
                    itemBuilder: (context, index) {
                      final email = emails[index];
                      DateTime indiaDateTime = email.receivedAt.toUtc().add(
                        const Duration(hours: 5, minutes: 30),
                      );
                      DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
                      String dateWithTime = formatter.format(indiaDateTime);
                      List<Color> gradientColors = [];

                      if (email.priority == "Critical" ||
                          email.priority == "High") {
                        gradientColors = isDarkMode
                            ? [
                                const Color(0xFF63171B),
                                const Color(0xFF9B2C2C),
                              ] // Dark Crimson
                            : [
                                const Color(0xFFFED7D7),
                                const Color(0xFFFEB2B2),
                              ]; // Pastel Red
                      } else if (email.priority == "Medium") {
                        gradientColors = isDarkMode
                            ? [
                                const Color(0xFF744210),
                                const Color(0xFF975A16),
                              ] // Dark Ochre/Amber
                            : [
                                const Color(0xFFFEFCBF),
                                const Color(0xFFFEEBC8),
                              ]; // Pastel Yellow
                      } else if (email.priority == "Low" ||
                          email.priority == "Expired") {
                        gradientColors = isDarkMode
                            ? [
                                const Color(0xFF1B4332),
                                const Color(0xFF2D6A4F),
                              ] // Deep Dark Green
                            : [
                                const Color(0xFFD8F3DC),
                                const Color(0xFFB7E4C7),
                              ]; // Pastel Green
                      } else {
                        gradientColors = isDarkMode
                            ? [
                                const Color(0xFF1E293B),
                                const Color(0xFF0F172A),
                              ] // Dark Slate Gray
                            : [
                                const Color(0xFFF1F5F9),
                                const Color(0xFFE2E8F0),
                              ]; // Light Slate Gray
                      }

                      return VisibilityDetector(
                        key: Key('$index'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0.5 &&
                              index == emails.length - 1 &&
                              ref.read(hasMoreProvider.notifier).getValue() ==
                                  true) {
                            setState(() {
                              isLoading = true;
                            });
                            getMoreEmails();
                          }
                        },
                        child: SizedBox(
                          width: screenWidth,
                          child: Card(
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                SizedBox(
                                  width: screenWidth * 0.97 * 0.95,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(200),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isDarkMode
                                                ? [
                                                    const Color(0xFF1E1E24),
                                                    const Color(0xFF0F0F12),
                                                  ] // Dark Mode Colors
                                                : [
                                                    const Color(0xFF667EEA),
                                                    const Color(0xFF764BA2),
                                                  ], // Light Mode Colors
                                          ),
                                        ),
                                        child: Text(email.category),
                                      ),
                                      SizedBox(width: 2, height: 0),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(200),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors:
                                                gradientColors, // Light Mode Colors
                                          ),
                                        ),
                                        child: Text(email.priority),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                SizedBox(
                                  width: screenWidth * (0.97 * 0.95),
                                  child: Text(
                                    email.sender.split("<")[0],
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Color(0xFF8C9ABA)
                                          : Color.fromARGB(255, 197, 196, 196),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * (0.97 * 0.95),
                                  child: Text(
                                    email.subject,
                                    style: TextStyle(),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * (0.97 * 0.95),
                                  child: Text(
                                    email.summary.length <= 80
                                        ? email.summary
                                        : email.summary.substring(0, 27) +
                                              "...",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Color(0xFF8C9ABA)
                                          : Color.fromARGB(255, 197, 196, 196),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * (0.97 * 0.95),
                                  child: Text(
                                    dateWithTime,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Color(0xFF8C9ABA)
                                          : Color.fromARGB(255, 197, 196, 196),
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                isLoading == true ? SizedBox(height: 10) : SizedBox(height: 0),
                isLoading == true
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(height: 0),
                isLoading == true ? SizedBox(height: 5) : SizedBox(height: 0),
              ],
            ),
    );
  }
}
