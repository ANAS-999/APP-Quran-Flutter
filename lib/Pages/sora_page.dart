import 'dart:convert';
import 'package:quran/Data/bookmark_data.dart';
import 'package:quran/Data/sora_data.dart';
import 'package:quran/Data/sora_quran_data.dart';
import 'package:quran/Local%20db/bookmark_database.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

import '../Dialogs/riwaya_dialog.dart';

class SoraPage extends StatefulWidget {
  final SoraData sora;
  const SoraPage({super.key, required this.sora});

  @override
  State<SoraPage> createState() => _SoraPageState();
}

class _SoraPageState extends State<SoraPage> {
  //! Variables
  bool isLoading = true;
  bool isBookmarked = false;
  List<SoraQuranData> listAyat = [];
  final refreshController = RefreshController(initialRefresh: false);

  //! Player Variables
  int i = 0;
  double seek = 0;
  double fontSize = 15;
  bool isError = false;
  late Source audioSource;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();

  getSoraData() async {
    audioPlayer.stop();
    setState(() {
      isLoading = true;
      listAyat.clear();
      isPlaying = false;
    });
    try {
      final id = widget.sora.id;
      final uri = Uri.https('api.alquran.cloud', '/v1/surah/$id/ar.alafasy');
      final response = await http.get(uri);

      setState(() {
        isLoading = false;
        listAyat = (jsonDecode(response.body)['data']['ayahs'] as List)
            .map((e) => SoraQuranData.fromJson(e))
            .toList();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        listAyat.clear();
      });
    }
  }

  onRefresh() async {
    getSoraData();
    refreshController.refreshCompleted();
  }

  initPlayer() {
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

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  onPlay(int index, SoraQuranData item) {
    setState(
      () {
        if (isPlaying && i == index) {
          isPlaying = false;
          audioPlayer.pause();
        } else {
          isPlaying = true;
          position = Duration.zero;
          audioSource = UrlSource(item.audio);
          audioPlayer.play(audioSource);
        }

        i = index;
      },
    );
  }

  onSound() {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => RiwayaDialog(sora: widget.sora),
        ),
      ),
    );
  }

  onBookmark() async {
    final db = BookmarkDatabase();
    final item = BookmarkData(
      soraId: widget.sora.id,
    );

    if (!isBookmarked) {
      db.insertData(item);
      checkBookmark();
    } else {
      db.deleteData(item);
      checkBookmark();
    }
  }

  checkBookmark() async {
    final db = BookmarkDatabase();
    var response = await db.readData();
    var listBookmarks = response.reversed.toList();

    for (BookmarkData i in listBookmarks) {
      if (i.soraId == widget.sora.id) {
        setState(() {
          isBookmarked = true;
        });
        return;
      }
      setState(() {
        isBookmarked = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    initPlayer();
    getSoraData();
    checkBookmark();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      //! AppBar
      appBar: appBarWidget(),

      //! Body
      body: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropMaterialHeader(),
        controller: refreshController,
        onRefresh: onRefresh,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                cardSoraWidget(),
                Stack(
                  children: [
                    //! Loading
                    loadingWidget(),

                    //! Error
                    errorWidget(),

                    //! List Surah
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ayat',
                                style: th.textTheme.titleLarge!
                                    .copyWith(fontSize: 25),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ListView.separated(
                              shrinkWrap: true,
                              itemCount: listAyat.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var item = listAyat[index];

                                return cardAyahWidget(index, item);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 30);
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBarWidget() {
    final th = Theme.of(context);

    return AppBar(
      scrolledUnderElevation: 0.0,
      title: Row(
        children: [
          Text(
            widget.sora.nameEn,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: SizedBox(
            width: 22,
            height: 22,
            child: SvgPicture.asset(
              'assets/icons/sound.svg',
              colorFilter:
                  ColorFilter.mode(th.iconTheme.color!, BlendMode.srcIn),
            ),
          ),
          onPressed: () {
            onSound();
          },
        ),
        IconButton(
          icon: SizedBox(
            width: 22,
            height: 22,
            child: Icon(
              isBookmarked
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              size: 22,
              color: isBookmarked ? th.primaryColor : th.iconTheme.color,
            ),
          ),
          onPressed: () {
            onBookmark();
          },
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

  Widget progressBarWidget(int index) {
    final th = Theme.of(context);

    return SizedBox(
      height: 35,
      child: Visibility(
        visible: isPlaying && i == index,
        child: SliderTheme(
          data: SliderThemeData(
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 0,
            ),
            activeTrackColor: th.primaryColor,
            inactiveTrackColor: th.textTheme.bodySmall!.color,
            overlayColor: const Color(0x46525252),
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
      ),
    );
  }

  Widget cardSoraWidget() {
    return Stack(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, .6, 1],
              colors: [Color(0xFFDF98FA), Color(0xFFB070FD), Color(0xFF9055FF)],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 10,
          child: Opacity(
            opacity: 0.2,
            child: SvgPicture.asset(
              'assets/icons/quran.svg',
              width: 324 - 55,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                widget.sora.nameEn,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'الشيخ مشاري العفاسي',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(thickness: 1, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.sora.place,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${widget.sora.ayat} Ayat",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SvgPicture.asset('assets/icons/bismillah.svg')
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SizedBox(
            width: 35,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/surah-star.svg',
                ),
                Text(
                  widget.sora.id.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget loadingWidget() {
    return Visibility(
      visible: isLoading,
      child: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 150),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget errorWidget() {
    return Visibility(
      visible: listAyat.isEmpty && !isLoading,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 150),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/404.svg',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Unable to connect to servers'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget cardAyahWidget(int index, SoraQuranData item) {
    final th = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 35,
          padding: const EdgeInsets.only(
            left: 10,
          ),
          decoration: BoxDecoration(
            color: th.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 25,
                    child: CircleAvatar(),
                  ),
                  Text(
                    item.ayah.toString(),
                    style: GoogleFonts.getFont('Rubik').copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              progressBarWidget(index),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onPlay(index, item);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isPlaying && index == i
                            ? Icons.pause_rounded
                            : Icons.play_arrow_outlined,
                        color: th.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.text,
              style: GoogleFonts.amiri(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}
