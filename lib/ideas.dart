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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To-Do',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(items[index].title),
                    value: items[index].isCompleted,
                    onChanged: (bool? value) {
                      toggleCheckbox(value, index);
                    },
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
