import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

import 'dart:async';

class Reading extends StatefulWidget {
  final int chapter;
  final String id;
  const Reading({super.key, required this.id, required this.chapter});

  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  late final ScrollController _scrollController;
  Timer? _debounce;
  String? chap;
  List marks = [];
  bool marked = false;
  bool savePos = true;
  bool saved = false;
  bool read = false;
  late Map data;
  late int savedChap;
  Future<void> loadChap() async {
    final text = await rootBundle.loadString(
      'assets/nvls/${widget.id}/${widget.chapter}.txt',
    );
    final rawData =
        jsonDecode(await rootBundle.loadString('assets/data.json')) as List;
    final rawMarks =
        box.get('${widget.id}_bookmarks', defaultValue: []) as List;
    savedChap = box.get('last-${widget.id}-chap', defaultValue: 1) as int;
    if (widget.chapter < savedChap) {
      setState(() {
        data = {for (var e in rawData) e['id'] as String: e['value'] as Map};
        read = true;
      });
    }
    setState(() {
      chap = text;
      marks = rawMarks;
      marked = marks.contains(widget.chapter);
    });
  }

  final box = Hive.box('mybox');

  void markChap() {
    setState(() {
      if (!marked) {
        marks.add(widget.chapter);
        marked = true;
        return;
      }

      marks.remove(widget.chapter);
      marked = false;
    });
    box.put('${widget.id}_bookmarks', marks);
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    loadChap().then((_) => _restoreScrollPosition());
    _scrollController.addListener(_onScroll);
  }

  void _restoreScrollPosition() {
    final savedOffset = box.get(
      '${widget.id}_${widget.chapter}_scroll',
      defaultValue: null,
    );
    if (savedOffset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            duration: Duration(microseconds: 1000),
            curve: Curves.bounceInOut,
            (savedOffset as double).clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        }
      });
    }
  }

  void saveProg() {
    if (saved) return;
    box.delete('${widget.id}_${widget.chapter}_scroll');
    box.put('last-${widget.id}-chap', widget.chapter + 1);
    setState(() {
      savePos = false;
      saved = true;
      read = true;
    });
    print('saved');
  }

  void _onScroll() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _saveScrollPosition);
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        widget.chapter >= savedChap) {
      saveProg();
    }
  }

  void _saveScrollPosition() {
    if (!savePos) return;
    if (!_scrollController.hasClients) return;
    box.put('${widget.id}_${widget.chapter}_scroll', _scrollController.offset);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _saveScrollPosition(); // safety net on normal navigation away
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapter} ${read ? '(Read)' : ''}'),
      ),
      body: Scrollbar(
        controller: _scrollController,
        thickness: 15,
        radius: Radius.circular(10),
        interactive: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          child: chap == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Text(chap!, style: TextStyle(fontSize: 20)),
                    SizedBox(height: 100),
                    if (widget.chapter < savedChap - 1)
                      FilledButton(
                        onPressed: () {
                          saveProg();
                        },
                        child: savePos ? Text('Save?') : Icon(Icons.check),
                      ),
                    SizedBox(height: 100),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: .spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                if (widget.chapter - 1 > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Reading(id: widget.id, chapter: widget.chapter - 1),
                    ),
                  );
                }
              },
              child: Icon(Icons.keyboard_arrow_left, size: 26),
            ),
            ElevatedButton(
              onPressed: () {
                markChap();
              },
              child: Icon(
                !marked ? Icons.bookmark_add_outlined : Icons.bookmark,
                size: 26,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.chapter + 1 > data[widget.id]['chapters']) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Reading(id: widget.id, chapter: widget.chapter + 1),
                  ),
                );
              },
              child: Icon(Icons.keyboard_arrow_right, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
