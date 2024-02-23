import 'package:refreshed/state_manager.dart';

class ValueStorage<T> extends Value<T> {
  ValueStorage(super.value);

  Map<String, dynamic> changes = <String, dynamic>{};

  void changeValue(String key, dynamic value) {
    changes = {key: value};
    refresh();
  }
}
