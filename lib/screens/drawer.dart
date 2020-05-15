import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/miniflux.dart';
import '../models/category.dart';
import '../models/data.dart';
import '../models/nav.dart';

class MyDrawer extends StatelessWidget {
  Widget _buildHeader(Data data, BuildContext context) {
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
                final res = await refreshAllFeeds();
                if (res) {
                  Navigator.pop(context);
                  Scaffold.of(context).showSnackBar(snackBar);
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

  List<Widget> _buildCategoryList(Data data, BuildContext context) {
    final nav = Provider.of<Nav>(context);
    // The First element is the 'Unread'
    List<Widget> categoryList = [
      ListTile(
        title: Text('Unread (${data.entries.length})'),
        onTap: () {
          if (nav.currentFeedId != null || nav.currentCategoryId != null) {
            nav.set(null, null, 'Unread');
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
        final int count = data.entries.where((i) => i.feedId == feed.id).length;
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
          data.entries.where((i) => i.feed.category.id == category.id).length;
      categoryList.add(
        ExpansionTile(
          title: Text('${category.title} ($count)'),
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

  Widget _buildMyDrawer(Data data, BuildContext context) {
    List<Widget> categoryList = _buildCategoryList(data, context);

    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
            _buildHeader(data, context),
          ] +
          categoryList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<Data>(
        builder: (context, data, child) {
          return _buildMyDrawer(data, context);
        },
      ),
    );
  }
}
