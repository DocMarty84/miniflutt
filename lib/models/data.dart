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

  Future<bool> read(List<int> entryIds) async {
    if (entryIds.length == 0) {
      return true;
    }
    entries
        .where((entry) => entryIds.contains(entry.id))
        .forEach((entry) => entry.status = 'read');
    notifyListeners();
    return await updateEntries(entryIds, 'read');
  }

  Future<bool> unread(List<int> entryIds) async {
    if (entryIds.length == 0) {
      return true;
    }
    entries
        .where((entry) => entryIds.contains(entry.id))
        .forEach((entry) => entry.status = 'unread');
    notifyListeners();
    return await updateEntries(entryIds, 'unread');
  }

  Future<bool> toggleRead(int entryId) async {
    final Entry currentEntry =
        entries.firstWhere((entry) => entry.id == entryId);
    final String newStatus = currentEntry.status == 'read' ? 'unread' : 'read';
    currentEntry.status = newStatus;
    notifyListeners();
    return await updateEntries([entryId], newStatus);
  }

  Future<bool> toggleStar(int entryId) async {
    entries
        .where((entry) => entry.id == entryId)
        .forEach((entry) => entry.starred = !entry.starred);
    notifyListeners();
    return await toggleEntryBookmark(entryId);
  }

  void refresh() async {
    final Set<int> feedIds = {};
    final Set<int> categoryIds = {};

    // Trigger a progress indicator in the listeners
    isRefresh = true;
    notifyListeners();

    final Map<String, dynamic> json = await getEntries();

    // Clear the existing data
    entries.clear();
    feeds.clear();
    categories.clear();

    // Fill in entries, feeds and categories
    for (Map<String, dynamic> elem in (json['entries'] ?? [])) {
      final Entry entry = Entry.fromJson(elem);
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
