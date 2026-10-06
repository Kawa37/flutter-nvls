import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/chaplist.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

import 'utils.dart';

import 'dart:io';

Future<bool> requestStoragePermission() async {
  if (!Platform.isAndroid) {
    return true;
  }

  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  }

  var status = await Permission.manageExternalStorage.request();
  return status.isGranted;
}

Future<Directory> getFolder() async {
  final folder = Directory('/storage/emulated/0/Novels');
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  return folder;
}

Future<void> writeFile(String filename, data, bool json) async {
  final folder = await getFolder();
  final file = File('${folder.path}/$filename');

  if (!json) {
    await file.writeAsString(data, mode: FileMode.write);
  } else {
    String prettyJson = JsonEncoder.withIndent(' ').convert(data);
    await file.writeAsString(prettyJson, mode: FileMode.write);
  }
}

Future<String> readFile(String filename) async {
  final folder = await getFolder();
  final file = File('${folder.path}/$filename');

  if (!await file.exists()) return '';
  return await file.readAsString();
}

class HomePage extends StatefulWidget {
  final String title;
  const HomePage(this.title, {super.key});

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
  List selectedNvls = [];
  List visibleOrder = [];
  bool _loading = true;
  bool isExtended = true;

  Future<void> checkPermission() async {
    final storagePermission =
        box.get('storage-permission', defaultValue: false) as bool;
    if (!storagePermission) {
      bool requestStat = await requestStoragePermission();
      if (requestStat) box.put('storage-permission', true);
    }
  }

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
    try {
      await saveData(dataById);
    } catch (e) {
      debugPrint('perission error: $e');
    }
  }

  bool isDataSaved = false;
  Future<void> saveData(Map data) async {
    // final allData = {'novels': data};

    setState(() => isDataSaved = true);
  }

  void toggleHide() {
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

  List toggleSelect(String id, List selected) {
    List res = selected;
    if (selected.contains(id)) {
      res.remove(id);
    } else {
      res.add(id);
    }
    return res;
  }

  @override
  void initState() {
    super.initState();

    checkPermission();
    backupData();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || order.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: .center,
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
      appBar: AppBar(
        title: InkWell(
          onDoubleTap: () => toggleHide(),
          child: ValueListenableBuilder(
            valueListenable: box.listenable(keys: ['sorting-order']),
            builder: (context, Box box, _) {
              return selectedNvls.isEmpty
                  ? Text(
                      '${showHidden ? 'Hidden' : 'Library'} [${visibleOrder.length}]',
                    )
                  : Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() => selectedNvls = []);
                          },
                        ),
                        Text('${selectedNvls.length}'),
                        Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () async {
                            for (var i in selectedNvls) {
                              await toggleHideNvl(i);
                            }
                            selectedNvls = [];
                          },
                          icon: Icon(Icons.visibility_off_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => selectedNvls = visibleOrder);
                          },
                          icon: Icon(Icons.select_all),
                        ),
                      ],
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

          if (visibleOrder.isEmpty) {
            return Center(
              child: Text('No ${showHidden ? 'Hiddens' : 'Novels'}'),
            );
          }

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
                bool isSelect = selectedNvls.contains(id);

                return InkWell(
                  onTap: () async {
                    if (selectedNvls.isNotEmpty) {
                      setState(() {
                        selectedNvls = toggleSelect(id, selectedNvls);
                      });
                      return;
                    }
                    box.put('the-last', id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapList(data: dataById, id: id),
                      ),
                    );
                  },
                  onLongPress: () {
                    setState(() {
                      selectedNvls = toggleSelect(id, selectedNvls);
                    });
                  },
                  child: Card(
                    // color: Theme.of(context).colorScheme.surface,
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // border: isSelect
                        //     ? BoxBorder.all(color: Colors.red, width: 2)
                        //     : Border.all(color: Colors.white, width: .5),
                        color: isSelect
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                      child: Column(
                        spacing: 5,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/nvls/$id/cover_$id.webp',
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
        label: Text('Continue'),
        isExtended: isExtended,
      ),
    );
  }
}
