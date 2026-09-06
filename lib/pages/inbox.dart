import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/emails.dart';
import 'package:mailmind/services/socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

// 1. Change from StatefulWidget to ConsumerStatefulWidget
class Inbox extends ConsumerStatefulWidget {
  Inbox({super.key});

  @override
  ConsumerState<Inbox> createState() => _InboxState();
}

// 2. Change from State to ConsumerState
class _InboxState extends ConsumerState<Inbox> {
  bool isLoading = true; // Use simple state for UI loading spinner only
  bool addCatLoading = false;

  String? category;
  String? priority;
  String? starred;
  String? dateStart;
  String? dateEnd;
  String addCategoryText = "";

  List<Map<String, dynamic>> fixCategories = [
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
              newCat.insert(0, {"name": valueW['name'], "id": valueW['id']});
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
      Duration diff = DateTime.parse(
        dateEnd ?? DateTime.now().toString(),
      ).difference(DateTime.parse(dateStart ?? DateTime.now().toString()));
      if (category != null ||
          priority != null ||
          starred != null ||
          (dateEnd != null && dateStart != null && diff.inDays > 0)) {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserFilteredEmails(
          starred,
          category,
          priority,
          dateStart,
          dateEnd,
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
      Duration diff = DateTime.parse(
        dateEnd ?? DateTime.now().toString(),
      ).difference(DateTime.parse(dateStart ?? DateTime.now().toString()));
      if (dateEnd != null && dateStart != null) {
        Duration diff = DateTime.parse(
          dateEnd!,
        ).difference(DateTime.parse(dateStart!));
      }
      bool hasMore = ref.read(hasMoreProvider.notifier).getValue();
      cursorData data;
      if (hasMore == false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No more emails to load")));
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (category != null ||
          priority != null ||
          starred != null ||
          (dateEnd != null && dateStart != null)) {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserFilteredEmails(
          starred,
          category,
          priority,
          dateStart,
          dateEnd,
          cursor,
        );
      } else {
        String? cursor = ref.read(cursorProvider.notifier).getValue();
        data = await getUserEmails(cursor);
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: kReleaseMode
              ? Text("something went wrong")
              : Text(e.toString()),
        ),
      );
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

  void categoryFilter(String categoryS) {
    if (categoryS == category) {
      setState(() {
        category = null;
      });
    } else {
      setState(() {
        category = categoryS;
      });
    }
    setState(() {
      isLoading = true;
    });
    ref.read(cursorProvider.notifier).updateValue(null);
    ref.read(emailsProivder.notifier).updateValue(false, []);
    ref.read(hasMoreProvider.notifier).updateValue(true);
    getMoreEmails();
  }

  Future<void> addCategory() async {
    dynamic value = await addCategories(addCategoryText);
    List<dynamic> newAddedCat = await getUserCategories();
    List<Map<String, Object?>> newCat = [...newAddedCat, ...categories];

    if (value == "done") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value.toString())));
      Navigator.pop(context);
    }

