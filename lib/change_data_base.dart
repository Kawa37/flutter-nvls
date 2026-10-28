Map transfer(Map boxData, List dataJson) {
  if (boxData.isEmpty || dataJson.isEmpty) return {};
  Map jsonData = {for (Map novel in dataJson) novel['id']: novel['value']};

  Map novelInBox = {};
  for (String novel in jsonData.keys.toList()) {
    jsonData[novel]['scroll'] = {};
    jsonData[novel]['last_chap'] = 1;
    jsonData[novel]['bookmarks'] = [];
  }

  for (String boxKey in boxData.keys.toList()) {
    for (String novelName in jsonData.keys.toList()) {
      if (boxKey.contains(novelName)) {
        novelInBox.putIfAbsent(novelName, () => []).add(boxKey);
      }
    }
  }
  for (var novel in novelInBox.keys.toList()) {
    for (String boxKey in novelInBox[novel]) {
      if (boxKey.contains('_scroll')) {
        final parts = boxKey.split('_');
        jsonData[novel]['scroll'][parts[parts.length - 2]] = boxData[boxKey];
      } else if (boxKey.startsWith('last-') && boxKey.endsWith('-chap')) {
        jsonData[novel]['last_chap'] = boxData[boxKey];
      } else if (boxKey.endsWith('_bookmarks')) {
        jsonData[novel]['bookmarks'] = boxData[boxKey];
      }
    }
  }

  final result = {
    'novels': jsonData, // the per-novel data built above
    'history': boxData['history'], // copied as-is from the backup
    'hidden_novels': boxData['hidden-nvls'],
    'prefs': {
      'storage_permission': boxData['storage-permission'],
      'theme': boxData['theme'],
      'sorting_order': boxData['sorting-order'],
      'last_novel': boxData['last-nvl'],
      'theme_color': boxData['color'],
      'default_font': boxData['default-font'],
    },
  };

  return result;
}

