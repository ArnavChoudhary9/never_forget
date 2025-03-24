import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class Reminder {
  String title;

  Reminder({required this.title});

  Map<String, dynamic> toJson() {
    return {'title': title};
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(title: json['title'] as String);
  }
}

class _RemindersState extends State<Reminders> {
  List<Reminder> reminders = [];

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderList = reminders.map((item) => item.toJson()).toList();
    await prefs.setString('reminders', jsonEncode(reminderList));
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderString = prefs.getString('reminders');
    if (reminderString != null) {
      final List<dynamic> reminderJson = jsonDecode(reminderString);
      setState(() {
        reminders =
            reminderJson.map((json) => Reminder.fromJson(json)).toList();
      });
    }
  }

  void addReminder(String title) {
    setState(() {
      reminders.add(Reminder(title: title));
    });
    saveReminders();
  }

  void deleteReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });
    saveReminders();
  }

  void showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Reminders'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter Reminders name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  addReminder(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  deleteReminder(index); // Delete the selected reminder
                  Navigator.of(context).pop(); // Close the menu
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:
            reminders.isEmpty
                ? const Center(
                  child: Text(
                    "Click on '+' to add new Reminder",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Reminders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: reminders.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Long press to delete this reminder",
                                  ),
                                  duration: const Duration(
                                    seconds: 1,
                                  ), // Tooltip duration
                                ),
                              );
                            },
                            onLongPress: () => showOptionsMenu(context, index),
                            child: ListTile(
                              title: Text(reminders[index].title),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
