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

  void saveHistory(String id, int chap) {
    final history = box.get('history', defaultValue: []) as List;
    Map hisdata = {"id": id, "chap": chap};
    if (history.isNotEmpty && history.first['id'] != widget.id) {
      history.insert(0, hisdata);
    } else if (history.isEmpty) {
      history.add(hisdata);
    } else if (history.first['id'] == widget.id) {
      history[0] = hisdata;
    }
    box.put('history', history);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final Map data = widget.data[widget.id];
    final String nvlTitle = data['title'];

    return Scaffold(
      appBar: AppBar(title: Text(nvlTitle)),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/nvls/${widget.id}/cover_${widget.id}.webp',
                          width: 200,
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(Icons.book),
                      Text(
                        '${data['chapters']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),

                      Icon(Icons.bookmark, color: theme.secondary),
                      Text('${marks.length}', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                for (int i = data['chapters']; i > 0; i--)
                  Builder(
                    builder: (context) {
                      final isBookmarked = marks.contains(i);
                      final isRead = i < lastChap;
                      BuildContext? tileContext; // NEW: will hold a context *inside* the Slidable
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
                              onPressed: (_) => toggleBookmark(i),
                              icon: isBookmarked
                                  ? Icons.bookmark_remove
                                  : Icons.bookmark_add,
                              label: isBookmarked ? 'Unmark' : 'Bookmark',
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
                              if (tileContext != null) {
                                Slidable.of(tileContext!)?.close();
                              }
                              return false;
                            },
                            onDismissed: () {},
                          ),
                          children: [
                            SlidableAction(
                              onPressed: (_) => toggleRead(i, lastChap),
                              backgroundColor: isRead
                                  ? Colors.grey
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              icon: isRead ? Icons.visibility_off : Icons.check,
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
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: i < lastChap
                                  ? Text(' ')
                                  : Text(
                                      '-',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                              textColor: i < lastChap
                                  ? Colors.grey
                                  : Colors.white,

                              shape: RoundedRectangleBorder(
                                side: BorderSide(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: i < lastChap
                                  ? theme.surface
                                  : theme.surfaceContainer,
                              onTap: () {
                                saveHistory(widget.id, i);
                                final raw = box.get(
                                  'sorting-order',
                                  defaultValue: {},
                                ) as Map;
                                Map yeah = raw;
                                yeah[widget.id] =
                                    DateTime.now().millisecondsSinceEpoch;

                                box.put('sorting-order', yeah);
                                box.put('last-nvl', widget.id);

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
        onPressed: () {
          final lastChap1 =
              box.get('last-${widget.id}-chap', defaultValue: 1) as int;
          if (lastChap1 <= data['chapters']) {
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
