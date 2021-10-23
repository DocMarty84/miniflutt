import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.indigo,
);

final appThemeDark = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
  ).copyWith(
    secondary: Colors.indigo,
  ),
);
