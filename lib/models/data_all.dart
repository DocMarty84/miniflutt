import 'dart:convert';
import 'package:flutter/material.dart';

import 'category.dart';
import 'feed.dart';
import '../api/miniflux.dart';

class DataAll extends ChangeNotifier {
  final List<Feed> feeds = [];
  final List<Category?> categories = [];
  bool isRefresh = false;

  Future<void> refresh() async {
    final Set<int?> categoryIds = {};

    // Trigger a progress indicator in the listeners
    isRefresh = true;
    notifyListeners();

    List<dynamic>? jsonFeeds = [];
    List<dynamic>? jsonCategories = [];
    try {
      final Future<String> jsonFeedsFut = getFeeds();
      final Future<String> jsonCategoriesFut = getCategories();
      jsonFeeds = json.decode(await jsonFeedsFut);
      jsonCategories = json.decode(await jsonCategoriesFut);
    } catch (e) {
      jsonFeeds = [];
      jsonCategories = [];
    }

    // Clear the existing data
    feeds.clear();
    categories.clear();

    // Fill all feeds and categories
    categoryIds.clear();
    for (Map<String, dynamic> elem in (jsonFeeds as Iterable<Map<String, dynamic>>? ?? [])) {
      final Feed feed = Feed.fromJson(elem);
      feeds.add(feed);
      if (!categoryIds.contains(feed.category!.id)) {
        categories.add(feed.category);
        categoryIds.add(feed.category!.id);
      }
    }

    for (Map<String, dynamic> elem in (jsonCategories as Iterable<Map<String, dynamic>>? ?? [])) {
      final Category category = Category.fromJson(elem);
      if (!categoryIds.contains(category.id)) {
        categories.add(category);
        categoryIds.add(category.id);
      }
    }

    // Sort all feeds and categories
    feeds.sort((a, b) => a.title!.compareTo(b.title!));
    categories.sort((a, b) => a!.title!.compareTo(b!.title!));

    // Stop the progress indicator and notify listeners
    isRefresh = false;
    notifyListeners();
  }
}
