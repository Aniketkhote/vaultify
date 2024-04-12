import "package:refreshed/state_manager.dart";

/// Represents a storage class for storing values of type [T].
///
/// This class extends the [Value] class and adds functionality to track changes
/// made to the stored values.
class ValueStorage<T> extends Value<T> {
  /// Initializes a [ValueStorage] with an initial [value].
  ValueStorage(super.value);

  /// Map to track changes made to stored values.
  Map<String, dynamic> changes = <String, dynamic>{};

  /// Method to change the value associated with a given [key].
  ///
  /// This method updates the [changes] map with the new value for the specified key
  /// and triggers a refresh of the stored value.
  void changeValue(String key, value) {
    changes = <String, dynamic>{key: value};
    refresh();
  }
}
