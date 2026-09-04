import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/chaplist.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  const HomePage(this.title, {super.key});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('mybox');
  late Map sorter;
  List data = [];

  Future<void> loadData() async {
    final text = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = jsonDecode(text);
    });
  }

  @override
  void initState() {
    super.initState();
    final raw = box.get('nvl-sorter', defaultValue: {}) as Map;
    sorter = raw;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dataById = {for (var e in data) e['id'] as String: e['value'] as Map};

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['sorting-order']),
        builder: (context, Box box, _) {
          final saved = box.get('sorting-order', defaultValue: {}) as Map;
          Map orderMap;

          if (data.length != saved.length) {
            Map newOrder = {};
            for (var e in data) {
              final id = e['id'];
              newOrder[id] = saved.containsKey(id) ? saved[id] : 0;
            }
            box.put('sorting-order', newOrder);
            orderMap = newOrder;
          } else {
            orderMap = saved;
          } // Convert everything to a comparable num before sorting

          List<String> order = orderMap.keys.cast<String>().toList()
            ..sort((a, b) => orderMap[b].compareTo(orderMap[a]));

          return Scaffold(
            body: GridView.builder(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
              ),
              itemCount: order.length,
              itemBuilder: (context, index) {
                final String id = order[index];
                final Map value = dataById[id]!;

                return InkWell(
                  onTap: () {
                    box.put('the-last', id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapList(data: dataById, id: id),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      spacing: 5,
                      children: [
                        InkWell(
                          // borderRadius: BorderRadius.circular(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/nvls/$id/cover_$id.webp',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            value['title'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final id = box.get('last-nvl', defaultValue: '') as String;
          if (id.isEmpty) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapList(id: id, data: dataById),
            ),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
