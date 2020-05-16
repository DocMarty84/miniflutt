import 'package:flutter/material.dart';

class Nav extends ChangeNotifier {
  int currentFeedId;
  int currentCategoryId;
  String appBarTitle = 'All';

  void set(int feedId, int categoryId, String title) {
    currentFeedId = feedId;
    currentCategoryId = categoryId;
    appBarTitle = title;
    notifyListeners();
  }
}
