import 'dart:convert';
import 'package:quran/Data/imam_data.dart';
import 'package:quran/Data/sora_data.dart';
import 'package:quran/Functions/func.dart';
import 'package:quran/Pages/listen_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Data/riwaya_data.dart';
import '../widgets/drop_down_widget.dart';

class SoundScreen extends StatefulWidget {
  final BuildContext context;
  final List<SoraData> listSowar;

  const SoundScreen({
    super.key,
    required this.context,
    required this.listSowar,
  });

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  //! Variables
  bool isLoadingImam = false;
  bool isLoadingRiwaya = false;
  List<ImamData> listImam = [];
  List<RiwayaData> listRewaya = [];

  static late ValueNotifier<ImamData> valueNotifierImam;
  late ValueNotifier<RiwayaData> valueNotifierRiwaya;
  final fullNameTextEditingController = TextEditingController();
  final refreshController = RefreshController(initialRefresh: false);

  getRewaya() async {
    setState(() {
      isLoadingRiwaya = true;
      listRewaya.clear();
      listImam.clear();
    });
    try {
      final params = {'language': 'ar'};
      final uri = Uri.https('mp3quran.net', '/api/v3/riwayat', params);
      final response = await http.get(uri);

      setState(() {
        isLoadingRiwaya = false;
        listRewaya = (jsonDecode(response.body)['riwayat'] as List)
            .map((e) => RiwayaData.fromJson(e))
            .toList();
        listRewaya.sort((a, b) => a.name.compareTo(b.name));

        try {
          valueNotifierRiwaya = ValueNotifier(listRewaya[0]);
          if (listRewaya.length >= 7) {
            valueNotifierRiwaya.value = listRewaya[17];
          } else {
            valueNotifierRiwaya.value = listRewaya[0];
          }
        } catch (e) {
          valueNotifierRiwaya = ValueNotifier(RiwayaData.empty());
          valueNotifierRiwaya.value = RiwayaData.empty();
        }
      });

      getImam(valueNotifierRiwaya.value.id);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingRiwaya = false;
        listRewaya.clear();
      });
    }
  }

  getImam(int rewayaId) async {
    setState(() {
      isLoadingImam = true;
      listImam.clear();
    });
    try {
      final params = {'language': 'ar', 'rewaya': rewayaId.toString()};
      final uri = Uri.https('mp3quran.net', '/api/v3/reciters', params);
      final response = await http.get(uri);

      setState(() {
        isLoadingImam = false;
        listImam = (jsonDecode(response.body)['reciters'] as List)
            .map((e) => ImamData.fromJson(e))
            .toList();
        listImam.sort((a, b) => a.name.compareTo(b.name));

        try {
          valueNotifierImam = ValueNotifier(listImam[0]);
          valueNotifierImam.value = listImam[0];
        } catch (e) {
          valueNotifierImam = ValueNotifier(ImamData.empty());
          valueNotifierImam.value = ImamData.empty();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingImam = false;
        listImam.clear();
      });
    }
  }

  onRefresh() async {
    getRewaya();
    getImam(valueNotifierRiwaya.value.id);

    refreshController.refreshCompleted();
  }

  onSoraClick(int index) {
    final sora = widget.listSowar[index];
    final imam = valueNotifierImam.value;
    final riwaya = valueNotifierRiwaya.value;

    Navigator.push(
      widget.context,
      MaterialPageRoute(
        builder: (context) => ListenPage(
          sora: sora,
          imam: imam,
          rewaya: riwaya,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    getRewaya();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return /* SmartRefresher(
      enablePullDown: true,
      header: const WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: onRefresh,
      child: */
        SafeArea(
      child: Stack(
        children: [
          //! Loading
          loadingWidget(),

          //! Error
          errorWidget(),

          //! Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  //! Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sound',
                      style: th.textTheme.titleLarge!.copyWith(fontSize: 25),
                    ),
                  ),

                  const SizedBox(height: 15),

                  //! Drop Down Menu Riwaya
                  FutureBuilder(
                    future: null,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (!isLoadingRiwaya) {
                        return DropdownRiwayaWidget<RiwayaData>(
                          valueNotifier: valueNotifierRiwaya,
                          showSearchTextField: true,
                          maxHeight: 300,
                          itemWidgetBuilder: (int index, RiwayaData item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  color: th.textTheme.titleLarge!.color,
                                ),
                              ),
                            );
                          },
                          children: listRewaya,
                          onChanged: (RiwayaData value) {
                            valueNotifierRiwaya.value = value;
                          },
                        );
                      }

                      return loadingItemsWidget('Riwaya');
                    },
                  ),

                  const SizedBox(height: 5),

                  //! Drop Down Menu Imam
                  FutureBuilder(
                    future: null,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (!isLoadingImam && !isLoadingRiwaya) {
                        return DropdownImamWidget<ImamData>(
                          valueNotifier: valueNotifierImam,
                          showSearchTextField: true,
                          maxHeight: 300,
                          itemWidgetBuilder: (int index, ImamData item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  color: th.textTheme.titleLarge!.color,
                                ),
                              ),
                            );
                          },
                          children: listImam,
                          onChanged: (ImamData value) {
                            valueNotifierImam.value = value;
                          },
                        );
                      }

                      return loadingItemsWidget('Imam');
                    },
                  ),

                  const SizedBox(height: 15),

                  //! List Surah
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.listSowar.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return itemBookmarkWidget(index);
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      //),
    );
  }

  //! Widgets
  Widget itemBookmarkWidget(int index) {
    final th = Theme.of(context);
    var item = widget.listSowar[index];

    return Container(
      decoration: BoxDecoration(
        color: th.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onSoraClick(index);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 35,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /* SvgPicture.asset(
                        'assets/icons/surah-star.svg',
                      ), */
                      Icon(
                        CupertinoIcons.volume_up,
                        color: th.primaryColor,
                        size: 32,
                      ),
                      //Text(item.id.toString()),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.nameEn),
                          Text(
                            '${item.place.capitalize()} - ${item.ayat} Ayah',
                            style: th.textTheme.bodySmall,
                          )
                        ],
                      ),
                      Text(
                        item.nameAr,
                        style: GoogleFonts.getFont('Amiri').copyWith(
                          color: th.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget errorWidget() {
    return Visibility(
      visible: widget.listSowar.isEmpty && !isLoadingImam && !isLoadingRiwaya,
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

  Widget loadingWidget() {
    return Visibility(
      visible: widget.listSowar.isEmpty && isLoadingImam && isLoadingRiwaya,
      child: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingItemsWidget(String text) {
    final th = Theme.of(context);

    return Container(
      key: GlobalKey(),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: th.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}
