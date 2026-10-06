import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:novels/home.dart' show requestStoragePermission, getFolder;

final _box = Hive.box('mybox');

Future<File> backupData({String filename = 'backup.json'}) async {
  final granted = await requestStoragePermission();
  if (!granted) {
    throw Exception('Storage permission denied');
  }

  final folder = await getFolder();
  final file = File('${folder.path}/$filename');

  final Map<dynamic, dynamic> allData = _box.toMap();

  final jsonStr = const JsonEncoder.withIndent('  ').convert(allData);

  return file.writeAsString(jsonStr, mode: FileMode.write);
}

Future<void> restoreData({String filename = 'backup.json'}) async {
  final granted = await requestStoragePermission();
  if (!granted) {
    throw Exception('Storage permission denied');
  }

  final folder = await getFolder();
  final file = File('${folder.path}/$filename');

  if (!await file.exists()) {
    throw Exception('Backup file not found: ${file.path}');
  }

  final raw = await file.readAsString();
  final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;

  await _box.putAll(data);
}
