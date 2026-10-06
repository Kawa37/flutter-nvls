import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'utils.dart';

import 'main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final box = Hive.box('mybox');
  bool loading = false;
  Map colors = {
    'amber': Colors.amber,
    'red': Colors.red,
    'blue': Colors.blue,
    "purple": Colors.purple,
    'orange': Colors.orange,
    'lime': Colors.lime,
    'teal': Colors.teal,
    'green': Colors.green,
  };

  void changeThemeColor(MaterialColor color) {}

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: themeMode,
          builder: (context, mode, _) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text('Theme'),
                  SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: colors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, idx) {
                        final i = colors.keys.toList()[idx];
                        return FilledButton(
                          onPressed: () {
                            themeColor.value = colors[i];
                            box.put('color', i);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors[i],
                          ),

                          child: Text(i),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      themeMode.value = themeMode.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                      box.put(
                        'theme',
                        themeMode.value == ThemeMode.dark ? 0 : 1,
                      );
                    },
                    child: Row(
                      children: [
                        Text('Light Mode:'),
                        Expanded(child: SizedBox()),

                        Icon(
                          mode != ThemeMode.light ? Icons.sunny : Icons.bedtime,
                          color: Theme.of(context).colorScheme.primary,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      setState(() => loading = true);
                      await restoreData();
                      setState(() => loading = false);
                    },
                    child: Row(
                      children: [
                        Text('Restore data'),
                        Expanded(child: SizedBox()),

                        Icon(Icons.download),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
