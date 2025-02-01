import "dart:async";

import "package:flutter/widgets.dart";
import "package:refreshed/utils.dart";
import "package:vaultify/src/storage/html.dart"
    if (dart.library.io) "storage/io.dart";
import "package:vaultify/src/value.dart";

/// Vaultify provides access to a persistent storage container,
/// offering methods to read, write, and manage data.
class Vaultify {
  /// Creates a new Vaultify instance.
  ///
  /// The [container] parameter is the container name (defaults to 'Vaultify').
  /// [path] is an optional path for storage, and [initialData] is the optional initial data for the container.
  factory Vaultify([
    String container = "Vaultify",
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    if (_sync.containsKey(container)) {
      // Returns the existing instance if one already exists for the container.
      return _sync[container]!;
    } else {
      // Creates a new Vaultify instance and stores it for future use.
      final Vaultify instance =
          Vaultify._internal(container, path, initialData);
      _sync[container] = instance;
      return instance;
    }
  }

  /// Private constructor for Vaultify instance.
  Vaultify._internal(
    String key, [
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    _concrete = VaultifyImpl(key, path);
    _initialData = initialData;

    // Initializes the storage asynchronously.
    initStorage = Future<bool>(() async {
      await _init();
      return true;
    });
  }

  /// Map to store synchronized instances of Vaultify for different containers.
  static final Map<String, Vaultify> _sync = <String, Vaultify>{};

  /// Microtask instance used for deferred operations.
  final Microtask microtask = Microtask();

  /// Initializes the storage drive.
  ///
  /// The [container] parameter is the container name to be initialized.
  static Future<bool> init([String container = "Vaultify"]) {
    WidgetsFlutterBinding.ensureInitialized();
    return Vaultify(container).initStorage;
  }

  /// Initializes the instance, setting up the storage with initial data.
  Future<void> _init() async {
    try {
      await _concrete.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  /// Reads a value from the container with the given [key].
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  T? read<T>(String key) => _concrete.read(key);

  /// Retrieves all the keys stored in the container.
  T getKeys<T>() => _concrete.getKeys();

  /// Retrieves all the values stored in the container.
  T getValues<T>() => _concrete.getValues();

  /// Checks if data exists in the container for the given [key].
  ///
  /// Returns `true` if data exists, otherwise `false`.
  bool hasData(String key) => read(key) != null;

  /// Retrieves the changes made to the container.
  Map<String, dynamic> get changes => _concrete.subject.changes;

  /// Listens for any changes in the container's state.
  ///
  /// The [value] callback will be executed when changes are detected.
  VoidCallback listen(VoidCallback value) =>
      _concrete.subject.addListener(value);

  /// Map to store key-specific listeners.
  final Map<Function, Function> _keyListeners = <Function, Function>{};

  /// Listens for changes to a specific [key].
  ///
  /// The [callback] will be executed when changes are detected for that key.
  VoidCallback listenKey(String key, ValueSetter callback) {
    void listen() {
      if (changes.keys.first == key) {
        callback(changes[key]);
      }
    }

    _keyListeners[callback] = listen;
    return _concrete.subject.addListener(listen);
  }

  /// Writes data to the container for the specified [key].
  ///
  /// The value will be written in memory and the changes will be flushed asynchronously.
  Future<void> write(String key, value) async {
    writeInMemory(key, value);
    return _tryFlush();
  }

  /// Writes data to the container in memory without flushing immediately.
  void writeInMemory(String key, value) {
    _concrete.write(key, value);
  }

  /// Writes data to the container only if the data for the specified [key] is `null`.
  ///
  /// This method ensures that data is only written if the key does not already exist.
  Future<void> writeIfNull(String key, value) async {
    if (read(key) != null) {
      return;
    }
    return write(key, value);
  }

  /// Removes data from the container for the specified [key].
  ///
  /// The changes will be flushed asynchronously after removal.
  Future<void> remove(String key) async {
    _concrete.remove(key);
    return _tryFlush();
  }

  /// Clears all data from the container.
  ///
  /// This will remove all keys and values, and the changes will be flushed.
  Future<void> erase() async {
    _concrete.clear();
    return _tryFlush();
  }

  /// Saves the changes made to the container.
  Future<void> save() async => _tryFlush();

  /// Attempts to flush the changes to the container.
  Future<void> _tryFlush() async => microtask.exec(_addToQueue);

  /// Adds the flush operation to the queue, which will be executed later.
  Future<dynamic> _addToQueue() async => queue.add(_flush);

  /// Flushes the changes to the container, ensuring persistence.
  Future<void> _flush() async {
    try {
      await _concrete.flush();
    } catch (e) {
      rethrow;
    }
  }

  /// Instance of the concrete implementation for storage operations.
  late VaultifyImpl _concrete;

  /// Queue instance used for deferred tasks.
  GetQueue<dynamic> queue = GetQueue<dynamic>();

  /// Listenable instance for observing the container.
  ValueStorage<Map<String, dynamic>> get listenable => _concrete.subject;

  /// Initializes the storage drive asynchronously.
  ///
  /// Ensure that you use `await` before calling this method to avoid unexpected side effects.
  late Future<bool> initStorage;

  /// Initial data for the container, passed during initialization.
  Map<String, dynamic>? _initialData;
}

/// A class for managing microtasks and ensuring that a callback is executed
/// only once per microtask.
class Microtask {
  int _version = 0;
  int _microtask = 0;

  /// Executes the provided [callback] function.
  ///
  /// The [callback] function is executed only once per microtask.
  /// If multiple calls to [exec] are made within the same microtask,
  /// only the last call will trigger the [callback].
  void exec(Function callback) {
    if (_microtask == _version) {
      _microtask++;
      scheduleMicrotask(() {
        _version++;
        _microtask = _version;
        callback();
      });
    }
  }
}
