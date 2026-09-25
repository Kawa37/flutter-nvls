import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
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

  Future<bool> _getConfirmation() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete all history?'),
        content: Text('You sure bro?'),
        actions: [
          TextButton(
            onPressed: () {
              return Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              return Navigator.of(context).pop(true);
            },
            child: Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      return true;
    }
    return false;
  }

  Future<void> saveOrder(String id) async {
    final raw = box.get('sorting-order', defaultValue: {}) as Map;
    Map yeah = raw;
    yeah[id] = DateTime.now().millisecondsSinceEpoch;

    await box.put('sorting-order', yeah);
    await box.put('last-nvl', id);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            child: Icon(
              Icons.delete_forever_outlined,
              size: 26,
              color: Colors.red,
            ),
            onPressed: () async {
              final confir = await _getConfirmation();
              if (confir) box.delete('history');
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(child: Text('No History'))
          : ValueListenableBuilder(
              valueListenable: box.listenable(keys: ['history']),
              builder: (context, Box box, child) {
                history = box.get('history', defaultValue: []) as List;
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: .5),
                      ),
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      title: Text(data[history[index]['id']]['title']),
                      subtitle: Text(history[index]['chap'].toString()),
                      onTap: () async {
                        String id = history[index]['id'];
                        int chap = history[index]['chap'];
                        await saveOrder(id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Reading(id: id, chapter: chap),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
