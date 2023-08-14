import 'dart:convert';
import 'package:quran/Pages/Screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/Data/sora_data.dart';
import 'package:quran/Functions/func.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'Screens/bookmark_screen.dart';
import 'Screens/sound_screen.dart';
import 'sora_page.dart';

class HomePage extends StatefulWidget {
  final ThemeMode mode;
  final String appName;
  final String version;
  final ValueNotifier<ThemeMode> notifier;

  const HomePage({
    super.key,
    required this.mode,
    required this.appName,
    required this.version,
    required this.notifier,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //! Variables
  bool isLoading = false;
  List<SoraData> listSowar = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final navController = PersistentTabController(initialIndex: 0);
  final refreshController = RefreshController(initialRefresh: false);

  getSuwar() async {
    setState(() {
      isLoading = true;
      listSowar.clear();
    });
    try {
      final params = {'language': 'en'};
      final uri = Uri.https('api.quran.com', '/api/v4/chapters', params);
      final response = await http.get(uri);

      setState(() {
        isLoading = false;
        listSowar = (jsonDecode(response.body)['chapters'] as List)
            .map((e) => SoraData.fromJson(e))
            .toList();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        listSowar.clear();
      });
    }
  }

  onRefresh() async {
    getSuwar();
    refreshController.refreshCompleted();
  }

  onSoraClick(SoraData item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SoraPage(sora: item)),
    );
  }

  onSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          context: context,
          listSowar: listSowar,
          index: navController.index,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    getSuwar();
  }

  //! Content
  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,

      //! AppBar
      appBar: appBarWidget(),

      //! Drawer
      drawer: navDrawerWidget(),

      //! Body
      body: SafeArea(
        child: PersistentTabView(
          context,
          controller: navController,
          screens: [
            sowarScreen(),
            soundScreen(),
            bookmarkScreen(),
          ],
          items: [
            PersistentBottomNavBarItem(
              icon: const Icon(CupertinoIcons.book_fill),
              title: ("Sowar"),
              activeColorPrimary: th.primaryColor,
              inactiveColorPrimary: th.iconTheme.color!.withOpacity(0.5),
            ),
            PersistentBottomNavBarItem(
              icon: const Icon(CupertinoIcons.volume_up),
              title: ("Sound"),
              activeColorPrimary: th.primaryColor,
              inactiveColorPrimary: th.iconTheme.color!.withOpacity(0.5),
            ),
            PersistentBottomNavBarItem(
              icon: const Icon(CupertinoIcons.bookmark),
              title: ("Bookmark"),
              activeColorPrimary: th.primaryColor,
              inactiveColorPrimary: th.iconTheme.color!.withOpacity(0.5),
            ),
          ],
          backgroundColor: th.cardColor.withOpacity(0.5),
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: th.cardColor.withOpacity(0.5),
          ),
          itemAnimationProperties: const ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          hideNavigationBarWhenKeyboardShows: true,
          popActionScreens: PopActionScreensType.once,
          stateManagement: false,
          onItemSelected: (value) {
            setState(() {
              navController;
            });
          },
          navBarStyle: NavBarStyle.style6,
        ),
      ),
    );
  }

  //! Screens
  Widget sowarScreen() {
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

          //! List Surah
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Suwar',
                      style: th.textTheme.titleLarge!.copyWith(fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: listSowar.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return itemSoraWidget(index);
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

  Widget soundScreen() {
    return SoundScreen(context: context, listSowar: listSowar);
  }

  Widget bookmarkScreen() {
    return BookmarkScreen(listSowar: listSowar, context: context);
  }

  //! Widgets
  PreferredSizeWidget appBarWidget() {
    final th = Theme.of(context);

    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      bottomOpacity: 0.0,
      title: Row(
        children: [
          Text(
            widget.appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Visibility(
            visible: navController.index == 0,
            child: IconButton(
              onPressed: () {
                onSearch();
              },
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                colorFilter: ColorFilter.mode(
                  th.iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          )
        ],
      ),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/menu.svg',
          colorFilter: ColorFilter.mode(
            th.iconTheme.color!,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget navDrawerWidget() {
    final th = Theme.of(context);
    final bodySmall = th.textTheme.bodySmall;
    final backColor = th.colorScheme.background;
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 45),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFDF98FA),
                    Color(0xFFB070FD),
                    Color(0xFF9055FF),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset('assets/icons/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.appName,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Version ${widget.version}',
                    style: bodySmall!.copyWith(
                      color: const Color(0xC1FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text('Option', style: bodySmall),
                  const SizedBox(width: 5),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
            ListTile(
              title: const Text('Setting'),
              leading: const Icon(CupertinoIcons.settings),
              onTap: () {
                Navigator.pop(context);
                onShowDialogHome(
                  context,
                  widget.mode,
                  widget.notifier,
                );
              },
            ),
            ListTile(
              title: const Text('About Us'),
              leading: const Icon(CupertinoIcons.info),
              onTap: () {
                Navigator.pop(context);
                onShowDialogAbout(widget.appName, widget.version, context);
              },
            ),
            ListTile(
              title: const Text('Check Update'),
              leading: const Icon(CupertinoIcons.upload_circle),
              onTap: () {
                Navigator.pop(context);
                onShowDialogUpdate(widget.appName, widget.version, context);
              },
            ),
          ],
        ),
      ),
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
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemSoraWidget(int index) {
    final th = Theme.of(context);
    var item = listSowar[index];

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
                SizedBox(
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
      visible: listSowar.isEmpty && !isLoading,
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
}
