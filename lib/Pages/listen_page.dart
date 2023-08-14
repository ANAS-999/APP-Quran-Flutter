import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:quran/Data/imam_data.dart';
import 'package:quran/Data/riwaya_data.dart';
import 'package:quran/Data/sora_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Functions/func.dart';

class ListenPage extends StatefulWidget {
  final SoraData sora;
  final ImamData imam;
  final RiwayaData rewaya;
  const ListenPage(
      {super.key,
      required this.sora,
      required this.imam,
      required this.rewaya});

  @override
  State<ListenPage> createState() => _ListenPage();
}

class _ListenPage extends State<ListenPage> {
  int i = 0;
  int random = 1;
  double seek = 0;
  double fontSize = 15;
  late Source audioSource;
  bool isPlaying = false;
  bool isFinish = true;
  bool isRepeat = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();

  check() {
    var server = widget.imam.moshaf[0]['server'] as String;
    if (widget.sora.id < 10) {
      play('${server}00${widget.sora.id}.mp3');
    } else if (widget.sora.id < 100) {
      play('${server}0${widget.sora.id}.mp3');
    } else {
      play('$server${widget.sora.id}.mp3');
    }
  }

  play(String url) {
    isPlaying = true;
    audioSource = UrlSource(url);
    audioPlayer.play(audioSource);
  }

  onBack() {
    Navigator.pop(context);
  }

  onInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "سورة ${widget.sora.nameAr}",
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          "تلاوة سورة ${widget.sora.nameAr} للشيخ ${widget.imam.name} برواية ${widget.rewaya.name}",
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text(
              "Close",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        position = Duration.zero;
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) async {
      setState(() {
        isFinish = true;
        isPlaying = false;
        position = Duration.zero;
      });
      if (isRepeat) {
        check();
      }
    });

    setState(() {
      random = Random().nextInt(5) + 1;
    });

    check();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    audioPlayer.stop();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      //! AppBar
      appBar: appBarWidget(),

      //! Body
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: th.colorScheme.background,
          ),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 50,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child:
                                Image.asset('assets/images/quran_$random.jpg'),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 15),
                          child: Text(
                            widget.imam.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'برواية ${widget.rewaya.name}',
                          textAlign: TextAlign.center,
                          style: th.textTheme.bodySmall!.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        thumbColor: th.primaryColor,
                        activeTrackColor: th.primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        overlayColor: const Color(0x46525252),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (val) async {
                          final position = Duration(seconds: val.toInt());
                          await audioPlayer.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    getDuration(position),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      getDuration(duration),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Material(
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        position = Duration.zero;
                                      });
                                      await audioPlayer.seek(position);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: SvgPicture.asset(
                                        'assets/icons/reply.svg',
                                        colorFilter: ColorFilter.mode(
                                          th.iconTheme.color!,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final p = Duration(
                                          seconds: position.inSeconds - 10);
                                      await audioPlayer.seek(p);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: SvgPicture.asset(
                                        'assets/icons/replay_10.svg',
                                        colorFilter: ColorFilter.mode(
                                          th.iconTheme.color!,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (() => setState(
                                          () {
                                            if (isPlaying) {
                                              isPlaying = false;
                                              audioPlayer.pause();
                                            } else {
                                              isPlaying = true;
                                              if (isFinish) {
                                                check();
                                              } else {
                                                audioPlayer.resume();
                                              }
                                            }
                                          },
                                        )),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 37,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final p = Duration(
                                          seconds: position.inSeconds + 10);
                                      await audioPlayer.seek(p);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: SvgPicture.asset(
                                        'assets/icons/forward_10.svg',
                                        colorFilter: ColorFilter.mode(
                                          th.iconTheme.color!,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => setState(() {
                                      isRepeat = !isRepeat;
                                    }),
                                    borderRadius: BorderRadius.circular(20),
                                    child: isRepeat
                                        ? SvgPicture.asset(
                                            'assets/icons/repeat.svg',
                                            colorFilter: ColorFilter.mode(
                                              th.iconTheme.color!,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            'assets/icons/no_repeat.svg',
                                            colorFilter: ColorFilter.mode(
                                              th.iconTheme.color!,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBarWidget() {
    final th = Theme.of(context);

    return AppBar(
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      title: Text(
        widget.sora.nameAr,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/info.svg',
            colorFilter: ColorFilter.mode(
              th.iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => onInfo(),
        ),
      ],
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/back.svg',
          colorFilter: ColorFilter.mode(
            th.iconTheme.color!,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
