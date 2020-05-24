import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/miniflux.dart';
import '../models/category.dart';
import '../models/data.dart';
import '../models/nav.dart';

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
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              trailing: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              title: Text('Refresh', style: TextStyle(color: Colors.white)),
              trailing: (!data.isRefresh
                  ? Icon(
                      Icons.refresh,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.file_download,
                      color: Colors.white,
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
                  Scaffold.of(context).showSnackBar(snackBar);
                } catch (e) {
                  Scaffold.of(context).showSnackBar(
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
