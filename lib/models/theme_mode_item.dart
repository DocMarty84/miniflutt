import 'dart:collection';

import 'package:flutter/material.dart';

class ThemeModeItem {
  final String displayName;
  final ThemeMode themeMode;

  ThemeModeItem._(this.displayName, this.themeMode);

  factory ThemeModeItem.of(final ThemeMode themeMode) {
    return ThemeModeItem._(_displayName(themeMode), themeMode);
  }
}

Set<ThemeModeItem> availableThemeModeItems() => LinkedHashSet.of(
    ThemeMode.values.map((mode) => ThemeModeItem.of(mode)));

String _displayName(final ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.system:
      return "System Default";
    case ThemeMode.light:
      return "Light";
    case ThemeMode.dark:
      return "Dark";
    default:
      return themeMode.name;
  }
}