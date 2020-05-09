import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'drawer.dart';
import '../models/data.dart';
import '../models/entry.dart';
import '../models/nav.dart';

class MyHome extends StatelessWidget {
  // Filter entries based on the navigation info
  List<Entry> _filterEntries(Data data, Nav nav) {
    List<Entry> entries = [];
    if (nav.currentCategoryId != null) {
      entries = data.entries
          .where((i) => i.feed.category.id == nav.currentCategoryId)
          .toList();
    } else if (nav.currentFeedId != null) {
      entries =
          data.entries.where((i) => i.feedId == nav.currentFeedId).toList();
    } else {
      entries = data.entries;
    }
    return entries;
  }

  Widget _buildEntryList(Data data, Nav nav, BuildContext context) {
    List<Entry> entries = _filterEntries(data, nav);
    return RefreshIndicator(
      onRefresh: () async {
        data.refresh();
      },
      child: ListView.builder(
        itemCount: entries.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          Entry entry = entries[i ~/ 2];
          return ListTile(
            title: Text(
              '${entry.title}',
              style: TextStyle(
                color: (entry.status == 'unread' ? Colors.black : Colors.grey),
                fontStyle: (entry.status == 'unread'
                    ? FontStyle.normal
                    : FontStyle.italic),
              ),
            ),
            subtitle: Text(
                (nav.currentFeedId == null ? entry.feed.title + '\n' : '') +
                    DateFormat.yMEd()
                        .add_jm()
                        .format(DateTime.parse(entry.publishedAt))),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/entry',
                arguments: entry,
              );
              final List<int> entryIds = [entry.id];
              data.read(entryIds);
            },
            onLongPress: () {
              final List<int> entryIds = [entry.id];
              data.unread(entryIds);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<Nav>(
          builder: (context, nav, child) {
            return Text(nav.appBarTitle);
          },
        ),
      ),
      body: Center(
        child: Consumer2<Data, Nav>(
          builder: (context, data, nav, child) {
            if (data.isRefresh) {
              return CircularProgressIndicator();
            } else {
              // By default, show a loading spinner.
              return _buildEntryList(data, nav, context);
            }
          },
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
