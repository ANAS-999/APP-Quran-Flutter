import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:quran/Themes/theme.dart';
import 'package:quran/Pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quran/Functions/func.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String version = '1.1.0';
  final String appName = 'Quran';
  final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.light);

  @override
  void initState() {
    getVersion();
    getThemeMode(notifier);

    super.initState();
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String v = packageInfo.version.toString();

    setState(() {
      version = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: notifier,
      builder: (_, mode, __) {
        return MaterialApp(
          themeMode: mode,
          theme: lightTheme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          home: HomePage(
            mode: mode,
            appName: appName,
            version: version,
            notifier: notifier,
          ),
        );
      },
    );
  }
}
