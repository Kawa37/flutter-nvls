import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/home.dart';
import 'package:novels/history.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('mybox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'JetBrainsMono',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.red,
        fontFamily: 'JetBrainsMono',
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currPage = 0;

  final List<Widget> pages = [HomePage('Library'), HistoryPage()];
  final List<String> titles = ['Library', 'History'];

  List data = [];

  void load() async {
    final rawData = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = jsonDecode(rawData);
    });
  }

  @override
  void initState() {
    super.initState();

    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(index: currPage, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currPage,

        onDestinationSelected: (index) {
          setState(() {
            currPage = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Library',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
