import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeThemeDialog extends StatefulWidget {
  final ThemeMode mode;
  final ValueNotifier<ThemeMode> notifier;
  const HomeThemeDialog(
      {super.key, required this.mode, required this.notifier});

  @override
  State<HomeThemeDialog> createState() => _HomeThemeDialogState();
}

class _HomeThemeDialogState extends State<HomeThemeDialog> {
  int index = 3;

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  getThemeMode() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      index = pref.getInt('theme_mode') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () => DialogNavigator.of(context).pop(),
                    splashRadius: 20,
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Text(
                  'Back',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 2,
                  groupValue: index,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) async {
                    final pref = await SharedPreferences.getInstance();
                    setState(() {
                      index = value ?? 2;
                      widget.notifier.value = ThemeMode.dark;
                    });
                    pref.setInt('theme_mode', index);
                  },
                ),
                const Text('Dark'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: index,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) async {
                    final pref = await SharedPreferences.getInstance();
                    setState(() {
                      index = value ?? 1;
                      widget.notifier.value = ThemeMode.light;
                    });
                    pref.setInt('theme_mode', index);
                  },
                ),
                const Text('Light'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 0,
                  groupValue: index,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) async {
                    final pref = await SharedPreferences.getInstance();
                    setState(() {
                      index = value ?? 0;
                      widget.notifier.value = ThemeMode.system;
                    });
                    pref.setInt('theme_mode', index);
                  },
                ),
                const Text('System'),
              ],
            ),
            const Divider(thickness: 1),
            Container(
              alignment: Alignment.center,
              child: Text(
                'APP BY ANAS',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
