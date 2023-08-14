import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';

class AboutDialogHome extends StatefulWidget {
  final String appName;
  final String version;

  const AboutDialogHome({
    super.key,
    required this.appName,
    required this.version,
  });

  @override
  State<AboutDialogHome> createState() => _AboutDialogHome();
}

class _AboutDialogHome extends State<AboutDialogHome> {
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
            //! Title
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
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            //! Image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 65,
                  alignment: Alignment.center,
                  child: Image.asset('assets/icons/logo.png'),
                ),
              ],
            ),
            const SizedBox(height: 5),
            //! App Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.appName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            //! Version
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'version : ${widget.version}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            //! By
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
