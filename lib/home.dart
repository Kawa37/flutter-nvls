import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/chaplist.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

import 'main.dart';

Future<bool> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  }

  var status = await Permission.manageExternalStorage.request();
  if (status.isGranted) return true;

  status = await Permission.storage.request();
  return status.isGranted;
}

Future<Directory> getFolder() async {
  final folder = Directory('/storage/emulated/0/Novels');
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  return folder;
}

Future<void> writeFile(String filename, String data) async {
  final folder = await getFolder();
  final file = File('${folder.path}/$filename');
  await file.writeAsString(data, mode: FileMode.write);
}

Future<String> readFile(String filename) async {
  final folder = await getFolder();
  final file = File('${folder.path}/$filename');
  if (!await file.exists()) return '';
  return await file.readAsString();
}

class HomePage extends StatefulWidget {
  const HomePage(this.title, {super.key});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('mybox');
  List data = [];
  bool showHidden = false;
  List hiddenNvls = [];
  Map dataById = {};
  List order = [];
  List visibleOrder = [];
  bool _loading = true;
  bool isExtended = true;

  List getOrder(Map dataById) {
    if (dataById.isEmpty) return [];
    final savedOrder = box.get('sorting-order', defaultValue: {}) as Map;

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
    final rawHiddenNvls = box.get('hidden-nvls', defaultValue: []) as List;
    setState(() {
      data = jsonDecode(text);
      dataById = {for (var e in data) e['id'] as String: e['value'] as Map};
      order = getOrder(dataById);
      visibleOrder = order.where((element) {
        if (showHidden) {
          return hiddenNvls.contains(element) ? true : false;
        } else if (!showHidden) {
          return hiddenNvls.contains(element) ? false : true;
        }
        return true;
      }).toList();
      hiddenNvls = rawHiddenNvls;
      _loading = false;
    });
    await saveData(dataById);
  }

  bool isDataSaved = false;
  Future<void> saveData(Map data) async {
    final int today = int.parse('${DateTime.now().day}${DateTime.now().hour}');
    final lastTimeSaved =
        box.get('last-file-save-date', defaultValue: 0) as int;

    if (today - lastTimeSaved >= 6) {
      await writeFile('data.txt', data.toString());
      print('saved data');
      setState(() => isDataSaved = true);
    } else {
      setState(() => isDataSaved = true);
    }
  }

  void toggleHide() {
    print('${DateTime.now().day}${DateTime.now().hour}');
    setState(() {
      showHidden = !showHidden;
      visibleOrder = order.where((element) {
        if (showHidden) {
          return hiddenNvls.contains(element) ? true : false;
        } else if (!showHidden) {
          return hiddenNvls.contains(element) ? false : true;
        }
        return true;
      }).toList();
    });
  }

  Future<void> toggleHideNvl(String id) async {
    setState(() {
      if (!(hiddenNvls.contains(id))) {
        hiddenNvls.add(id);
      } else {
        hiddenNvls.remove(id);
      }
    });
    await box.put('hidden-nvls', hiddenNvls);
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || order.isEmpty || !isDataSaved) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              themeMode.value = themeMode.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
              box.put('theme', themeMode.value == ThemeMode.dark ? 0 : 1);
            },

            child: Icon(
              themeMode.value != ThemeMode.light ? Icons.sunny : Icons.bedtime,
              size: 26,
            ),
          ),
        ],
        title: InkWell(
          onDoubleTap: () => toggleHide(),
          child: ValueListenableBuilder(
            valueListenable: box.listenable(keys: ['sorting-order']),
            builder: (context, Box box, _) {
              return Text(
                '${showHidden ? 'Hidden' : 'Library'} [${visibleOrder.length}]',
              );
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['sorting-order']),
        builder: (context, Box box, _) {
          order = getOrder(dataById);
          visibleOrder = order.where((element) {
            if (showHidden) {
              return hiddenNvls.contains(element) ? true : false;
            } else if (!showHidden) {
              return hiddenNvls.contains(element) ? false : true;
            }
            return true;
          }).toList();

          return NotificationListener<UserScrollNotification>(
            onNotification: (noti) {
              if (noti.direction == ScrollDirection.forward) {
                if (!isExtended) setState(() => isExtended = true);
              } else if (noti.direction == ScrollDirection.reverse) {
                if (isExtended) setState(() => isExtended = false);
              }
              return true;
            },
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
              ),
              itemCount: visibleOrder.length,
              itemBuilder: (context, index) {
                final String id = visibleOrder[index];
                final Map value = dataById[id]!;

                return InkWell(
                  onTap: () async {
                    box.put('the-last', id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapList(data: dataById, id: id),
                      ),
                    );
                  },
                  onLongPress: () async {
                    await toggleHideNvl(id);
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
      floatingActionButton: FloatingActionButton.extended(
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

        icon: Icon(Icons.play_arrow),
        label: Text('Continue', style: TextStyle(fontSize: 18)),
        isExtended: isExtended,
      ),
    );
  }
}
