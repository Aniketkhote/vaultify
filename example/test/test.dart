import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/vaultify.dart';

void main() {
  const counter = 'counter';
  const isDarkMode = 'isDarkMode';
  Vaultify box = Vaultify();
  test('GetStorage read and write operation', () {
    box.write(counter, 0);
    expect(box.read(counter), 0);
  });

  test('save the state of brightness mode of app in GetStorage', () {
    box.write(isDarkMode, true);
    expect(box.read(isDarkMode), true);
  });
}
