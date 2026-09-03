import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Reading extends StatefulWidget {
  final int chapter;
  final String nvlTitle;
  const Reading({super.key, required this.chapter, this.nvlTitle = ''});

  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  Future<void> loadChap() async {
    final String Chap = await rootBundle.loadString('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nvlTitle)),
      body: Column(children: [Text('Reading Here')]),
    );
  }
}
