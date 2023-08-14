import 'package:quran/Data/imam_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';

import '../../Data/riwaya_data.dart';

class DropdownImamWidget<String> extends StatelessWidget {
  const DropdownImamWidget({
    Key? key,
    required this.valueNotifier,
    required this.itemWidgetBuilder,
    required this.children,
    required this.onChanged,
    this.underline = false,
    this.showSeparator = true,
    this.exit = MiraiExit.fromAll,
    this.chevronDownColor,
    this.showMode = MiraiShowMode.bottom,
    this.maxHeight,
    this.showSearchTextField = false,
    this.showOtherAndItsTextField = false,
    this.other,
  }) : super(key: key);

  final ValueNotifier<ImamData> valueNotifier;
  final MiraiDropdownBuilder<String> itemWidgetBuilder;
  final List<String> children;
  final ValueChanged<String> onChanged;
  final bool underline;
  final bool showSeparator;
  final MiraiExit exit;
  final Color? chevronDownColor;
  final MiraiShowMode showMode;
  final double? maxHeight;
  final bool showSearchTextField;
  final bool showOtherAndItsTextField;
  final Widget? other;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return MiraiPopupMenu<String>(
      key: UniqueKey(),
      enable: true,
      space: 4,
      radius: 10,
      showMode: showMode,
      exit: exit,
      showSeparator: showSeparator,
      children: children,
      itemWidgetBuilder: itemWidgetBuilder,
      onChanged: onChanged,
      maxHeight: maxHeight,
      bgColor: th.colorScheme.background,
      showOtherAndItsTextField: showOtherAndItsTextField,
      showSearchTextField: showSearchTextField,
      other: other,
      cardColor: th.cardColor,
      child: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: th.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: ValueListenableBuilder<ImamData>(
                valueListenable: valueNotifier,
                builder: (_,ImamData chosenTitle, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      chosenTitle.name,
                      key: ValueKey<ImamData>(chosenTitle),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              color: th.iconTheme.color,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}


class DropdownRiwayaWidget<String> extends StatelessWidget {
  const DropdownRiwayaWidget({
    Key? key,
    required this.valueNotifier,
    required this.itemWidgetBuilder,
    required this.children,
    required this.onChanged,
    this.underline = false,
    this.showSeparator = true,
    this.exit = MiraiExit.fromAll,
    this.chevronDownColor,
    this.showMode = MiraiShowMode.bottom,
    this.maxHeight,
    this.showSearchTextField = false,
    this.showOtherAndItsTextField = false,
    this.other,
  }) : super(key: key);

  final ValueNotifier<RiwayaData> valueNotifier;
  final MiraiDropdownBuilder<String> itemWidgetBuilder;
  final List<String> children;
  final ValueChanged<String> onChanged;
  final bool underline;
  final bool showSeparator;
  final MiraiExit exit;
  final Color? chevronDownColor;
  final MiraiShowMode showMode;
  final double? maxHeight;
  final bool showSearchTextField;
  final bool showOtherAndItsTextField;
  final Widget? other;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return MiraiPopupMenu<String>(
      key: UniqueKey(),
      enable: true,
      space: 4,
      radius: 10,
      showMode: showMode,
      exit: exit,
      showSeparator: showSeparator,
      children: children,
      itemWidgetBuilder: itemWidgetBuilder,
      onChanged: onChanged,
      maxHeight: maxHeight,
      bgColor: th.colorScheme.background,
      showOtherAndItsTextField: showOtherAndItsTextField,
      showSearchTextField: showSearchTextField,
      other: other,
      cardColor: th.cardColor,
      child: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: th.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: ValueListenableBuilder<RiwayaData>(
                valueListenable: valueNotifier,
                builder: (_,RiwayaData chosenTitle, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      chosenTitle.name,
                      key: ValueKey<RiwayaData>(chosenTitle),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              color: th.iconTheme.color,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
