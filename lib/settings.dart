import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/home.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'utils.dart';
import 'main.dart';
import 'change_data_base.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final box = Hive.box('mybox');
  bool loading = false;

  void setPref(String key, dynamic value) {
    final prefs = box.get('prefs', defaultValue: {}) as Map;
    prefs[key] = value;
    box.put('prefs', prefs);
  }

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
                  // theme selection
                  Text('Theme'),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var color in colors.keys.toList())
                          Row(
                            children: [
                              FilledButton(
                                onPressed: () {
                                  themeColor.value = colors[color];
                                  setPref('theme_color', color);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors[color],
                                ),
                                child: Text(color),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // fonts selection
                  SizedBox(height: 30),
                  Text('Fonts'),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var fontS in fonts)
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  font.value = fontS;
                                  setPref('default_font', fontS);
                                },
                                child: Text(
                                  fontS,
                                  style: TextStyle(fontFamily: fontS),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // light mode
                  SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      themeMode.value = themeMode.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                      setPref(
                        'theme_color',
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

                  // restore data
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
                  // FilledButton( //   onPressed: () async { //     if (box.containsKey('novels')) return; //     final data = await rootBundle.loadString( //       'assets/data.json', //     ); //     await writeFile('backup-1.json', box.toMap(), true); //     final Map newData = transfer( //       box.toMap(), //       jsonDecode(data), //     ); //     if (newData.isEmpty) return; //     await box.clear(); //     await box.putAll(newData); //   }, //   child: Text('change database'), // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
