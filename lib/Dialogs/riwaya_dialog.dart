import 'dart:convert';
import 'package:quran/Data/riwaya_data.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../Data/sora_data.dart';
import 'imam_dialog.dart';

class RiwayaDialog extends StatefulWidget {
  final SoraData sora;
  const RiwayaDialog({super.key, required this.sora});

  @override
  State<RiwayaDialog> createState() => _RiwayaDialogState();
}

class _RiwayaDialogState extends State<RiwayaDialog> {
  //! Variables
  bool isError = true;
  bool isLoading = false;
  List<RiwayaData> listRiwayat = [];

  @override
  void initState() {
    super.initState();

    getRiwayat();
  }

  getRiwayat() async {
    setState(() {
      isError = false;
      isLoading = true;
      listRiwayat.clear();
    });
    try {
      final params = {'language': 'ar'};
      final uri = Uri.https('mp3quran.net', '/api/v3/riwayat', params);
      final response = await http.get(uri);

      setState(() {
        isError = false;
        isLoading = false;
        listRiwayat = (jsonDecode(response.body)['riwayat'] as List)
            .map((e) => RiwayaData.fromJson(e))
            .toList();

        listRiwayat.sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isError = true;
        isLoading = false;
        listRiwayat.clear();
      });
    }
  }

  onRiwaya(int index) {
    DialogNavigator.of(context).push(
      FluidDialogPage(
        builder: (context) => ImamDialog(
          sora: widget.sora,
          rewaya: listRiwayat[index],
        ),
      ),
    );
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
                  colorFilter: ColorFilter.mode(
                    th.iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => DialogNavigator.of(context).close(),
              ),
              Text(
                'Riwayat',
                style: th.textTheme.titleLarge!.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: listRiwayat.length,
            itemBuilder: (context, index) {
              final item = listRiwayat[index];

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
                      onRiwaya(index);
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
                              'assets/icons/quran_book.svg',
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
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
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
