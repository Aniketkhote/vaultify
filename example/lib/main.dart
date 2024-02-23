import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';
import 'package:vaultify/vaultify.dart';

void main() async {
  await Vaultify.init();
  runApp(App());
}

class Controller extends GetxController {
  final box = Vaultify();
  bool get isDark => box.read('darkmode') ?? false;
  ThemeData get theme => isDark ? ThemeData.dark() : ThemeData.light();
  void changeTheme(bool val) => box.write('darkmode', val);
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Controller());
    return Observer(builder: (_) {
      return MaterialApp(
        theme: controller.theme,
        home: Scaffold(
          appBar: AppBar(title: Text("Get Storage")),
          body: Center(
            child: SwitchListTile(
              value: controller.isDark,
              title: Text("Touch to change ThemeMode"),
              onChanged: controller.changeTheme,
            ),
          ),
        ),
      );
    });
  }
}
