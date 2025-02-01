import "package:vaultify/vaultify.dart";

/// A factory function type that produces instances of [Vaultify].
typedef StorageFactory = Vaultify Function();

/// Represents a read-write value with an associated key and default value.
///
/// This class provides convenient access to read and write values from a storage container.
class ReadWriteValue<T> {
  /// Constructs a [ReadWriteValue] instance with the given [key], [defaultValue],
  /// and an optional [getBox] factory function.
  ///
  /// [key] The key associated with the value.
  /// [defaultValue] The default value if the value is not found in storage.
  /// [getBox] The optional factory function to obtain the storage container.
  ReadWriteValue(
    this.key,
    this.defaultValue, [
    this.getBox,
  ]);

  /// The key associated with the value.
  final String key;

  /// The default value.
  final T defaultValue;

  /// The factory function to obtain the storage container.
  final StorageFactory? getBox;

  /// Retrieves the current value associated with the [key].
  ///
  /// If the value is not found, it returns the [defaultValue].
  T get val => _getRealBox().read(key) ?? defaultValue;

  /// Sets the value associated with the [key] to [newVal].
  set val(T newVal) => _getRealBox().write(key, newVal);

  /// Returns the storage container associated with this value.
  ///
  /// If no [getBox] is provided, it defaults to a new [Vaultify] instance.
  Vaultify _getRealBox() => getBox?.call() ?? Vaultify();
}

/// Extension methods for providing syntactic sugar to create [ReadWriteValue] instances.
extension Data<T> on T {
  /// Creates a [ReadWriteValue] instance for the current value.
  ///
  /// The [valueKey] parameter specifies the key associated with the value.
  /// The optional [getBox] parameter specifies the factory function to obtain the storage container.
  /// The optional [defVal] parameter specifies the default value.
  ///
  /// Returns a new [ReadWriteValue] instance.
  ReadWriteValue<T> val(
    String valueKey, {
    StorageFactory? getBox,
    T? defVal,
  }) =>
      ReadWriteValue(valueKey, defVal ?? this, getBox);
}
