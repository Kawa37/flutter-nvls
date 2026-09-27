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
                  SizedBox(height: 20),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
