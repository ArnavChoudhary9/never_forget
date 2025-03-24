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
  final List<Idea> items = [
    Idea(title: 'Item 1'),
    Idea(title: 'Item 2'),
    Idea(title: 'Item 3'),
    Idea(title: 'Item 4'),
  ];

  void toggleCheckbox(bool? value, int index) {
    setState(() {
      items[index].toggleCompletion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ideas'),
        ],
      ),
    );
  }
}
