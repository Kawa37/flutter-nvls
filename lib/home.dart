import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:novels/chaplist.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.title, {super.key});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('mybox');
  late Map sorter;
  @override
  void initState() {
    super.initState();
    final raw = box.get('nvl-sorter', defaultValue: {}) as Map;
    sorter = raw;
  }

  final List<Map> data = [
    {
      'id': 'assassinate_wonderwind',
      'value': {
        'chapters': 25,
        'readingKey': 'aw_reading',
        'title': 'Assassinate Wonderwind',
        'description': '',
      },
    },
    {
      'id': 'bloodstone_immortal_five_element_sovereign',
      'value': {
        'chapters': 10,
        'readingKey': 'bifes_reading',
        'title': 'Bloodstone Immortal Five Element Sovereign',
        'description': '',
      },
    },
    {
      'id': 'clara_casewell,_attorney_to_the_villainess',
      'value': {
        'chapters': 60,
        'readingKey': 'ccattv_reading',
        'title': 'Clara Casewell, Attorney To The Villainess',
        'description': '',
      },
    },
    {
      'id': "i_am_the_heroine's_master",
      'value': {
        'chapters': 10,
        'readingKey': 'iathm_reading',
        'title': "I Am The Heroine's Master",
        'description': '',
      },
    },
    {
      'id': 'i_became_the_scoundrel_in_the_popular_dating_sim',
      'value': {
        'chapters': 186,
        'readingKey': 'ibtsitpds_reading',
        'title': 'I Became The Scoundrel In The Popular Dating Sim',
        'description': '',
      },
    },
    {
      'id': 'leaving_a_legacy',
      'value': {
        'chapters': 10,
        'readingKey': 'lal_reading',
        'title': 'Leaving A Legacy',
        'description': '',
      },
    },
    {
      'id': 'max_level_sword_sage',
      'value': {
        'chapters': 11,
        'readingKey': 'mlss_reading',
        'title': 'Max Level Sword Sage',
        'description': '',
      },
    },
    {
      'id': 'mother_of_learning',
      'value': {
        'chapters': 30,
        'readingKey': 'mol_reading',
        'title': 'Mother Of Learning',
        'description': '',
      },
    },
    {
      'id': 'my_glorius_life',
      'value': {
        'chapters': 18,
        'readingKey': 'mgl_reading',
        'title': 'My Glorius Life',
        'description': '',
      },
    },
    {
      'id': 'others_summon_dragons_i_summon_legendary_knights',
      'value': {
        'chapters': 10,
        'readingKey': 'osdislk_reading',
        'title': 'Others Summon Dragons I Summon Legendary Knights',
        'description': '',
      },
    },
    {
      'id': 'reverend_insanity',
      'value': {
        'chapters': 10,
        'readingKey': 'ri_reading',
        'title': 'Reverend Insanity',
        'description': '',
      },
    },
    {
      'id': 'rock_falls,_everyone_dies',
      'value': {
        'chapters': 21,
        'readingKey': 'rfed_reading',
        'title': 'Rock Falls, Everyone Dies',
        'description': '',
      },
    },
    {
      'id': 'shadow_slave',
      'value': {
        'chapters': 1400,
        'readingKey': 'ss_reading',
        'title': 'Shadow Slave',
        'description': 'Ranks:\n\n1. Dormant Dormant Beast\n\n2. Awakened Awakened Monster\n\n3. Ascended Fallen Demon\n\n4. Transcendent Corrupted Devil\n\n5. Supreme Great Tyrant\n\n6. Sacred Cursed Terror\n\n7. Divine UnBoly Titan',
      },
    },
    {
      'id': 'supreme_magus',
      'value': {
        'chapters': 10,
        'readingKey': 'sm_reading',
        'title': 'Supreme Magus',
        'description': '',
      },
    },
    {
      'id': "the_author's_pov",
      'value': {
        'chapters': 10,
        'readingKey': 'tap_reading',
        'title': "The Author's Pov",
        'description': '',
      },
    },
    {
      'id': 'the_dungeon_of_arceus',
      'value': {
        'chapters': 18,
        'readingKey': 'tdoa_reading',
        'title': 'The Dungeon Of Arceus',
        'description': '',
      },
    },
    {
      'id': 'the_perfect_run',
      'value': {
        'chapters': 50,
        'readingKey': 'tpr_reading',
        'title': 'The Perfect Run',
        'description': '',
      },
    },
    {
      'id': 'the_second_coming_of_gluttony',
      'value': {
        'chapters': 10,
        'readingKey': 'tscog_reading',
        'title': 'The Second Coming Of Gluttony',
        'description': '',
      },
    },
    {
      'id': 'the_worst_litrpg_story_on_royal_road',
      'value': {
        'chapters': 28,
        'readingKey': 'twlsorr_reading',
        'title': 'The Worst Litrpg Story On Royal Road',
        'description': '',
      },
    },
    {
      'id': 'throne_of_time',
      'value': {
        'chapters': 10,
        'readingKey': 'tot_reading',
        'title': 'Throne Of Time',
        'description': '',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
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
    }

    // sorted list of ids, biggest value first
    List<String> order = orderMap.keys.cast<String>().toList()
      ..sort((a, b) => orderMap[b]!.compareTo(orderMap[a]!));

    // quick lookup: id -> value map, so we don't search `data` on every build
    final dataById = {for (var e in data) e['id'] as String: e['value'] as Map};

    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(10),
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
                  builder: (context) =>
                      ChapList(nvlTitle: value['title'], id: id),
                ),
              );
            },
            child: Card(
              child: Column(
                spacing: 5,
                children: [
                  Image.asset('assets/nvl-imgs/cover_$id.webp'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
