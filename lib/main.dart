import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/home.dart';
import 'package:novels/history.dart';
import 'package:novels/settings.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:novels/reading.dart';

final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('mybox');

  final box = Hive.box('mybox');
  final int rawTheme = box.get('theme', defaultValue: 0);
  final initTheme = rawTheme==0?ThemeMode.dark : ThemeMode.light;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, currMode, child) {
        return MaterialApp(
          home: MainScreen(),
          themeMode: currMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
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
      },
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
  final box = Hive.box('mybox');

  final List<Widget> pages = [HomePage('Library'), HistoryPage(), Settings()];
  final List<String> titles = ['Library', 'History', 'Settings'];

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
    final PageController pageController = PageController();
    return Scaffold(
      body: PageView(
        onPageChanged: (value) => setState(() => currPage = value),
        controller: pageController,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currPage,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        onDestinationSelected: (index) {
          final his = box.get('history', defaultValue: []) as List;
          final id = his.first['id'];
          final chap = his.first['chap'];
          if (currPage == index && index == 1) {
            print('dbl');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Reading(id: id, chapter: chap),
              ),
            );
          } else if (currPage == index && index == 2) {
            themeMode.value = themeMode.value == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          } else {
            setState(() {
              currPage = index;
            });
            pageController.jumpToPage(index);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(
              Icons.collections_bookmark,
              color: themeMode.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(
              Icons.history,
              color: themeMode.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(
              Icons.settings,
              color: themeMode.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