final Map backupdata = {
  "color": "Red",
  "deep_sea_embers_16_scroll": 7160.761904761905,
  "deep_sea_embers_17_scroll": 0.0,
  "deep_sea_embers_55_scroll": 5.714285714285552,
  "deep_sea_embers_56_scroll": 7190.087663486452,
  "default-font": "JetBrainsMono",
  "ending_maker_1_scroll": 0.0,
  "hidden-nvls": [
    "i_became_the_scoundrel_in_the_popular_dating_sim",
    "clara_casewell,_attorney_to_the_villainess",
    "i_only_love_my_greatest_enemy",
    "magical_girl_gunslinger",
    "ending_maker",
    "the_world_of_otome_games_is_tough_for_mobs",
    "kidnapped_dragons",
    "others_summon_dragons_i_summon_legendary_knights",
  ],
  "history": [
    {"id": "deep_sea_embers", "chap": 16},
    {"id": "shadow_slave", "chap": 1272},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1259},
    {"id": "deep_sea_embers", "chap": 57},
    {"id": "shadow_slave", "chap": 1257},
    {"id": "the_perfect_run", "chap": 27},
    {"id": "shadow_slave", "chap": 1252},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1249},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1244},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1245},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1243},
    {"id": "deep_sea_embers", "chap": 16},
    {"id": "shadow_slave", "chap": 1185},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 186},
    {"id": "shadow_slave", "chap": 1230},
    {"id": "magical_girl_gunslinger", "chap": 1},
    {"id": "shadow_slave", "chap": 1229},
    {"id": "the_worst_litrpg_story_on_royal_road", "chap": 3},
    {"id": "shadow_slave", "chap": 1229},
    {"id": "deep_sea_embers", "chap": 56},
    {"id": "shadow_slave", "chap": 1226},
    {"id": "mother_of_learning", "chap": 6},
    {"id": "supreme_magus", "chap": 6},
    {"id": "shadow_slave", "chap": 1220},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 186},
    {"id": "shadow_slave", "chap": 15},
    {"id": "deep_sea_embers", "chap": 55},
    {"id": "ending_maker", "chap": 1},
    {"id": "shadow_slave", "chap": 1596},
    {"id": "deep_sea_embers", "chap": 16},
    {"id": "shadow_slave", "chap": 1595},
    {"id": "deep_sea_embers", "chap": 15},
    {"id": "shadow_slave", "chap": 1600},
    {"id": "deep_sea_embers", "chap": 11},
    {"id": "shadow_slave", "chap": 1217},
    {"id": "deep_sea_embers", "chap": 10},
    {"id": "shadow_slave", "chap": 1210},
    {"id": "deep_sea_embers", "chap": 7},
    {"id": "shadow_slave", "chap": 1207},
    {"id": "super_minion", "chap": 1},
    {"id": "deep_sea_embers", "chap": 10},
    {"id": "shadow_slave", "chap": 1205},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 183},
    {"id": "shadow_slave", "chap": 1198},
    {"id": "bloodstone_immortal_five_element_sovereign", "chap": 5},
    {"id": "shadow_slave", "chap": 1190},
    {"id": "assassinate_wonderwind", "chap": 4},
    {"id": "shadow_slave", "chap": 1181},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 186},
    {"id": "shadow_slave", "chap": 1181},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 186},
    {"id": "shadow_slave", "chap": 1181},
    {"id": "the_second_coming_of_gluttony", "chap": 2},
    {"id": "shadow_slave", "chap": 1178},
    {"id": "supreme_magus", "chap": 10},
    {"id": "shadow_slave", "chap": 1171},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 184},
    {"id": "reverend_insanity", "chap": 9},
    {"id": "my_glorius_life", "chap": 16},
    {"id": "i_became_the_scoundrel_in_the_popular_dating_sim", "chap": 184},
  ],
  "last-assassinate_wonderwind-chap": 4,
  "last-clara_casewell,_attorney_to_the_villainess-chap": 40,
  "last-deep_sea_embers-chap": 17,
  "last-i_became_the_scoundrel_in_the_popular_dating_sim-chap": 187,
  "last-max_level_sword_sage-chap": 7,
  "last-mother_of_learning-chap": 6,
  "last-my_glorius_life-chap": 3,
  "last-nvl": "deep_sea_embers",
  "last-others_summon_dragons_i_summon_legendary_knights-chap": 5,
  "last-reverend_insanity-chap": 6,
  "last-rock_falls,_everyone_dies-chap": 2,
  "last-shadow_slave-chap": 1272,
  "last-supreme_magus-chap": 6,
  "last-the_author's_pov-chap": 3,
  "last-the_perfect_run-chap": 27,
  "last-the_second_coming_of_gluttony-chap": 3,
  "last-the_worst_litrpg_story_on_royal_road-chap": 3,
  "shadow_slave_1171_scroll": 4534.878045810302,
  "shadow_slave_1173_scroll": 8548.466902617018,
  "shadow_slave_1176_scroll": 7945.142857142857,
  "shadow_slave_1179_scroll": 7375.142857142857,
  "shadow_slave_1182_scroll": 12.085666563968278,
  "shadow_slave_1185_scroll": 0.0,
  "shadow_slave_1188_scroll": 8390.142857142857,
  "shadow_slave_1196_scroll": 564.2604148993528,
  "shadow_slave_1197_scroll": 8036.5714285714275,
  "shadow_slave_1202_scroll": 8.571428571428328,
  "shadow_slave_1208_scroll": 9196.571428571428,
  "shadow_slave_1216_scroll": 10965.571428571428,
  "shadow_slave_1226_scroll": 0.0,
  "shadow_slave_1229_scroll": 15605.571428571428,
  "shadow_slave_1255_scroll": 0.0,
  "shadow_slave_1257_scroll": 3752.1116617567527,
  "shadow_slave_1262_scroll": 8175.761904761905,
  "shadow_slave_1264_scroll": 7218.761904761905,
  "shadow_slave_1268_scroll": 7740.761904761905,
  "shadow_slave_1270_scroll": 0.0,
  "shadow_slave_1272_scroll": 428.19532544331014,
  "shadow_slave_1595_scroll": 0.0,
  "shadow_slave_1600_scroll": 0.0,
  "shadow_slave_bookmarks": [15, 1231],
  "sorting-order": {
    "assassinate_wonderwind": 1789017732079,
    "bloodstone_immortal_five_element_sovereign": 1789124711014,
    "clara_casewell,_attorney_to_the_villainess": 1789017574364,
    "deep_sea_embers": 1792325758464,
    "ending_maker": 1789506503547,
    "i_am_the_heroine's_master": 0,
    "i_became_the_scoundrel_in_the_popular_dating_sim": 1789940036403,
    "i_only_love_my_greatest_enemy": 0,
    "kidnapped_dragons": 0,
    "leaving_a_legacy": 0,
    "magical_girl_gunslinger": 1789808923048,
    "max_level_sword_sage": 0,
    "mother_of_learning": 1789556293164,
    "my_glorius_life": 1789017647806,
    "others_summon_dragons_i_summon_legendary_knights": 1789017586659,
    "reverend_insanity": 1789017687599,
    "rock_falls,_everyone_dies": 1789017619861,
    "shadow_slave": 1791574936869,
    "super_minion": 1789620916514,
    "supreme_magus": 1789556289727,
    "the_author's_pov": 1789017691419,
    "the_dungeon_of_arceus": 0,
    "the_perfect_run": 1790625690452,
    "the_second_coming_of_gluttony": 1788931709905,
    "the_world_of_otome_games_is_tough_for_mobs": 0,
    "the_worst_litrpg_story_on_royal_road": 1789734835674,
    "throne_of_time": 0,
  },
  "storage-permission": true,
  "the-last": "supreme_magus",
  "theme": 0,
};

