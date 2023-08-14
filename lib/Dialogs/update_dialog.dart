import 'package:firebase_database/firebase_database.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatefulWidget {
  final String version;
  final String appName;
  const UpdateDialog({super.key, required this.appName, required this.version});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool isLoading = true;
  bool isUpdated = false;
  String newVersion = '';

  @override
  void initState() {
    super.initState();

    checkUpdate();
  }

  checkUpdate() async {
    setState(() {
      isLoading = true;
    });

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('${widget.appName}/version').get();

    if (snapshot.exists) {
      String v = snapshot.value.toString();

      setState(() {
        newVersion = v;
        isLoading = false;
        isUpdated = v == widget.version;
      });
    } else {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "The application is not connected to our servers!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: null,
      builder: (context, snapshot) {
        if (isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const CircularProgressIndicator(),
          );
        } else if (!isUpdated) {
          return Container(
            width: 300,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.refresh),
                    const SizedBox(width: 10),
                    Text(
                      'UPDATE',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'There is a new version now $newVersion',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'your version ${widget.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  'If the new version does not work, uninstall the old version and try again',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final ref = FirebaseDatabase.instance.ref();
                      final link =
                          await ref.child('${widget.appName}/link').get();
                      final url =
                          !link.value.toString().startsWith("http://") &&
                                  !link.value.toString().startsWith("https://")
                              ? "http://${link.value}"
                              : link.value.toString();

                      if (link.exists) {
                        if (!await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication)) {
                          if (!mounted) return;
                          DialogNavigator.of(context).close();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Text("Something is wrong. Try again later"),
                          ));
                        }
                      } else {
                        if (!mounted) return;
                        DialogNavigator.of(context).close();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Something is wrong. Try again later"),
                        ));
                      }
                    } catch (e) {
                      DialogNavigator.of(context).close();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Something is wrong. Try again later"),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 12.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      textStyle: const TextStyle(color: Colors.white)),
                  child: const Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      //color: Theme.of(context).textTheme.titleLarge!.color!,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 5,
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/back.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Close'),
                ],
              ),
              SizedBox(
                height: 154,
                child: SvgPicture.asset('assets/images/update.svg'),
              ),
              const SizedBox(height: 20),
              Text('You have The Last Version ${widget.version}'),
            ],
          ),
        );
      },
    );
  }
}
