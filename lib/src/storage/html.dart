import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../value.dart';

/// A class for managing data storage using local storage mechanisms,
/// such as HTML5 local storage.
class VaultifyImpl {
  /// Constructs a [VaultifyImpl] instance with the given [fileName] and optional [path].
  VaultifyImpl(this.fileName, [this.path]);

  /// Gets the local storage instance.
  html.Storage get localStorage => html.window.localStorage;

  /// The optional path for storing the file.
  final String? path;

  /// The name of the file.
  final String fileName;

  /// The storage subject holding the data.
  ValueStorage<Map<String, dynamic>> subject =
      ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  /// Clears the stored data.
  void clear() {
    localStorage.remove(fileName);
    subject.value.clear();

    subject
      ..value.clear()
      ..changeValue("", null);
  }

  /// Checks if the file exists in the storage.
  Future<bool> _exists() async {
    return localStorage.containsKey(fileName);
  }

  /// Flushes the data to storage.
  Future<void> flush() async {
    return await _writeToStorage(subject.value);
  }

  /// Reads a value associated with the given [key] from storage.
  T? read<T>(String key) {
    return subject.value[key] as T?;
  }

  /// Retrieves the keys from the stored data.
  T getKeys<T>() {
    return subject.value.keys as T;
  }

  /// Retrieves the values from the stored data.
  T getValues<T>() {
    return subject.value.values as T;
  }

  /// Initializes the storage with optional [initialData].
  Future<void> init([Map<String, dynamic>? initialData]) async {
    subject.value = initialData ?? <String, dynamic>{};
    if (await _exists()) {
      await _readFromStorage();
    } else {
      await _writeToStorage(subject.value);
    }
    return;
  }

  /// Removes the value associated with the given [key] from storage.
  void remove(String key) {
    subject
      ..value.remove(key)
      ..changeValue(key, null);
  }

  /// Writes the given [value] associated with the [key] to storage.
  void write(String key, dynamic value) {
    subject
      ..value[key] = value
      ..changeValue(key, value);
  }

  /// Writes the data to the storage.
  Future<void> _writeToStorage(Map<String, dynamic> data) async {
    localStorage.update(fileName, (val) => json.encode(subject.value),
        ifAbsent: () => json.encode(subject.value));
  }

  /// Reads the data from storage.
  Future<void> _readFromStorage() async {
    final dataFromLocal = _firstWhereOrNull(
      localStorage.entries,
      (value) {
        return value.key == fileName;
      },
    );
    if (dataFromLocal != null) {
      subject.value = json.decode(dataFromLocal.value) as Map<String, dynamic>;
    } else {
      await _writeToStorage(<String, dynamic>{});
    }
  }
}

_firstWhereOrNull(Iterable entries, bool Function(dynamic element) test) {
  for (var element in entries) {
    if (test(element)) return element;
  }
  return null;
}
