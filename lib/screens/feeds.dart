import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/data_all.dart';

class MyFeedsList extends StatelessWidget {
  MyFeedsList({Key? key, required this.dataAll}) : super(key: key);
  final DataAll dataAll;

  List<Widget> _buildFeeds(BuildContext context) {
    List<Widget> categoryList = [];

    for (Category? category in dataAll.categories) {
      // Build the category ExpansionTile
      categoryList.add(
        ListTile(
          title: Text(
            category!.title!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/category',
              arguments: category,
            );
          },
        ),
      );

      // Build the feed ListTile, by category
      List<Widget> feedList = dataAll.feeds
          .where((feed) => feed.category!.id == category.id)
          .map<Widget>((feed) {
        return ListTile(
          title: Text('    ${feed.title}'),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/feed',
              arguments: feed,
            );
          },
        );
      }).toList();

      categoryList += feedList;
    }
    return categoryList;
  }

  Widget build(BuildContext context) {
    return ListView(
      children: _buildFeeds(context),
    );
  }
}

class MyFeeds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories and feeds')),
      body: Center(
        child: Consumer<DataAll>(
          builder: (context, dataAll, child) {
            if (dataAll.isRefresh) {
              return CircularProgressIndicator();
            } else {
              return MyFeedsList(dataAll: dataAll);
            }
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 3.0),
            child: FloatingActionButton(
              child: Icon(Icons.category),
              onPressed: () => Navigator.pushNamed(context, '/category'),
              heroTag: null,
              mini: true,
            ),
          ),
          FloatingActionButton(
            child: Icon(Icons.rss_feed),
            onPressed: () => Navigator.pushNamed(context, '/feed_create'),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
