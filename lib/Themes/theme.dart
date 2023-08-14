import 'package:flutter/material.dart';
import 'colors.dart';

//! Dark
final darkTheme = ThemeData(
  useMaterial3: true,
  cardColor: card,
  primaryColor: primary,
  fontFamily: 'TiltNeon',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: card,
    primary: primary,
    secondary: secondary,
    background: background,
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(color: background),
  iconTheme: const IconThemeData(color: Colors.white),
  dividerTheme: const DividerThemeData(
    color: Color(0x21FFFFFF),
  ),
  textTheme: const TextTheme(bodySmall: TextStyle(color: Color(0x5AFFFFFF))),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white),
);

//! Light
final lightTheme = ThemeData(
  useMaterial3: true,
  cardColor: cardLight,
  fontFamily: 'TiltNeon',
  primaryColor: primaryLight,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: primaryLight,
    secondary: secondaryLight,
    background: backgroundLight,
    brightness: Brightness.light,
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  dividerTheme: const DividerThemeData(color: Color(0x1F000000)),
  textTheme: const TextTheme(bodySmall: TextStyle(color: Color(0x78000000))),
);
