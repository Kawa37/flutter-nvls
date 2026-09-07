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
  List data = [];
  Map dataById = {};
  List order = [];
  bool _loading = true;

  List getOrder(Map dataById) {
    if (dataById.isEmpty) return [];
    final savedOrder = box.get('sorting-order', defaultValue: {}) as Map;
    print('[box.get sorting order] $savedOrder');

    final needsRebuild =
        savedOrder.length != dataById.length ||
        !dataById.keys.every((id) => savedOrder.containsKey(id));

    Map orderMap;
    if (needsRebuild) {
      Map newOrder = {
        for (var id in dataById.keys)
          id: savedOrder.containsKey(id) ? savedOrder[id] : 0,
      };
      box.put('sorting-order', newOrder);
      orderMap = newOrder;
    } else {
      orderMap = savedOrder;
    }

    List<String> order = orderMap.keys.cast<String>().toList()
      ..sort((a, b) => orderMap[b].compareTo(orderMap[a]));
    return order;
  }

  Future<void> loadData() async {
    final text = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = jsonDecode(text);
      dataById = {for (var e in data) e['id'] as String: e['value'] as Map};
      order = getOrder(dataById);
      _loading = false;
      print('order from load: $order');
    });
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || order.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Library [${dataById.length}]'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['sorting-order']),
        builder: (context, Box box, _) {
          order = getOrder(dataById);
          print('order from listenable: $order');
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: BoxBorder.all(
                              width: .5,
                              color: Colors.white,
                            ),
                          ),
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
