import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Ideas extends StatefulWidget {
  const Ideas({super.key});

  @override
  State<Ideas> createState() => _IdeasState();
}

class Idea {
  String title;
  bool isCompleted;

  Idea({required this.title, this.isCompleted = false});

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

class _IdeasState extends State<Ideas> {
  List<Idea> ideas = [];

  @override
  void initState() {
    super.initState();
    loadIdeas();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = ideas.map((item) => item.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(taskList));
  }

  Future<void> loadIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final taskString = prefs.getString('tasks');
    if (taskString != null) {
      final List<dynamic> taskJson = jsonDecode(taskString);
      setState(() {
        ideas = taskJson.map((json) => Idea.fromJson(json)).toList();
      });
    }
  }

  void toggleCheckbox(bool? value, int index) {
    setState(() {
      ideas[index].toggleCompletion();
    });
    saveTasks(); 
  }

  void addIdea(String title) {
    setState(() {
      ideas.add(Idea(title: title));
    });
    saveTasks(); 
  }

  void deleteCompletedIdeas() {
    setState(() {
      ideas.removeWhere((item) => item.isCompleted);
    });
    saveTasks(); 
  }

  void showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Idea'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter idea title'),
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
                  addIdea(controller.text);
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

  @override
  Widget build(BuildContext context) {
    final pendingTasks = ideas.where((idea) => !idea.isCompleted).toList();
    final completedTasks = ideas.where((idea) => idea.isCompleted).toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingTasks.isNotEmpty) ...[
              const Text(
                'To-Do',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(pendingTasks[index].title),
                      value: pendingTasks[index].isCompleted,
                      onChanged: (bool? value) {
                        toggleCheckbox(
                          value,
                          ideas.indexOf(pendingTasks[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],

            if (completedTasks.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Completed Ideas',
                    onPressed: deleteCompletedIdeas,
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(
                        completedTasks[index].title,
                        style: const TextStyle(
                          color: Colors.grey, // Gray color for completed tasks
                          decoration:
                              TextDecoration
                                  .lineThrough, // Strikethrough effect
                        ),
                      ),
                      value: completedTasks[index].isCompleted,
                      onChanged: (bool? value) {
                        toggleCheckbox(
                          value,
                          ideas.indexOf(completedTasks[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
