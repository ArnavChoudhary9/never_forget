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
  DateTime dateTime;

  Reminder({required this.title, required this.dateTime});

  Map<String, dynamic> toJson() {
    return {'title': title, 'dateTime': dateTime.toIso8601String()};
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );
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

  void addReminder(String title, DateTime dateTime) {
    setState(() {
      reminders.add(Reminder(title: title, dateTime: dateTime));
    });
    saveReminders();
  }

  void deleteReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });
    saveReminders();
  }

  void showAddReminderDialog() async {
    final TextEditingController controller = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter Reminder name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : "${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}",
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text("Pick Date"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime == null
                            ? "Select Time"
                            : "${selectedTime?.hour}:${selectedTime?.minute}",
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setDialogState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: const Text("Pick Time"),
                      ),
                    ],
                  ),
                ],
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
                    if (controller.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final fullDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      addReminder(controller.text, fullDateTime);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showEditReminderDialog(int index) {
    final TextEditingController titleController = TextEditingController(
      text: reminders[index].title,
    );
    DateTime selectedDate =
        reminders[index]
            .dateTime; // Assuming reminders[index].dateTime is a DateTime object

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new title',
                  ),
                ),
                const SizedBox(height: 20), // Add some space between fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${selectedDate.toLocal()}'.split(
                        ' ',
                      )[0], // Display only the date
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          selectedDate = pickedDate;
                        }
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time: ${TimeOfDay.fromDateTime(selectedDate).format(context)}',
                    ),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (pickedTime != null) {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      },
                      child: const Text('Change Time'),
                    ),
                  ],
                ),
              ],
            ),
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
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    reminders[index].title = titleController.text;
                    reminders[index].dateTime =
                        selectedDate; // Update the date/time
                  });
                  saveReminders();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
                              subtitle: Text(
                                "${reminders[index].dateTime.toLocal()}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed:
                                        () => showEditReminderDialog(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => deleteReminder(index),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddReminderDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
