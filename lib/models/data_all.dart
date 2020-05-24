import 'package:flutter/material.dart';

import 'category.dart';
import 'feed.dart';
import '../api/miniflux.dart';

class DataAll extends ChangeNotifier {
  final List<Feed> feeds = [];
  final List<Category> categories = [];
  bool isRefresh = false;

  void refresh({String search}) async {
    final Set<int> categoryIds = {};

    // Trigger a progress indicator in the listeners
    isRefresh = true;
    notifyListeners();

    List<dynamic> jsonFeeds = [];
    try {
      jsonFeeds = await getFeeds();
    } catch (e) {
      jsonFeeds = [];
    }

    // Clear the existing data
    feeds.clear();
    categories.clear();

    // Fill all feeds and categories
    categoryIds.clear();
    for (Map<String, dynamic> elem in (jsonFeeds ?? [])) {
      final Feed feed = Feed.fromJson(elem);
      feeds.add(feed);
      if (!categoryIds.contains(feed.category.id)) {
        categories.add(feed.category);
        categoryIds.add(feed.category.id);
      }
    }

    // Sort all feeds and categories
    feeds.sort((a, b) => a.title.compareTo(b.title));
    categories.sort((a, b) => a.title.compareTo(b.title));

    // Stop the progress indicator and notify listeners
    isRefresh = false;
    notifyListeners();
  }
}
