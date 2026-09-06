import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:novels/reading.dart';
import 'package:flutter/services.dart' show rootBundle;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  final box = Hive.box('mybox');
  List history = [];
  Map data = {};
  void getData() async {
    final raw = box.get('history', defaultValue: []) as List;
    final rawData = await rootBundle.loadString('assets/data.json');
    setState(() {
      history = raw;
      data = {
        for (var e in jsonDecode(rawData)) e['id'] as String: e['value'] as Map,
      };
    });
  }

  void saveOrder(String id) {
    final raw = box.get('sorting-order', defaultValue: {}) as Map;
    Map yeah = raw;
    yeah[id] = DateTime.now().millisecondsSinceEpoch;

    box.put('sorting-order', yeah);
    box.put('last-nvl', id);
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      // appBar: AppBar(),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          if (history.isNotEmpty) {
            return ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(),
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              title: Text(data[history[index]['id']]['title']),
              subtitle: Text(history[index]['chap'].toString()),
              onTap: () {
                String id = history[index]['id'];
                int chap = history[index]['chap'];
                saveOrder(id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Reading(id: id, chapter: chap),
                  ),
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}
