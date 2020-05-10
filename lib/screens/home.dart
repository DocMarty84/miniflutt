import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'drawer.dart';
import '../models/data.dart';
import '../models/entry.dart';
import '../models/nav.dart';

// Filter entries based on the navigation info
List<Entry> _filterEntries(Data data, Nav nav) {
  List<Entry> entries = [];
  if (nav.currentCategoryId != null) {
    entries = data.entries
        .where((i) => i.feed.category.id == nav.currentCategoryId)
        .toList();
  } else if (nav.currentFeedId != null) {
    entries = data.entries.where((i) => i.feedId == nav.currentFeedId).toList();
  } else {
    entries = data.entries;
  }
  return entries;
}

// Implements the action buttons in a widget to display an 'Undo' action in a
// snackbar.
// See https://medium.com/@ksheremet/flutter-showing-snackbar-within-the-widget-that-builds-a-scaffold-3a817635aeb2
class MyHomeMarkRead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done_all),
      onPressed: () async {
        final nav = Provider.of<Nav>(context, listen: false);
        final data = Provider.of<Data>(context, listen: false);
        final entryIds = _filterEntries(data, nav)
            .where((entry) => entry.status == 'unread')
            .map((entry) => entry.id)
            .toList();
        final snackBar = SnackBar(
          content: Text('${entryIds.length} item(s) mark read'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              data.unread(entryIds);
            },
          ),
        );
        final res = await data.read(entryIds);
        if (res) {
          Scaffold.of(context).showSnackBar(snackBar);
        }
      },
    );
  }
}

class MyHome extends StatelessWidget {
  Widget _buildEntryList(Data data, Nav nav, BuildContext context) {
    final List<Entry> entries = _filterEntries(data, nav);
    return RefreshIndicator(
      onRefresh: () async {
        data.refresh();
      },
      child: ListView.builder(
        itemCount: entries.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final Entry entry = entries[i ~/ 2];
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
        // action button
        actions: <Widget>[
          MyHomeMarkRead(),
        ],
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
