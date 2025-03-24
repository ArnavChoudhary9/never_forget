import 'package:flutter/material.dart';

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
}

class _IdeasState extends State<Ideas> {
  final List<Idea> items = [];

  void toggleCheckbox(bool? value, int index) {
    setState(() {
      items[index].toggleCompletion();
    });
  }

  void addIdea(String title) {
    setState(() {
      items.add(Idea(title: title));
    });
  }

  void deleteCompletedIdeas() {
    setState(() {
      items.removeWhere((item) => item.isCompleted);
    });
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
    final pendingTasks = items.where((item) => !item.isCompleted).toList();
    final completedTasks = items.where((item) => item.isCompleted).toList();

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
                          items.indexOf(pendingTasks[index]),
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
                    tooltip: 'Delete Completed Tasks',
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
                          items.indexOf(completedTasks[index]),
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
