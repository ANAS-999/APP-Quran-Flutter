import 'package:quran/Data/bookmark_data.dart';
import 'package:quran/Data/sora_data.dart';
import 'package:quran/Functions/func.dart';
import 'package:quran/Local%20db/bookmark_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../sora_page.dart';

class BookmarkScreen extends StatefulWidget {
  final BuildContext context;
  final List<SoraData> listSowar;
  const BookmarkScreen(
      {super.key, required this.listSowar, required this.context});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  //! Variables
  bool isError = false;
  bool isLoading = false;
  List<BookmarkData> listBookmark = [];
  final refreshController = RefreshController(initialRefresh: false);

  getBookmark() async {
    setState(() {
      isError = false;
      isLoading = true;
      listBookmark.clear();
    });

    try {
      final db = BookmarkDatabase();
      final response = await db.readData();

      for (var i in response) {
        if (!listBookmark.contains(i)) {
          setState(() {
            listBookmark.add(i);
            listBookmark.sort((a, b) => a.soraId.compareTo(b.soraId));
          });
        }
      }
      setState(() {
        isError = false;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  onRefresh() async {
    getBookmark();
    refreshController.refreshCompleted();
  }

  onSoraClick(SoraData item) {
    Navigator.push(
      widget.context,
      MaterialPageRoute(builder: (context) => SoraPage(sora: item)),
    );
  }

  @override
  void initState() {
    super.initState();

    getBookmark();
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

          //! Empty
          emptyLoading(),

          //! Error
          errorWidget(),

          //! List Surah
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bookmark',
                      style: th.textTheme.titleLarge!.copyWith(fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: listBookmark.length,
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
    final book = listBookmark[index];
    final item = widget.listSowar.firstWhere((x) => x.id == book.soraId);

    return Container(
      decoration: BoxDecoration(
        color: th.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onSoraClick(item);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                /* SizedBox(
                  width: 35,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/surah-star.svg',
                      ),
                      Text(item.id.toString()),
                    ],
                  ),
                ), */
                SizedBox(
                  width: 35,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.bookmark_fill,
                        color: th.primaryColor,
                        size: 34,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text((index + 1).toString()),
                      ),
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
      visible: isError && !isLoading,
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
      visible: isLoading && !isError,
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

  Widget emptyLoading() {
    return Visibility(
      visible: !isLoading && !isError && listBookmark.isEmpty,
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
                        'assets/images/bookmark.svg',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Empty Bookmark'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
