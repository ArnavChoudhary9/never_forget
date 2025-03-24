import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Custom Components
import 'package:never_forget/theme.dart';

import 'package:never_forget/ideas.dart';
import 'package:never_forget/reminders.dart';
import 'package:never_forget/photos.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: NeverForget(),
    ),
  );
}

class NeverForget extends StatelessWidget {
  const NeverForget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Never Forget',
      theme: lightTheme, // Light theme
      darkTheme: darkTheme, // Dark theme
      themeMode: themeProvider.themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Ideas()),
    Center(child: Reminders()),
    Center(child: Photos()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Never Forget')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_rounded),
            label: 'Ideas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photos'
          ),
        ],
      ),
    );
  }
}
