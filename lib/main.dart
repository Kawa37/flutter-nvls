import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/home.dart';
import 'package:novels/history.dart';
import 'package:novels/settings.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:novels/reading.dart';

Map colors = {
  'Amber': Colors.amber,
  'Red': Colors.red,
  'Blue': Colors.blue,
  "Purple": Colors.purple,
  'Orange': Colors.orange,
  'Lime': Colors.lime,
  'Teal': Colors.teal,
  'Green': Colors.green,
  'Indigo': Colors.indigo,
  'Pink': Colors.pink,
  'Transparent': Colors.transparent,
};

List<String> fonts = ['JetBrainsMono', 'Libron', 'Literata', 'FiraCode'];

final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

final ValueNotifier<MaterialColor> themeColor = ValueNotifier<MaterialColor>(
  Colors.red,
);

final ValueNotifier<String> font = ValueNotifier<String>('JetBrainsMono');

void getAll(Box box) {
  final int rawTheme = box.get('theme', defaultValue: 0);
  final initTheme = rawTheme == 0 ? ThemeMode.dark : ThemeMode.light;
  themeMode.value = initTheme;

  final String rawColor = box.get('color', defaultValue: 'red');
  themeColor.value = colors[rawColor] ?? Colors.red;

  final rawFont =
      box.get('default-font', defaultValue: 'JetBrainsMono') as String;
  font.value = rawFont;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('mybox');

  final box = Hive.box('mybox');
  getAll(box);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeColor, themeMode, font]),
      builder: (context, child) {
        final currMode = themeMode.value;
        final currColor = themeColor.value;
        final fontS = font.value;
        return MaterialApp(
          home: MainScreen(),
          themeMode: currMode,
          theme: ThemeData(
            colorSchemeSeed: currColor,
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: fontS,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: currColor,
            fontFamily: fontS,
            brightness: Brightness.dark,
            useMaterial3: true,
          ).copyWith(scaffoldBackgroundColor: Colors.black),
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
  final PageController pageController = PageController();

  List data = [];

  void load() async {
    final rawData = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = jsonDecode(rawData);
    });
  }

  void goHome() {
    pageController.jumpToPage(0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    load();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        goHome();
      },
      child: Scaffold(
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
            if (currPage == index && index == 1 && his.isNotEmpty) {
              final id = his.first['id'];
              final chap = his.first['chap'];
              print('dbl');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reading(id: id, chapter: chap),
                ),
              );
            }
            if (currPage == index && index == 2) {
              themeMode.value = themeMode.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              box.put('theme', themeMode.value == ThemeMode.dark ? 0 : 1);
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
      ),
    );
  }
}
