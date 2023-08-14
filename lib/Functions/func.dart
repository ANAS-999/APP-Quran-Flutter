import 'package:quran/Dialogs/setting_dialog.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dialogs/about_dialog.dart';
import '../Dialogs/update_dialog.dart';

void onShowDialogHome(
  BuildContext context,
  ThemeMode mode,
  ValueNotifier<ThemeMode> notifier,
) {
  showDialog(
    context: context,
    builder: (context) => FluidDialog(
      rootPage: FluidDialogPage(
        alignment: Alignment.center,
        builder: (context) => HomeDialog(mode: mode, notifier: notifier),
      ),
    ),
  );
}

String getDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

void onShowDialogAbout(String appName, String version, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => FluidDialog(
      rootPage: FluidDialogPage(
        alignment: Alignment.center,
        builder: (context) =>
            AboutDialogHome(appName: appName, version: version),
      ),
    ),
  );
}

void onShowDialogUpdate(String appName, String version, BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => FluidDialog(
      rootPage: FluidDialogPage(
        alignment: Alignment.center,
        builder: (context) => UpdateDialog(appName: appName, version: version),
      ),
    ),
  );
}

void getThemeMode(ValueNotifier<ThemeMode> notifier) async {
  final pref = await SharedPreferences.getInstance();
  int prefMode = pref.getInt('theme_mode') ?? 0;

  if (kDebugMode) print(prefMode);

  switch (prefMode) {
    case 0:
      notifier.value = ThemeMode.system;
      break;
    case 1:
      notifier.value = ThemeMode.light;
      break;
    case 2:
      notifier.value = ThemeMode.dark;
      break;
  }
}
