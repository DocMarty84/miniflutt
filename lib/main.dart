import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';
import 'models/data.dart';
import 'models/data_all.dart';
import 'models/nav.dart';
import 'models/settings.dart';
import 'screens/home.dart';
import 'screens/category.dart';
import 'screens/entry.dart';
import 'screens/feed.dart';
import 'screens/feed_create.dart';
import 'screens/feeds.dart';
import 'screens/search.dart';
import 'screens/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Data()),
        ChangeNotifierProvider(create: (context) => DataAll()),
        ChangeNotifierProvider(create: (context) => Nav()),
        ChangeNotifierProvider(create: (context) => Settings()),
      ],
      child: MaterialApp(
        title: 'Miniflutt',
        theme: appTheme,
        darkTheme: appThemeDark,
        initialRoute: '/',
        routes: {
          '/': (context) => MyHome(),
          '/category': (context) => MyCategory(),
          '/entry': (context) => MyEntry(),
          '/feed': (context) => MyFeed(),
          '/feed_create': (context) => MyFeedCreate(),
          '/feeds': (context) => MyFeeds(),
          '/search': (context) => MySearch(),
          '/settings': (context) => MySettings(),
        },
      ),
    );
  }
}
