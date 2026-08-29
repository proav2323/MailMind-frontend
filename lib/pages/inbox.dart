import 'dart:developer';
import 'package:flutter_riverpod/misc.dart';
import 'package:mailmind/components/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/components/UserAppBar.dart';
import 'package:mailmind/models/email.dart';
import 'package:mailmind/models/user.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/emails.dart';
import 'package:mailmind/services/sharedPref.dart';
import 'package:mailmind/services/api.dart';
import 'package:dio/dio.dart';
import 'package:mailmind/services/socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// 1. Change from StatefulWidget to ConsumerStatefulWidget
class Inbox extends ConsumerStatefulWidget {
  const Inbox({super.key});

  @override
  ConsumerState<Inbox> createState() => _InboxState();
}

// 2. Change from State to ConsumerState
class _InboxState extends ConsumerState<Inbox> {
  bool isLoading = true; // Use simple state for UI loading spinner only

  void init() async {
    try {
      cursorData data = await getUserEmails();

      // 3. Update Riverpod providers directly when data arrives using ref.read
      ref.read(emailsProivder.notifier).updateValue(false, data.emails);
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
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 50,
                  child: Row(children: [Text(emails.length.toString())]),
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

                      return SizedBox(
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
                                      : email.summary.substring(0, 27) + "...",
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
