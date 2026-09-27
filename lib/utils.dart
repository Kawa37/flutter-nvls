import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
// Reusing what you already built in home.dart instead of duplicating it:
// requestStoragePermission() handles the MANAGE_EXTERNAL_STORAGE prompt,
// getFolder() returns/creates /storage/emulated/0/Novels.
import 'package:novels/home.dart' show requestStoragePermission, getFolder;

final _box = Hive.box('mybox');

/// Dumps every key/value currently in the Hive box to a JSON file on
/// the device's storage (Novels/backup.json).
///
/// Equivalent to something like:
///   JS:     fs.writeFileSync('backup.json', JSON.stringify(localStorage))
///   Python: json.dump(dict(box), open('backup.json', 'w'))
/// i.e. we just serialize the whole key-value store to disk.
///
/// Returns the File that was written, so callers can show its path
/// or share it. Throws if permission is denied.
Future<File> backupData({String filename = 'backup.json'}) async {
  final granted = await requestStoragePermission();
  if (!granted) {
    throw Exception('Storage permission denied');
  }

  final folder = await getFolder();
  final file = File('${folder.path}/$filename');

  // box.toMap() grabs every key Hive currently has (history, sorting-order,
  // hidden-nvls, per-chapter scroll positions, bookmarks, theme, etc.)
  // in one shot - no need to enumerate keys by hand.
  final Map<dynamic, dynamic> allData = _box.toMap();

  // Pretty-printed so the backup is human-readable/diffable if you ever
  // want to peek at it. Every value already stored (List/Map/int/bool/
  // String) is JSON-safe, so this just works.
  final jsonStr = const JsonEncoder.withIndent('  ').convert(allData);

  return file.writeAsString(jsonStr, mode: FileMode.write);
}

/// Reads a JSON backup file previously written by [backupData] and
/// restores every key/value back into the Hive box.
///
/// This OVERWRITES any existing keys with the same name (last-write-wins),
/// same as calling box.put for each entry - like Object.assign(store, backup)
/// in JS, or dict.update(backup) in Python.
///
/// Throws if permission is denied or the file doesn't exist.
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

  // putAll writes every entry in one batch instead of looping put() calls.
  await _box.putAll(data);
}
