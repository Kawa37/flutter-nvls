import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/reading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChapList extends StatefulWidget {
  final String id;
  final Map data;
  const ChapList({super.key, required this.id, required this.data});

  @override
  State<ChapList> createState() => _ChapListState();
}

class _ChapListState extends State<ChapList> {
  final box = Hive.box('mybox');
  bool showBookmarks = false;

  Future<void> saveOrder() async {
    final raw = box.get('sorting-order', defaultValue: {}) as Map;
    Map yeah = raw;
    yeah[widget.id] = DateTime.now().millisecondsSinceEpoch;

    await box.put('sorting-order', yeah);
    await box.put('last-nvl', widget.id);
    print('saved sorting-order: ${box.get('sorting-order')}');
  }

  void toggleBookmark(int chap) {
    final marks = box.get('${widget.id}_bookmarks', defaultValue: []) as List;
    if (marks.contains(chap)) {
      marks.remove(chap);
    } else {
      marks.add(chap);
    }
    box.put('${widget.id}_bookmarks', marks);
  }

  void toggleRead(int chap, int lastChap) {
    final bool isRead = chap < lastChap;
    final newLastChap = isRead ? chap : chap + 1;

    box.delete('${widget.id}_${chap}_scroll');
    box.put('last-${widget.id}-chap', newLastChap);
  }

  Future<bool> _showConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return true;
    }
    return false;
  }

  void deleteNvlData() async {
    bool confirmation = await _showConfirmation();
    if (confirmation) {
      box.deleteAll(['last-${widget.id}-chap', '${widget.id}_bookmarks']);
    }
  }

  bool ascended = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final Map data = widget.data[widget.id];
    final String nvlTitle = data['title'];
    final range = ascended
        ? List<int>.generate(data['chapters'], (i) => i + 1)
        : List<int>.generate(data['chapters'], (i) => data['chapters'] - i);

    return Scaffold(
      appBar: AppBar(
        title: Text(nvlTitle),
        actions: [
          TextButton(
            child: Icon(
              Icons.delete_forever_outlined,
              size: 26,
              color: Colors.red,
            ),
            onPressed: () {
              deleteNvlData();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(
          keys: ['last-${widget.id}-chap', '${widget.id}_bookmarks'],
        ),
        builder: (context, Box box, _) {
          final marks =
              box.get('${widget.id}_bookmarks', defaultValue: []) as List;
          final lastChap =
              box.get('last-${widget.id}-chap', defaultValue: 1) as int;

          return Scrollbar(
            thickness: 15,
            radius: Radius.circular(10),
            interactive: true,
            child: ListView(
              padding: EdgeInsets.only(bottom: 100),
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(width: .5, color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/nvls/${widget.id}/cover_${widget.id}.webp',
                            width: 150,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            nvlTitle,
                            style: TextStyle(fontSize: 18),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),
                Card(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          '${data['chapters']} chapters',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),

                        InkWell(
                          onTap: () {
                            setState(() {
                              showBookmarks = !showBookmarks;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.bookmark, color: theme.secondary),
                              Text(
                                '${marks.length}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              ascended = !ascended;
                            });
                          },
                          child: !ascended
                              ? Icon(Icons.arrow_downward)
                              : Icon(Icons.arrow_upward),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                for (int i in range)
                  if (!(showBookmarks && !(marks.contains(i))))
                    Builder(
                      builder: (context) {
                        final isBookmarked = marks.contains(i);
                        final isRead = i < lastChap;
                        BuildContext? tileContext;
                        return Slidable(
                          key: ValueKey(i),

                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: ScrollMotion(),
                            dismissible: DismissiblePane(
                              dismissThreshold: .3,
                              confirmDismiss: () async {
                                toggleBookmark(i);
                                if (tileContext != null) {
                                  Slidable.of(tileContext!)?.close();
                                }
                                return false;
                              },
                              onDismissed: () {},
                            ),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  toggleBookmark(i);
                                },
                                icon: isBookmarked
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark_add,
                                label: isBookmarked ? 'Unmark' : 'Bookmark',
                                backgroundColor: isBookmarked
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ],
                          ),

                          startActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            dismissible: DismissiblePane(
                              dismissThreshold: .3,
                              confirmDismiss: () async {
                                toggleRead(i, lastChap);
                                await saveOrder();
                                if (tileContext != null) {
                                  Slidable.of(tileContext!)?.close();
                                }
                                return false;
                              },
                              onDismissed: () {},
                            ),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  toggleRead(i, lastChap);
                                  await saveOrder();
                                },
                                backgroundColor: isRead
                                    ? Colors.red
                                    : Colors.white,
                                foregroundColor: Colors.white,
                                icon: isRead
                                    ? Icons.visibility_off
                                    : Icons.check,
                                label: isRead ? 'Unread' : 'Read',
                              ),
                            ],
                          ),

                          child: Builder(
                            builder: (context) {
                              tileContext = context;
                              return ListTile(
                                title: Row(
                                  children: [
                                    if (marks.contains(i))
                                      Icon(
                                        Icons.bookmark,
                                        color: theme.secondary,
                                      ),
                                    Text(
                                      '$i',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: i < lastChap
                                            ? Colors.grey
                                            : theme.inverseSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    i < lastChap
                                        ? Text(' ')
                                        : Text(
                                            '●',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ],
                                ),
                                textColor: i < lastChap
                                    ? Colors.grey
                                    : Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: i < lastChap
                                    ? theme.surface
                                    : theme.surfaceContainer,
                                onTap: () async {
                                  await saveOrder();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Reading(chapter: i, id: widget.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final lastChap1 =
              box.get('last-${widget.id}-chap', defaultValue: 1) as int;
          if (lastChap1 <= data['chapters']) {
            await saveOrder();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Reading(id: widget.id, chapter: lastChap1),
              ),
            );
          }
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
