import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Where the repository keeps its JSON snapshot.
abstract class TrainingStore {
  Future<String?> load();
  Future<void> save(String json);
}

/// Keeps the snapshot in memory; for tests.
class MemoryTrainingStore implements TrainingStore {
  MemoryTrainingStore([this.content]);

  String? content;

  @override
  Future<String?> load() async => content;

  @override
  Future<void> save(String json) async => content = json;
}

/// One JSON file in the app's documents directory. Writes go to a temporary
/// file first and are renamed, so a crash mid-write keeps the old data.
class FileTrainingStore implements TrainingStore {
  FileTrainingStore(this._file);

  static Future<FileTrainingStore> create() async {
    final dir = await getApplicationDocumentsDirectory();
    return FileTrainingStore(File('${dir.path}/gymoire.json'));
  }

  final File _file;

  @override
  Future<String?> load() async => await _file.exists() ? _file.readAsString() : null;

  @override
  Future<void> save(String json) async {
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(json, flush: true);
    await tmp.rename(_file.path);
  }
}
