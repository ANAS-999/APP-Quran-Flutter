import 'package:quran/Dialogs/theme_dialog.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';

class HomeDialog extends StatefulWidget {
  final ThemeMode mode;
  final ValueNotifier<ThemeMode> notifier;
  const HomeDialog({super.key, required this.mode, required this.notifier});

  @override
  State<HomeDialog> createState() => _HomeDialogState();
}

class _HomeDialogState extends State<HomeDialog> {
  void onThemeHomeDialog() {
    DialogNavigator.of(context).push(
      FluidDialogPage(
        builder: (context) => HomeThemeDialog(
          mode: widget.mode,
          notifier: widget.notifier,
        ),
      ),
    );
  }

  void onAboutHomeDialog() {
    DialogNavigator.of(context).close();
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
                    onPressed: () => DialogNavigator.of(context).close(),
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                  ),
                ),
                Text(
                  'Setting',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            ListTile(
              title: const Text('Themes'),
              leading: const Icon(Icons.brightness_4_outlined),
              iconColor: Theme.of(context).colorScheme.onSurface,
              onTap: () => onThemeHomeDialog(),
            ),
            const Divider(
              thickness: 1,
            ),
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