    setState(() {
      categories = newCat;
      addCategoryText = "";
      addCatLoading = false;
    });
  }

  void showAddCategoryModel() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter category name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          addCategoryText = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        addCatLoading = true;
                      });
                      addCategory();
                    },
                    child: addCatLoading == true
                        ? Center(child: CircularProgressIndicator())
                        : Text('Add Category'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showFiltersModel() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Center(
                      child: DropdownMenu<String>(
                        initialSelection: priority,
                        label: const Text('Select an priority'),
                        onSelected: (String? value) {
                          setState(() {
                            priority = value;
                          });
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: 'Critical',
                            label: 'Critical',
                          ),
                          DropdownMenuEntry(value: 'High', label: 'High'),
                          DropdownMenuEntry(value: 'Medium', label: 'Medium'),
                          DropdownMenuEntry(value: 'Low', label: 'Low'),
                          DropdownMenuEntry(value: 'Expired', label: 'Expired'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("starred"),
                      SizedBox(width: 10),
                      Switch(
                        value: starred == "true" ? true : false,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.greenAccent,
                        onChanged: (bool value) {
                          setState(() {
                            starred = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: dateStart != null
                                  ? DateTime.parse(dateStart!)
                                  : DateTime.now(),
                              firstDate: DateTime(
                                2000,
                              ), // Minimum selectable date
                              lastDate: DateTime(
                                2101,
                              ), // Maximum selectable date
                            );

                            if (picked != null &&
                                picked !=
                                    DateTime.parse(
                                      dateStart ?? DateTime.now().toString(),
                                    )) {
                              setState(() {
                                dateStart = picked.toIso8601String();
                              });
                            }
                          },
                          child: dateStart == null
                              ? Text("pick start date")
                              : Text(dateStart!),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: dateEnd != null
                                  ? DateTime.parse(dateEnd!)
                                  : DateTime.now(),
                              firstDate: DateTime(
                                2000,
                              ), // Minimum selectable date
                              lastDate: DateTime(
                                2101,
                              ), // Maximum selectable date
                            );

                            if (picked != null &&
                                picked !=
                                    DateTime.parse(
                                      dateEnd ?? DateTime.now().toString(),
                                    )) {
                              setState(() {
                                dateEnd = picked.toIso8601String();
                              });
                            }
                          },
                          child: dateEnd == null
                              ? Text("pick end date")
                              : Text(dateEnd!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        ref.read(cursorProvider.notifier).updateValue(null);
                        ref
                            .read(emailsProivder.notifier)
                            .updateValue(false, []);
                        ref.read(hasMoreProvider.notifier).updateValue(true);
                        getMoreEmails();
                        Navigator.pop(context);
                      },
                      child: Text("Apply Filters"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                          onPressed: showAddCategoryModel,
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () =>
                                categoryFilter(categories[index]['name']),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(200),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors:
                                      isDarkMode &&
                                          category != categories[index]['name']
                                      ? [
                                          const Color(0xFF1E1E24),
                                          const Color(0xFF0F0F12),
                                        ] // Dark Mode Colors
                                      : category == categories[index]['name']
                                      ? [
                                          const Color.fromARGB(255, 17, 170, 1),
                                          const Color.fromARGB(255, 0, 117, 14),
                                        ]
                                      : [
                                          const Color(0xFF667EEA),
                                          const Color(0xFF764BA2),
                                        ], // Light Mode Colors
                                ),
                              ),
                              child: categories[index]['id'] != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            categories[index]['name'],
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        IconButton(
                                          onPressed: () async {
                                            dynamic value =
                                                await deleteCategories(
                                                  categories[index]['id'],
                                                );
                                            if (value == "done") {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Category deleted successfully",
                                                  ),
                                                ),
                                              );
                                              List<Map<String, Object?>>
                                              newCat = [...fixCategories];
                                              List<dynamic> cat =
                                                  await getUserCategories();

                                              cat.forEach((valueW) {
                                                newCat.insert(0, {
                                                  "name": valueW['name'],
                                                  "id": valueW['id'],
                                                });
                                              });
                                              setState(() {
                                                categories = newCat;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    value.toString(),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(categories[index]['name']),
                                    ),
                            ),
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
                          onPressed: showFiltersModel,
                          icon: const Icon(Icons.filter_list),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: emails.length != 0
                      ? ListView.separated(
                          itemCount: emails.length,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 5,
                          ), // Number of items in your list
                          itemBuilder: (context, index) {
                            final email = emails[index];
                            DateTime indiaDateTime = email.receivedAt
                                .toUtc()
                                .add(const Duration(hours: 5, minutes: 30));
                            DateFormat formatter = DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            );
                            String dateWithTime = formatter.format(
                              indiaDateTime,
                            );
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
                                    ref
                                            .read(hasMoreProvider.notifier)
                                            .getValue() ==
                                        true &&
                                    isLoading == false) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getMoreEmails();
                                }
                              },
                              child: GestureDetector(
                                onTap: () {
                                  context.go("/email/${email.gmailId}");
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(200),
                                                      ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: isDarkMode
                                                        ? [
                                                            const Color(
                                                              0xFF1E1E24,
                                                            ),
                                                            const Color(
                                                              0xFF0F0F12,
                                                            ),
                                                          ] // Dark Mode Colors
                                                        : [
                                                            const Color(
                                                              0xFF667EEA,
                                                            ),
                                                            const Color(
                                                              0xFF764BA2,
                                                            ),
                                                          ], // Light Mode Colors
                                                  ),
                                                ),
                                                child: Text(email.category),
                                              ),
                                              SizedBox(width: 2, height: 0),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                  : Color.fromARGB(
                                                      255,
                                                      197,
                                                      196,
                                                      196,
                                                    ),
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
                                                : email.summary.substring(
                                                        0,
                                                        27,
                                                      ) +
                                                      "...",
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Color(0xFF8C9ABA)
                                                  : Color.fromARGB(
                                                      255,
                                                      197,
                                                      196,
                                                      196,
                                                    ),
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
                                                  : Color.fromARGB(
                                                      255,
                                                      197,
                                                      196,
                                                      196,
                                                    ),
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No emails found",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Color(0xFF8C9ABA)
                                  : Color.fromARGB(255, 197, 196, 196),
                            ),
                          ),
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
