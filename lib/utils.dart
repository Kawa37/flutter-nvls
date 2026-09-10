import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

Future<Uri?> pickAndPersistFolder() async {
  final uri = await saf.openDocumentTree();
  return uri;
}

Future<String?> getUri(Box box) async {
  // ✅ typed as String? instead of dynamic Future
  final savedUriStr = box.get('saf-folder-uri') as String?;

  if (savedUriStr != null) return savedUriStr;

  final picked = await pickAndPersistFolder();
  if (picked == null) {
    return null; // ✅ user cancelled — don't save "null" as a string
  }

  await box.put('saf-folder-uri', picked.toString());
  return picked.toString();
}

Future<void> writeToSafFolder(Box box, String filename, String contents) async {
  final savedUriStr = await getUri(box); // now properly String?
  if (savedUriStr == null) return; // ✅ this check actually works now

  final folderUri = Uri.parse(savedUriStr);
  final fileUri = await saf.createFileAsString(
    folderUri,
    mimeType: 'application/json',
    displayName: filename,
    content: contents,
  );
  print('Wrote to: $fileUri');
}
