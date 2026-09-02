import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/home.dart';
import 'package:novels/history.dart';

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
        colorSchemeSeed: Colors.redAccent,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.redAccent,
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

  final List<Widget> pages = [HomePage(), HistoryPage()];
  final List<String> titles = ['Home', 'Search'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[currPage],
          // style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      body: Center(
        child: IndexedStack(index: currPage, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currPage,
        onDestinationSelected: (intex) {
          setState(() {
            currPage = intex;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