final List datajson = [
  {
    "id": "assassinate_wonderwind",
    "value": {
      "chapters": 25,
      "readingKey": "aw_reading",
      "title": "Assassinate Wonderwind",
      "description": "",
    },
  },
  {
    "id": "bloodstone_immortal_five_element_sovereign",
    "value": {
      "chapters": 10,
      "readingKey": "bifes_reading",
      "title": "Bloodstone Immortal Five Element Sovereign",
      "description": "",
    },
  },
  {
    "id": "clara_casewell,_attorney_to_the_villainess",
    "value": {
      "chapters": 60,
      "readingKey": "ccattv_reading",
      "title": "Clara Casewell, Attorney To The Villainess",
      "description": "",
    },
  },
  {
    "id": "deep_sea_embers",
    "value": {
      "chapters": 60,
      "readingKey": "dse_reading",
      "title": "Deep Sea Embers",
      "description": "",
    },
  },
  {
    "id": "ending_maker",
    "value": {
      "chapters": 11,
      "readingKey": "em_reading",
      "title": "Ending Maker",
      "description": "",
    },
  },
  {
    "id": "i_am_the_heroine's_master",
    "value": {
      "chapters": 10,
      "readingKey": "iathm_reading",
      "title": "I Am The Heroine's Master",
      "description": "",
    },
  },
  {
    "id": "i_became_the_scoundrel_in_the_popular_dating_sim",
    "value": {
      "chapters": 186,
      "readingKey": "ibtsitpds_reading",
      "title": "I Became The Scoundrel In The Popular Dating Sim",
      "description": "",
    },
  },
  {
    "id": "i_only_love_my_greatest_enemy",
    "value": {
      "chapters": 10,
      "readingKey": "iolmge_reading",
      "title": "I Only Love My Greatest Enemy",
      "description": "",
    },
  },
  {
    "id": "kidnapped_dragons",
    "value": {
      "chapters": 12,
      "readingKey": "kd_reading",
      "title": "Kidnapped Dragons",
      "description": "",
    },
  },
  {
    "id": "leaving_a_legacy",
    "value": {
      "chapters": 10,
      "readingKey": "lal_reading",
      "title": "Leaving A Legacy",
      "description": "",
    },
  },
  {
    "id": "magical_girl_gunslinger",
    "value": {
      "chapters": 10,
      "readingKey": "mgg_reading",
      "title": "Magical Girl Gunslinger",
      "description": "",
    },
  },
  {
    "id": "max_level_sword_sage",
    "value": {
      "chapters": 11,
      "readingKey": "mlss_reading",
      "title": "Max Level Sword Sage",
      "description": "",
    },
  },
  {
    "id": "mother_of_learning",
    "value": {
      "chapters": 30,
      "readingKey": "mol_reading",
      "title": "Mother Of Learning",
      "description": "",
    },
  },
  {
    "id": "my_glorius_life",
    "value": {
      "chapters": 18,
      "readingKey": "mgl_reading",
      "title": "My Glorius Life",
      "description": "",
    },
  },
  {
    "id": "others_summon_dragons_i_summon_legendary_knights",
    "value": {
      "chapters": 10,
      "readingKey": "osdislk_reading",
      "title": "Others Summon Dragons I Summon Legendary Knights",
      "description": "",
    },
  },
  {
    "id": "reverend_insanity",
    "value": {
      "chapters": 10,
      "readingKey": "ri_reading",
      "title": "Reverend Insanity",
      "description": "",
    },
  },
  {
    "id": "rock_falls,_everyone_dies",
    "value": {
      "chapters": 21,
      "readingKey": "rfed_reading",
      "title": "Rock Falls, Everyone Dies",
      "description": "",
    },
  },
  {
    "id": "shadow_slave",
    "value": {
      "chapters": 1600,
      "readingKey": "ss_reading",
      "title": "Shadow Slave",
      "description": "Ranks:\n\n1. Dormant Dormant Beast\n\n2. Awakened Awakened Monster\n\n3. Ascended Fallen Demon\n\n4. Transcendent Corrupted Devil\n\n5. Supreme Great Tyrant\n\n6. Sacred Cursed Terror\n\n7. Divine UnBoly Titan",
    },
  },
  {
    "id": "super_minion",
    "value": {
      "chapters": 10,
      "readingKey": "sm_reading",
      "title": "Super Minion",
      "description": "",
    },
  },
  {
    "id": "supreme_magus",
    "value": {
      "chapters": 10,
      "readingKey": "sm_reading",
      "title": "Supreme Magus",
      "description": "",
    },
  },
  {
    "id": "the_author's_pov",
    "value": {
      "chapters": 10,
      "readingKey": "tap_reading",
      "title": "The Author's Pov",
      "description": "",
    },
  },
  {
    "id": "the_dungeon_of_arceus",
    "value": {
      "chapters": 18,
      "readingKey": "tdoa_reading",
      "title": "The Dungeon Of Arceus",
      "description": "",
    },
  },
  {
    "id": "the_perfect_run",
    "value": {
      "chapters": 50,
      "readingKey": "tpr_reading",
      "title": "The Perfect Run",
      "description": "",
    },
  },
  {
    "id": "the_second_coming_of_gluttony",
    "value": {
      "chapters": 10,
      "readingKey": "tscog_reading",
      "title": "The Second Coming Of Gluttony",
      "description": "",
    },
  },
  {
    "id": "the_world_of_otome_games_is_tough_for_mobs",
    "value": {
      "chapters": 10,
      "readingKey": "twoogitfm_reading",
      "title": "The World Of Otome Games Is Tough For Mobs",
      "description": "",
    },
  },
  {
    "id": "the_worst_litrpg_story_on_royal_road",
    "value": {
      "chapters": 28,
      "readingKey": "twlsorr_reading",
      "title": "The Worst Litrpg Story On Royal Road",
      "description": "",
    },
  },
  {
    "id": "throne_of_time",
    "value": {
      "chapters": 10,
      "readingKey": "tot_reading",
      "title": "Throne Of Time",
      "description": "",
    },
  },
];

void main() {
  transfer(backupdata, datajson);
}
