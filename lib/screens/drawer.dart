import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/miniflux.dart';
import '../models/category.dart';
import '../models/data.dart';
import '../models/nav.dart';
import '../models/settings.dart';

class MyDrawerHeader extends StatelessWidget {
  MyDrawerHeader({Key key, @required this.data}) : super(key: key);
  final Data data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.0,
      child: DrawerHeader(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Settings',
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6.color)),
              trailing: Icon(
                Icons.settings,
                color: Theme.of(context).primaryTextTheme.headline6.color,
              ),
              onTap: () {
                final settings = Provider.of<Settings>(context, listen: false);
                settings.load();
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              title: Text('Refresh',
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6.color)),
              trailing: (!data.isRefresh
                  ? Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                    )
                  : Icon(
                      Icons.file_download,
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                    )),
              onTap: () {
                data.refresh();
              },
              onLongPress: () async {
                final snackBar = SnackBar(
                  content: Text('All feeds are updated in the background. '
                      'Refresh in a few seconds.'),
                );
                try {
                  await refreshAllFeeds();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An error occured!\n$e')));
                }
              },
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  Future<void> _actionRead(
      List<int> entryIds, Data data, BuildContext context) async {
    final snackBar = SnackBar(
      content: Text('${entryIds.length} item(s) mark read'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          data.unread(entryIds);
        },
      ),
    );
    try {
      await data.read(entryIds);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occured!\n$e')));
    }
  }

  List<Widget> _buildCategoryList(Data data, BuildContext context) {
    final nav = Provider.of<Nav>(context);
    final unreadEntries = data.entries.where((i) => i.status == 'unread');
    // The First element is the 'All'
    List<Widget> categoryList = [
      ListTile(
        title: Text('All (${unreadEntries.length})'),
        onTap: () {
          if (nav.currentFeedId != null || nav.currentCategoryId != null) {
            nav.set(null, null, 'All');
          }
          // Close the drawer
          Navigator.pop(context);
        },
        onLongPress: () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String feedOnLongPress =
              (prefs.getString('feedOnLongPress') ?? 'no');
          if (feedOnLongPress == 'read') {
            final List<int> entryIds = data.entries
                .where((i) => i.status == 'unread')
                .map((entry) => entry.id)
                .toList();
            _actionRead(entryIds, data, context);
          }
        },
      )
    ];

    for (Category category in data.categories) {
      // Build the feed ListTile, by category
      List<Widget> feedList = data.feeds
          .where((feed) => feed.category.id == category.id)
          .map<Widget>((feed) {
        final int count =
            unreadEntries.where((i) => i.feedId == feed.id).length;
        return ListTile(
          title: Text('    ${feed.title} ($count)'),
          onTap: () {
            if (nav.currentFeedId != feed.id) {
              nav.set(feed.id, null, feed.title);
            }
            // Close the drawer
            Navigator.pop(context);
          },
          onLongPress: () async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            final String feedOnLongPress =
                (prefs.getString('feedOnLongPress') ?? 'no');
            if (feedOnLongPress == 'read') {
              final List<int> entryIds = data.entries
                  .where((i) => i.feedId == feed.id && i.status == 'unread')
                  .map((entry) => entry.id)
                  .toList();
              _actionRead(entryIds, data, context);
            }
          },
        );
      }).toList();

      // Build the category ExpansionTile
      final int count =
          unreadEntries.where((i) => i.feed.category.id == category.id).length;
      categoryList.add(
        ExpansionTile(
          title: Text('${category.title} ($count)'),
          initiallyExpanded: nav.currentCategoryId == category.id ||
              data.feeds
                  .where((feed) => feed.category.id == category.id)
                  .map((feed) => feed.id)
                  .contains(nav.currentFeedId),
          children: feedList,
          onExpansionChanged: (exp) {
            if (exp && nav.currentCategoryId != category.id) {
              nav.set(null, category.id, category.title);
            }
          },
        ),
      );
    }
    return categoryList;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<Data>(
        builder: (context, data, child) {
          return ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
                  MyDrawerHeader(data: data),
                ] +
                _buildCategoryList(data, context),
          );
        },
      ),
    );
  }
}
