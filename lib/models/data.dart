import 'package:flutter/material.dart';

import 'category.dart';
import 'entry.dart';
import 'feed.dart';
import '../api/miniflux.dart';

class Data extends ChangeNotifier {
  final List<Entry> entries = [];
  final List<Feed> feeds = [];
  final List<Category> categories = [];
  bool isRefresh = false;

  // The constructor allows refreshing at startup
  Data() {
    refresh();
  }

  void read(List<int> entryIds) {
    entries
        .where((entry) => entryIds.contains(entry.id))
        .forEach((entry) => entry.status = 'read');
    notifyListeners();
    updateEntries(entryIds, 'read');
  }

  void unread(List<int> entryIds) {
    entries
        .where((entry) => entryIds.contains(entry.id))
        .forEach((entry) => entry.status = 'unread');
    notifyListeners();
    updateEntries(entryIds, 'unread');
  }

  void refresh() async {
    Set<int> feedIds = {};
    Set<int> categoryIds = {};

    // Trigger a progress indicator in the listeners
    isRefresh = true;
    notifyListeners();

    Map<String, dynamic> json = await getEntries();

    // Clear the existing data
    entries.clear();
    feeds.clear();
    categories.clear();

    // Fill in entries, feeds and categories
    for (Map<String, dynamic> elem in (json['entries'] ?? [])) {
      Entry entry = Entry.fromJson(elem);
      entries.add(entry);
      if (!feedIds.contains(entry.feedId)) {
        feeds.add(entry.feed);
        feedIds.add(entry.feedId);
        if (!categoryIds.contains(entry.feed.category.id)) {
          categories.add(entry.feed.category);
          categoryIds.add(entry.feed.category.id);
        }
      }
    }

    // Sort feeds and categories
    feeds.sort((a, b) => a.title.compareTo(b.title));
    categories.sort((a, b) => a.title.compareTo(b.title));

    // Stop the progress indicator and notify listeners
    isRefresh = false;
    notifyListeners();
  }
}
