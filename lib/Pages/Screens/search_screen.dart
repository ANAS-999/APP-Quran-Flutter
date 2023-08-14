import 'package:quran/Functions/func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Data/sora_data.dart';
import '../sora_page.dart';

class SearchScreen extends StatefulWidget {
  final int index;
  final BuildContext context;
  final List<SoraData> listSowar;

  const SearchScreen({
    super.key,
    required this.index,
    required this.context,
    required this.listSowar,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //! Variables
  final List<SoraData> listTemp = [];
  final TextEditingController searchController = TextEditingController();

  onSoraClick(int soraIndex) {
    final item = listTemp[soraIndex];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SoraPage(sora: item)),
    );
  }

  onSearch(String text) {
    setState(() {
      listTemp.clear();
    });

    for (var sora in widget.listSowar) {
      if (sora.nameAr.toLowerCase().contains(text.toLowerCase()) ||
          sora.nameEn.toLowerCase().contains(text.toLowerCase())) {
        setState(() {
          listTemp.add(sora);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      listTemp.addAll(widget.listSowar);
    });
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              //! Search line
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/back.svg',
                      colorFilter: ColorFilter.mode(
                        th.iconTheme.color!,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: th.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search...',
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (String text) {
                          onSearch(text);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),

              const SizedBox(height: 15),

              //! List Surah
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: listTemp.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return itemBookmarkWidget(index);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //! Widgets
  Widget itemBookmarkWidget(int index) {
    final th = Theme.of(context);
    final item = listTemp[index];

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
}
