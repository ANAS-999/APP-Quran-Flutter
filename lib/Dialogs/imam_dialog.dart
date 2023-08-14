import 'dart:convert';
import 'package:quran/Data/imam_data.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../Data/riwaya_data.dart';
import '../Data/sora_data.dart';
import '../Pages/listen_page.dart';

class ImamDialog extends StatefulWidget {
  final SoraData sora;
  final RiwayaData rewaya;

  const ImamDialog({super.key, required this.sora, required this.rewaya});

  @override
  State<ImamDialog> createState() => _ImamDialogState();
}

class _ImamDialogState extends State<ImamDialog> {
  //! Variables
  bool isError = true;
  bool isSearch = false;
  bool isLoading = false;
  List<ImamData> listImam = [];
  List<ImamData> listTemp = [];
  final TextEditingController lineSearch = TextEditingController();

  @override
  void initState() {
    super.initState();

    getImam();
  }

  getImam() async {
    setState(() {
      isError = false;
      isLoading = true;
      listImam.clear();
      listTemp.clear();
    });
    try {
      final params = {'language': 'ar', 'rewaya': widget.rewaya.id.toString()};
      final uri = Uri.https('mp3quran.net', '/api/v3/reciters', params);
      final response = await http.get(uri);

      setState(() {
        isError = false;
        isLoading = false;
        listImam = (jsonDecode(response.body)['reciters'] as List)
            .map((e) => ImamData.fromJson(e))
            .toList();
        listTemp.addAll(listImam);

        listTemp.sort((a, b) => a.name.compareTo(b.name));
        listImam.sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
        listImam.clear();
      });
    }
  }

  onImam(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListenPage(
          sora: widget.sora,
          imam: listImam[index],
          rewaya: widget.rewaya,
        ),
      ),
    );
  }

  onSearch() {
    setState(() {
      isSearch = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: th.colorScheme.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          if (isLoading) {
            //! Loading
            return loadingWidget();
          } else if (isError && !isLoading) {
            //! Error
            return errorWidget('Failed to connect to servers');
          } else if (!isLoading && !isError) {
            return listItemWidget();
          }

          return errorWidget('Something was wrong. Try again');
        },
      ),
    );
  }

  Widget listItemWidget() {
    final th = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Flexible(
          child: Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/back.svg',
                  // ignore: deprecated_member_use
                  color: th.iconTheme.color,
                ),
                onPressed: () {
                  if (isSearch) {
                    setState(() {
                      isSearch = false;
                      listTemp.clear();
                      lineSearch.clear();
                      listTemp.addAll(listImam);
                    });
                  } else {
                    DialogNavigator.of(context).pop();
                  }
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    Visibility(
                      visible: !isSearch,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reciters',
                            style:
                                th.textTheme.titleLarge!.copyWith(fontSize: 20),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            child: IconButton(
                              onPressed: () {
                                onSearch();
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/search.svg',
                                // ignore: deprecated_member_use
                                color: th.iconTheme.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isSearch,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: th.cardColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TextField(
                          controller: lineSearch,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                listTemp.clear();
                              });

                              for (var i in listImam) {
                                if (i.name.contains(value)) {
                                  setState(() {
                                    listTemp.add(i);
                                  });
                                }
                              }
                            } else {
                              setState(() {
                                listTemp.addAll(listImam);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Stack(
            children: [
              Center(
                child: Visibility(
                  visible: listTemp.isEmpty,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 74,
                        width: 74,
                        child: SvgPicture.asset(
                          fit: BoxFit.fill,
                          'assets/icons/search.svg',
                          // ignore: deprecated_member_use
                          color: th.iconTheme.color,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Reciter not found'),
                    ],
                  ),
                ),
              ),
              ListView.separated(
                itemCount: listTemp.length,
                itemBuilder: (context, index) {
                  final item = listTemp[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: th.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onImam(index);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(item.name),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(
                                  'assets/icons/imam.svg',
                                  // ignore: deprecated_member_use
                                  color: th.iconTheme.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget loadingWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const CircularProgressIndicator(),
    );
  }

  Widget errorWidget(String text) {
    final th = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/back.svg',
                // ignore: deprecated_member_use
                color: th.iconTheme.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Back',
              style: th.textTheme.titleLarge!.copyWith(fontSize: 20),
            ),
          ],
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 70),
          child: SvgPicture.asset('assets/images/404.svg'),
        ),
        Text(text),
        const SizedBox(height: 20),
      ],
    );
  }
}
