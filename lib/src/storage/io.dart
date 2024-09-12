import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:path_provider/path_provider.dart";
import "package:refreshed/refreshed.dart";
import "package:vaultify/src/value.dart";

/// A class implementing data storage functionality using local file system
/// storage and in-memory storage.
///
/// This class allows storing key-value pairs persistently in the local file
/// system and provides methods for CRUD operations on the stored data.
class VaultifyImpl {
  /// Constructs a `VaultifyImpl` instance with the provided [fileName] and
  /// optional [path].
  VaultifyImpl(this.fileName, [this.path]);

  /// The optional path for storing the file.
  final String? path;

  /// The name of the file to be used for storage.
  final String fileName;

  /// The in-memory storage for the data.
  final ValueStorage<Map<String, dynamic>> subject =
      ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  /// RandomAccessFile for file operations.
  RandomAccessFile? _randomAccessfile;

  /// Clears the in-memory storage.
  ///
  /// This method clears the in-memory storage and sets the subject's value to
  /// an empty map.
  Future<void> clear() async {
    subject
      ..value.clear()
      ..changeValue("", null);
  }

  /// Deletes the storage file and its backup file.
  ///
  /// This method deletes both the primary storage file and its backup file
  /// asynchronously.
  Future<void> deleteBox() async {
    final File box = await _fileDb(isBackup: false);
    final File backup = await _fileDb(isBackup: true);
    await Future.wait(
      <Future<FileSystemEntity>>[box.delete(), backup.delete()],
    );
  }

  /// Writes the current in-memory data to the storage file.
  ///
  /// This method encodes the in-memory data as JSON and writes it to the
  /// storage file.
  Future<void> flush() async {
    final Uint8List buffer = utf8.encode(json.encode(subject.value));
    final int length = buffer.length;
    final RandomAccessFile file = await _getRandomFile();

    _randomAccessfile = await file.lock();
    _randomAccessfile = await _randomAccessfile!.setPosition(0);
    _randomAccessfile = await _randomAccessfile!.writeFrom(buffer);
    _randomAccessfile = await _randomAccessfile!.truncate(length);
    _randomAccessfile = await file.unlock();
    _madeBackup();
  }

  /// Creates a backup of the current data.
  ///
  /// This method creates a backup of the current data by writing it to a
  /// separate backup file.
  void _madeBackup() {
    _getFile(true).then(
      (File value) async => await value.writeAsString(
        json.encode(subject.value),
        flush: true,
      ),
    );
  }

  /// Reads a value from the in-memory storage based on the given [key].
  T? read<T>(String key) => subject.value[key] as T?;

  /// Retrieves the keys of the in-memory storage.
  T getKeys<T>() => subject.value.keys as T;

  /// Retrieves the values of the in-memory storage.
  T getValues<T>() => subject.value.values as T;

  /// Initializes the storage.
  ///
  /// This method initializes the storage by loading the data from the file if
  /// it exists; otherwise, it initializes the storage with the provided
  /// [initialData].
  Future<void> init([Map<String, dynamic>? initialData]) async {
    subject.value = initialData ?? <String, dynamic>{};

    final RandomAccessFile file = await _getRandomFile();
    return file.lengthSync() == 0 ? flush() : _readFile();
  }

  /// Removes a value from the in-memory storage based on the given [key].
  void remove(String key) {
    subject
      ..value.remove(key)
      ..changeValue(key, null);
  }

  /// Writes a value to the in-memory storage with the given [key].
  void write(String key, value) {
    subject
      ..value[key] = value
      ..changeValue(key, value);
  }

  /// Reads the data from the storage file.
  Future<void> _readFile() async {
    try {
      RandomAccessFile file = await _getRandomFile();
      file = await file.setPosition(0);
      final Uint8List buffer = Uint8List(await file.length());
      await file.readInto(buffer);
      subject.value = json.decode(utf8.decode(buffer));
    } catch (e) {
      Get.log("Corrupted box, recovering backup file", isError: true);
      final File file = await _getFile(true);

      final String content = await file.readAsString()
        ..trim();

      if (content.isEmpty) {
        subject.value = <String, dynamic>{};
      } else {
        try {
          subject.value = (json.decode(content) as Map<String, dynamic>?) ??
              <String, dynamic>{};
        } catch (e) {
          Get.log("Can not recover Corrupted box", isError: true);
          subject.value = <String, dynamic>{};
        }
      }
      await flush();
    }
  }

  /// Gets a RandomAccessFile for file operations.
  Future<RandomAccessFile> _getRandomFile() async {
    if (_randomAccessfile != null) {
      return _randomAccessfile!;
    }
    final File fileDb = await _getFile(false);
    _randomAccessfile = await fileDb.open(mode: FileMode.append);

    return _randomAccessfile!;
  }

  /// Gets the file for storage operations.
  Future<File> _getFile(bool isBackup) async {
    final File fileDb = await _fileDb(isBackup: isBackup);
    if (!fileDb.existsSync()) {
      fileDb.createSync(recursive: true);
    }
    return fileDb;
  }

  /// Gets the file path for storage operations.
  Future<File> _fileDb({required bool isBackup}) async {
    final Directory dir = await _getImplicitDir();
    final String getPath = await _getPath(isBackup, path ?? dir.path);
    final File file = File(getPath);
    return file;
  }

  /// Gets the directory for storing the file.
  Future<Directory> _getImplicitDir() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (err) {
      rethrow;
    }
  }

  /// Gets the full file path based on the backup flag and the provided path.
  Future<String> _getPath(bool isBackup, String? path) async {
    final bool isWindows = GetPlatform.isWindows;
    final String separator = isWindows ? r"\" : "/";
    return isBackup
        ? "$path$separator$fileName.bak"
        : "$path$separator$fileName.vault";
  }
}
