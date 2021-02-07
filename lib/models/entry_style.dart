import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryStyle extends ChangeNotifier {
  FontSize fontSize;

  // The constructor allows refreshing at startup
  EntryStyle() {
    refresh();
  }

  Future<void> refresh() async {
    // Get preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Font size
    final String _fontSize = (prefs.getString('fontSize') ?? 'medium');
    if (_fontSize == 'small') {
      fontSize = FontSize.small;
    } else if (_fontSize == 'large') {
      fontSize = FontSize.large;
    } else if (_fontSize == 'xlarge') {
      fontSize = FontSize.xLarge;
    } else {
      fontSize = FontSize.medium;
    }
  }
}
