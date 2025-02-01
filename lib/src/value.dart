import 'package:refreshed/state_manager.dart';

/// A storage class for tracking and managing values of type [T].
///
/// This class extends the [Value] class to offer functionality for storing values
/// and tracking changes. It accumulates changes over time, allowing the storage
/// to track and refresh the stored value when necessary.
///
/// The [ValueStorage] class is designed to track changes and automatically refresh
/// the value when an update is made.
class ValueStorage<T> extends Value<T> {
  /// Initializes a [ValueStorage] with an initial [value].
  ///
  /// This constructor accepts an initial value and passes it to the parent [Value] class.
  ValueStorage(super.value);

  /// A map to track changes made to stored values. The key represents the field,
  /// and the value represents the new value that has been changed.
  Map<String, dynamic> changes = <String, dynamic>{};

  /// Method to change the value associated with a given [key].
  ///
  /// This method updates the [changes] map with the new value for the specified [key],
  /// and triggers a refresh to ensure the stored value is up-to-date.
  ///
  /// The [key] is used to identify the specific value being modified, and [value]
  /// represents the new value to be stored.
  ///
  /// This method will accumulate changes in the [changes] map instead of overwriting it,
  /// ensuring that the latest value for each key is tracked.
  void changeValue(String key, T? value) {
    // Add or update the value for the specified key in the changes map.
    changes[key] = value;

    // Refresh the stored value to reflect the latest changes.
    refresh();
  }
}
