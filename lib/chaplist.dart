import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/reading.dart';

class ChapList extends StatefulWidget {
  final String nvlTitle;
  final String id;

  const ChapList({super.key, this.nvlTitle = 'None', required this.id});

  @override
  State<ChapList> createState() => _ChapListState();
}

class _ChapListState extends State<ChapList> {
  final box = Hive.box('mybox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nvlTitle)),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Image.asset(
                  'assets/nvl-imgs/cover_${widget.id}.webp',
                  width: 200,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    widget.nvlTitle,
                    style: TextStyle(fontSize: 18, overflow: TextOverflow.clip),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          for (int i = 1; i < 21; i++)
            ListTile(
              title: Text('$i'),
              onTap: () {
                final raw = box.get('sorting-order', defaultValue: {}) as Map;
                Map yeah = raw;
                yeah[widget.id] = DateTime.now();
                box.put('sorting-order', yeah);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Reading(chapter: i)),
                );
              },
            ),
        ],
      ),
    );
  }
}
