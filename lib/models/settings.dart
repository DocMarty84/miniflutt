import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  late bool markReadOnScroll;
  String? entryOnLongPress;
  String? entrySwipeLeft;
  String? entrySwipeRight;
  String? feedOnLongPress;
  String? fontSize;
  late bool isLoad;

  Future<void> load() async {
    // First load preferences
    isLoad = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    markReadOnScroll = (prefs.getBool('markReadOnScroll') ?? false);
    entryOnLongPress = (prefs.getString('entryOnLongPress') ?? 'read');
    entrySwipeLeft = (prefs.getString('entrySwipeLeft') ?? 'no');
    entrySwipeRight = (prefs.getString('entrySwipeRight') ?? 'no');
    feedOnLongPress = (prefs.getString('feedOnLongPress') ?? 'no');
    fontSize = (prefs.getString('fontSize') ?? 'medium');
    isLoad = false;
    notifyListeners();
  }
}
