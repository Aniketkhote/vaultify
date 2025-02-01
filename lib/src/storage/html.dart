import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../value.dart';

/// A class for managing data storage using the HTML5 local storage mechanism.
///
/// This class provides a key-value store using the browser's localStorage to
/// persist data. It supports basic CRUD operations (create, read, update, delete)
/// and allows for both reading from and writing to localStorage, along with
/// keeping the data synchronized in memory.
class VaultifyImpl {
  /// Constructs a [VaultifyImpl] instance with the given [fileName] and optional [path].
  ///
  /// The [fileName] is used to store the data in localStorage. Optionally, a custom
  /// [path] can be provided, though this is unused in the web implementation.
  VaultifyImpl(this.fileName, [this.path]);

  /// Gets the local storage instance from the browser's window.
  html.Storage get localStorage => html.window.localStorage;

  /// The optional path for storing the file (currently unused for web).
  final String? path;

  /// The name of the file used for storing the data.
  final String fileName;

  /// The in-memory storage for the data, represented as a map of key-value pairs.
  ValueStorage<Map<String, dynamic>> subject =
      ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  /// Clears the stored data from both memory and local storage.
  ///
  /// This method removes the file from localStorage and clears the in-memory data.
  void clear() {
    localStorage.remove(fileName); // Removes from localStorage
    subject.value.clear(); // Clears in-memory data

    subject
      ..value.clear() // Ensure the data is cleared
      ..changeValue("", null); // Notify listeners of the cleared data
  }

  /// Checks if the data associated with [fileName] exists in localStorage.
  ///
  /// Returns a [Future<bool>] indicating whether the file exists.
  Future<bool> _exists() async {
    return localStorage.containsKey(fileName); // Check for file in localStorage
  }

  /// Flushes the in-memory data to local storage.
  ///
  /// This method encodes the current in-memory data as JSON and writes it to
  /// localStorage under the [fileName].
  Future<void> flush() async {
    return await _writeToStorage(
        subject.value); // Write in-memory data to localStorage
  }

  /// Reads a value associated with the given [key] from the in-memory storage.
  ///
  /// Returns the value associated with the [key] as a generic type [T].
  T? read<T>(String key) {
    return subject.value[key] as T?; // Return the value for the provided key
  }

  /// Retrieves all the keys from the in-memory storage.
  ///
  /// Returns the keys as a generic type [T].
  T getKeys<T>() {
    return subject.value.keys as T; // Return keys of in-memory data
  }

  /// Retrieves all the values from the in-memory storage.
  ///
  /// Returns the values as a generic type [T].
  T getValues<T>() {
    return subject.value.values as T; // Return values of in-memory data
  }

  /// Initializes the storage with the optional [initialData].
  ///
  /// If the file already exists in localStorage, it loads the data into memory.
  /// Otherwise, it writes the provided [initialData] (or an empty map) to localStorage.
  Future<void> init([Map<String, dynamic>? initialData]) async {
    subject.value = initialData ?? <String, dynamic>{}; // Initialize data

    if (await _exists()) {
      await _readFromStorage(); // Read data from localStorage
    } else {
      await _writeToStorage(
          subject.value); // Write initial data if file doesn't exist
    }
  }

  /// Removes a value associated with the given [key] from the storage.
  ///
  /// This method removes the key-value pair from both memory and localStorage.
  void remove(String key) {
    subject
      ..value.remove(key) // Remove from in-memory data
      ..changeValue(key, null); // Notify listeners of removal
  }

  /// Writes the given [value] associated with the [key] to both in-memory storage
  /// and localStorage.
  void write(String key, dynamic value) {
    subject
      ..value[key] = value // Update the in-memory data
      ..changeValue(key, value); // Notify listeners of the updated value
  }

  /// Writes the data to localStorage.
  ///
  /// This method encodes the [data] as a JSON string and writes it to localStorage
  /// under the [fileName].
  Future<void> _writeToStorage(Map<String, dynamic> data) async {
    localStorage.update(fileName, (val) => json.encode(subject.value),
        ifAbsent: () =>
            json.encode(subject.value)); // Update localStorage with data
  }

  /// Reads the data from localStorage and loads it into memory.
  ///
  /// If the data exists in localStorage, it is decoded from JSON and set to the
  /// in-memory storage. If no data is found, it writes an empty map to localStorage.
  Future<void> _readFromStorage() async {
    final dataFromLocal = _firstWhereOrNull(
      localStorage.entries,
      (value) => value.key == fileName, // Find the entry for the current file
    );

    if (dataFromLocal != null) {
      subject.value = json.decode(dataFromLocal.value)
          as Map<String, dynamic>; // Decode and load data
    } else {
      await _writeToStorage(
          <String, dynamic>{}); // Write empty map if no data found
    }
  }
}

/// A utility function that finds the first matching entry in an iterable, or null
/// if no match is found.
_firstWhereOrNull(Iterable entries, bool Function(dynamic element) test) {
  for (var element in entries) {
    if (test(element)) return element; // Return the matching element
  }
  return null; // Return null if no match is found
}
