import "dart:async";

import "package:flutter/widgets.dart";
import "package:refreshed/utils.dart";
import "package:vaultify/src/storage/html.dart"
    if (dart.library.io) "storage/io.dart";
import "package:vaultify/src/value.dart";

/// Instantiates Vaultify to access storage driver APIs.
class Vaultify {
  /// Creates a new Vaultify instance.
  ///
  /// [container] is the container name, defaults to 'Vaultify'.
  /// [path] is the optional path.
  /// [initialData] is the initial data to be used.
  factory Vaultify([
    String container = "Vaultify",
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    if (_sync.containsKey(container)) {
      return _sync[container]!;
    } else {
      final Vaultify instance =
          Vaultify._internal(container, path, initialData);
      _sync[container] = instance;
      return instance;
    }
  }

  /// Constructs a Vaultify instance.
  Vaultify._internal(
    String key, [
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    _concrete = VaultifyImpl(key, path);
    _initialData = initialData;

    initStorage = Future<bool>(() async {
      await _init();
      return true;
    });
  }

  /// Map to store synchronized instances of Vaultify.
  static final Map<String, Vaultify> _sync = <String, Vaultify>{};

  /// Microtask instance.
  final Microtask microtask = Microtask();

  /// Initializes the storage drive.
  ///
  /// [container] is the container name.
  static Future<bool> init([String container = "Vaultify"]) {
    WidgetsFlutterBinding.ensureInitialized();
    return Vaultify(container).initStorage;
  }

  /// Initializes the Vaultify instance.
  Future<void> _init() async {
    try {
      await _concrete.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  /// Reads a value from the container with the given [key].
  T? read<T>(String key) => _concrete.read(key);

  /// Retrieves the keys from the container.
  T getKeys<T>() => _concrete.getKeys();

  /// Retrieves the values from the container.
  T getValues<T>() => _concrete.getValues();

  /// Checks if data exists in the container for the given [key].
  ///
  /// Returns true if data exists, otherwise false.
  bool hasData(String key) => (read(key) == null ? false : true);

  /// Gets the changes made to the container.
  Map<String, dynamic> get changes => _concrete.subject.changes;

  /// Listens for changes in the container.
  VoidCallback listen(VoidCallback value) =>
      _concrete.subject.addListener(value);

  /// Map to store key listeners.
  final Map<Function, Function> _keyListeners = <Function, Function>{};

  /// Listens for changes to a specific [key].
  VoidCallback listenKey(String key, ValueSetter callback) {
    void listen() {
      if (changes.keys.first == key) {
        callback(changes[key]);
      }
    }

    _keyListeners[callback] = listen;
    return _concrete.subject.addListener(listen);
  }

  /// Writes data to the container with the specified [key].
  Future<void> write(String key, value) async {
    writeInMemory(key, value);
    return _tryFlush();
  }

  /// Writes data to the container in memory.
  void writeInMemory(String key, value) {
    _concrete.write(key, value);
  }

  /// Writes data to the container only if the data is null.
  Future<void> writeIfNull(String key, value) async {
    if (read(key) != null) {
      return;
    }
    return write(key, value);
  }

  /// Removes data from the container with the specified [key].
  Future<void> remove(String key) async {
    _concrete.remove(key);
    return _tryFlush();
  }

  /// Clears all data from the container.
  Future<void> erase() async {
    _concrete.clear();
    return _tryFlush();
  }

  /// Saves the changes made to the container.
  Future<void> save() async => _tryFlush();

  /// Tries to flush the changes to the container.
  Future<void> _tryFlush() async => microtask.exec(_addToQueue);

  /// Adds the flush operation to the queue.
  Future<dynamic> _addToQueue() async => queue.add(_flush);

  /// Flushes the changes to the container.
  Future<void> _flush() async {
    try {
      await _concrete.flush();
    } catch (e) {
      rethrow;
    }
    return;
  }

  /// Instance of VaultifyImpl.
  late VaultifyImpl _concrete;

  /// GetQueue instance.
  GetQueue<dynamic> queue = GetQueue<dynamic>();

  /// Listenable of the container.
  ValueStorage<Map<String, dynamic>> get listenable => _concrete.subject;

  /// Initializes the storage drive.
  ///
  /// Important: use await before calling this API, or side effects will occur.
  late Future<bool> initStorage;

  /// Initial data for the container.
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
